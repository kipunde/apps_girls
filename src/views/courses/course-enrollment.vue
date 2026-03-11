<script>
import { Modal } from "bootstrap";
import { apiService } from "@/services/apiService";
import Swal from "sweetalert2";

export default {
  data() {
    return {
      loading: false,
      enrollments: [],       // all user-course assignments
      users: [],             // all users for dropdown
      coursesDropdown: [],   // all courses for assignment
      filters: { search: "" },
      assignModal: null,
      editModal: null,
      selectedUser: "",      // for assign modal
      selectedCourse: "",    // for assign modal
      editingEnrollmentId: null, // track enrollment being edited
      editingCourse: "",     // course for edit modal
      columns: [
        { title: "ID", dataIndex: "id", key: "id" },
        { title: "Student", dataIndex: "user_name", key: "user_name" },
        { title: "Course", dataIndex: "title", key: "title" },
        { title: "Enrolled On", dataIndex: "enrolled_at", key: "enrolled_at" },
        { title: "Status", dataIndex: "status", key: "status" },
        { title: "Progress", dataIndex: "progress", key: "progress" },
        { title: "Actions", key: "actions" },
      ],
    };
  },

  mounted() {
    this.fetchEnrollments();
    this.fetchAllUsers();
    this.fetchAllCourses();
  },

  computed: {
    filteredData() {
      const q = this.filters.search.toLowerCase();
      return this.enrollments.filter(
        (e) =>
          e.user_name.toLowerCase().includes(q) ||
          e.title.toLowerCase().includes(q)
      );
    },
  },

  methods: {
    // ---------------- Fetch all enrollments ----------------
    async fetchEnrollments() {
      this.loading = true;
      try {
        const res = await apiService.getAllUserCourses();
        console.log("Data from api", res);
        this.enrollments = (res.enrollments || []).map((e) => ({
          id: e.id,
          user_id: e.user_id,
          user_name: e.fullname,
          course_id: e.course_id,
          title: e.title,
          enrolled_at: e.enrolled_at,
          status: e.status,
          progress: e.progress || 0,
        }));
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "Failed to load enrollments", "error");
      } finally {
        this.loading = false;
      }
    },

    // ---------------- Fetch all users ----------------
    async fetchAllUsers() {
      try {
        const res = await apiService.getAllUsers();
        this.users = res.users || [];
      } catch (err) {
        console.error(err);
      }
    },

    // ---------------- Fetch all courses ----------------
    async fetchAllCourses() {
      try {
        const res = await apiService.getCourses();
        this.coursesDropdown = res.courses || [];
      } catch (err) {
        console.error(err);
      }
    },

    clearFilters() {
      this.filters.search = "";
    },

    // ---------------- Open assign modal ----------------
    openAssignModal() {
      this.selectedUser = "";
      this.selectedCourse = "";
      const modalEl = document.getElementById("assignModal");
      this.assignModal = Modal.getInstance(modalEl) || new Modal(modalEl);
      this.assignModal.show();
    },

    // ---------------- Open edit modal ----------------
    openEditModal(record) {
      this.editingEnrollmentId = record.id;
      this.selectedUser = record.user_id; // fixed, cannot change
      this.editingCourse = record.course_id;
      console.log("Selected user ID:", this.selectedUser, " and", this.editingCourse, "and",this.editingEnrollmentId);
      const modalEl = document.getElementById("editModal");
      this.editModal = Modal.getInstance(modalEl) || new Modal(modalEl);
      this.editModal.show();
    },

    // ---------------- Assign new course ----------------
    async assignCourse() {
      if (!this.selectedUser || !this.selectedCourse) {
        Swal.fire("Error", "Select user and course", "warning");
        return;
      }
      try {
        const res = await apiService.assignCourse(this.selectedUser, this.selectedCourse);
        if (res.code === 200) {
          Swal.fire("Success", res.message || "Course assigned!", "success");
          this.fetchEnrollments();
          this.assignModal.hide();
        } else {
          Swal.fire("Error", res.message || "Failed to assign course", "error");
        }
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "Failed to assign course", "error");
      }
    },

    // ---------------- Update existing assignment ----------------
async updateCourse() {
  if (!this.editingCourse) {
    Swal.fire("Error", "Select course", "warning");
    return;
  }

  try {
    const res = await apiService.updateAssign(
      this.editingEnrollmentId,
      Number(this.selectedUser), // ensures valid ID
      Number(this.editingCourse)
    );

    if (res.code === 200) {
      Swal.fire("Success", res.message || "Course updated!", "success");
      this.fetchEnrollments();
      this.editModal.hide();
      this.editingEnrollmentId = null;
      this.editingCourse = "";
    } else {
      Swal.fire("Error", res.message || "Failed to update course", "error");
    }
  } catch (err) {
    console.error(err);
    Swal.fire("Error", "Failed to update course", "error");
  }
},

    // ---------------- Remove enrollment ----------------
    async removeEnrollment(record) {
      const result = await Swal.fire({
        title: "Remove Enrollment?",
        text: `Remove ${record.user_name} from ${record.title}?`,
        icon: "warning",
        showCancelButton: true,
      });
      if (!result.isConfirmed) return;

      try {
        const res = await apiService.removeEnrollment(record.id);
        console.log("Fedback from api", res, "on the id", record.id);
        if (res.code === 200) {
          Swal.fire("Removed", res.message || "Enrollment removed", "success");
          this.fetchEnrollments();
        } else {
          Swal.fire("Error", res.message || "Failed to remove enrollment", "error");
        }
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "Failed to remove enrollment", "error");
      }
    },
  },
};
</script>
<template>
  <layout-header />
  <layout-sidebar />

  <div class="page-wrapper">
    <div class="content">
      <div class="page-header d-flex justify-content-between align-items-center">
        <div class="page-title">
          <h4>All User Courses</h4>
          <h6>Assign or edit courses for users</h6>
        </div>
        <button class="btn btn-added" @click="openAssignModal()">
          Assign Course
        </button>
      </div>

      <div class="d-flex mb-3">
        <input v-model="filters.search" type="text" class="form-control me-2" placeholder="Search user or course" />
        <button class="btn btn-primary ms-2" @click="clearFilters">Clear</button>
      </div>

      <div class="card table-list-card">
        <div class="card-body">
          <div class="table-responsive">
            <a-table :columns="columns" :data-source="filteredData" rowKey="id" :loading="loading">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'actions'">
                  <button class="btn btn-sm btn-warning me-2" @click="openEditModal(record)">Edit</button>
                  <button class="btn btn-sm btn-danger" @click="removeEnrollment(record)">Remove</button>
                </template>
                <template v-else>
                  <span>{{ record[column.dataIndex] }}</span>
                </template>
              </template>
            </a-table>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Assign Modal -->
  <div class="modal fade" id="assignModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Assign Course to User</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label>User</label>
            <select class="form-select" v-model="selectedUser">
              <option value="" disabled>Select user</option>
              <option v-for="u in users" :key="u.id" :value="u.id">{{ u.fullname }}</option>
            </select>
          </div>
          <div class="mb-3">
            <label>Course</label>
            <select class="form-select" v-model="selectedCourse">
              <option value="" disabled>Select course</option>
              <option v-for="c in coursesDropdown" :key="c.id" :value="c.id">{{ c.title }}</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button class="btn btn-primary" @click="assignCourse">Assign</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Edit Modal -->
  <div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Edit Assigned Course</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label>User</label>
            <input type="text" class="form-control" :value="users.find(u => u.id === selectedUser)?.fullname" disabled />
          </div>
          <div class="mb-3">
            <label>Course</label>
            <select class="form-select" v-model="editingCourse">
              <option value="" disabled>Select course</option>
              <option v-for="c in coursesDropdown" :key="c.id" :value="c.id">{{ c.title }}</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button class="btn btn-primary" @click="updateCourse">Update</button>
        </div>
      </div>
    </div>
  </div>
</template>