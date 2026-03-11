<script>
import { Modal } from "bootstrap";
import { apiService } from "@/services/apiService";
import Swal from "sweetalert2";

export default {
  data() {
    return {
      loading: false,
      courses: [],
      filters: { search: "" },
      columns: [
        { title: "ID", dataIndex: "id", key: "id" },
        { title: "Thumbnail", dataIndex: "thumbnail_url", key: "thumbnail" },
        { title: "Title", dataIndex: "title", key: "title" },
        { title: "Description", dataIndex: "description", key: "description" },
        { title: "Created On", dataIndex: "created_at", key: "created_at" },
        { title: "Action", key: "action" },
      ],
      courseForm: {
        title: "",
        description: "",
        thumbnail: null, // file object
        preview: null,   // for showing image preview
      },
      saving: false,
      editingCourseId: null, // track course being edited
    };
  },

  mounted() {
    this.fetchCourses();
  },

  computed: {
    filteredData() {
      const query = this.filters.search.toLowerCase();
      return this.courses.filter(
        (course) =>
          course.title.toLowerCase().includes(query) ||
          course.description.toLowerCase().includes(query)
      );
    },
  },

  methods: {
    async fetchCourses() {
      this.loading = true;
      try {
        const response = await apiService.getCourses();
        console.log("Data to display", response);
        
        if (response.code === 200) {
          this.courses = response.courses.map((c) => ({
            id: c.id,
            title: c.title,
            description: c.description,
            created_at: c.created_at,
            thumbnail_url: c.thumbnail_url || null,
          }));
        }
      } catch (error) {
        console.error("Error loading courses:", error);
      } finally {
        this.loading = false;
      }
    },

    clearFilters() {
      this.filters.search = "";
    },

    async deleteCourse(course) {
      const result = await Swal.fire({
        title: "Are you sure?",
        text: "This action cannot be undone!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        cancelButtonColor: "#3085d6",
        confirmButtonText: "Yes, delete it!",
        cancelButtonText: "Cancel",
      });
      if (!result.isConfirmed) return;

      try {
        const response = await apiService.deleteCourse(course.id);
        if (response.code === 200) {
          Swal.fire("Deleted!", "Course has been deleted.", "success");
          this.fetchCourses();
        }
      } catch (error) {
        console.error("Delete course error:", error);
        Swal.fire("Error", "Failed to delete course", "error");
      }
    },

    onThumbnailChange(event) {
      const file = event.target.files[0];
      if (file) {
        this.courseForm.thumbnail = file;

        // create preview
        const reader = new FileReader();
        reader.onload = () => {
          this.courseForm.preview = reader.result;
        };
        reader.readAsDataURL(file);
      } else {
        this.courseForm.thumbnail = null;
        this.courseForm.preview = null;
      }
    },

    addCourse() {
      this.editingCourseId = null;
      this.courseForm.title = "";
      this.courseForm.description = "";
      this.courseForm.thumbnail = null;
      this.courseForm.preview = null;

      const modalEl = document.getElementById("courseModal");
      const modalInstance = Modal.getInstance(modalEl) || new Modal(modalEl);
      modalInstance.show();
    },

    editCourse(course) {
      this.editingCourseId = course.id;
      this.courseForm.title = course.title;
      this.courseForm.description = course.description;
      this.courseForm.thumbnail = null;
      this.courseForm.preview = course.thumbnail_url || null;

      const modalEl = document.getElementById("courseModal");
      const modalInstance = Modal.getInstance(modalEl) || new Modal(modalEl);
      modalInstance.show();
    },

    async saveCourse() {
      if (!this.courseForm.title || !this.courseForm.description) {
        Swal.fire("Validation", "Please fill all fields", "warning");
        return;
      }

      this.saving = true;
      try {
        const payload = {
          title: this.courseForm.title,
          description: this.courseForm.description,
          thumbnail: this.courseForm.thumbnail, // file object
        };

        let response;
        if (this.editingCourseId) {
          payload.id = this.editingCourseId;
          response = await apiService.updateCourse(payload);
        } else {
          response = await apiService.saveCourse(payload);
        }

        if (response.code === 200) {
          Swal.fire("Success", this.editingCourseId ? "Course updated!" : "Course created!", "success");

          // reset form
          this.courseForm.title = "";
          this.courseForm.description = "";
          this.courseForm.thumbnail = null;
          this.courseForm.preview = null;
          this.editingCourseId = null;

          this.fetchCourses();

          const modalEl = document.getElementById("courseModal");
          const modalInstance = Modal.getInstance(modalEl) || new Modal(modalEl);
          modalInstance.hide();
        } else {
          Swal.fire("Error", response.message || "Failed to save course", "error");
        }
      } catch (error) {
        console.error("Save course error:", error);
        Swal.fire("Error", "Failed to save course", "error");
      } finally {
        this.saving = false;
      }
    },
     imageUrl(path) {
    if (!path) return null;
    return `${location.origin}${path}`;
  },
  },
};
</script>

<template>
  <layout-header></layout-header>
  <layout-sidebar></layout-sidebar>

  <div class="page-wrapper">
    <div class="content">
      <div class="page-header d-flex justify-content-between align-items-center">
        <div class="page-title">
          <h4>Course List</h4>
          <h6>Manage Your Courses</h6>
        </div>
        <div class="page-btn">
          <button class="btn btn-added" @click="addCourse">
            <vue-feather type="plus-circle" class="me-2"></vue-feather>
            Add Course
          </button>
        </div>
      </div>

      <div class="d-flex mb-3">
        <input
          type="text"
          v-model="filters.search"
          class="form-control me-2"
          placeholder="Search by title or description"
        />
        <button class="btn btn-primary ms-2" @click="clearFilters">Clear</button>
      </div>

      <div class="card table-list-card">
        <div class="card-body">
          <div class="table-responsive">
            <a-table :columns="columns" :data-source="filteredData" :loading="loading" rowKey="id">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'action'">
                  <div class="edit-delete-action">
                    <a class="me-2 p-2 mb-0" @click="editCourse(record)">
                      <vue-feather type="edit-2"></vue-feather>
                    </a>
                    <a class="me-2 p-2 mb-0" @click="deleteCourse(record)">
                      <vue-feather type="trash-2"></vue-feather>
                    </a>
                  </div>
                </template>
                 <template v-else-if="column.key === 'thumbnail'">
  <img
    v-if="record.thumbnail_url"
    :src="record.thumbnail_url"
    alt="Thumbnail"
    style="width:50px; border-radius:4px;"
  />
  <span v-else>—</span>
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

  <!-- Course Modal -->
  <div class="modal fade" id="courseModal" tabindex="-1" aria-labelledby="courseModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="courseModalLabel">
            {{ editingCourseId ? "Edit Course" : "Add New Course" }}
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label">Title</label>
            <input type="text" v-model="courseForm.title" class="form-control" placeholder="Course title" />
          </div>
          <div class="mb-3">
            <label class="form-label">Description</label>
            <textarea v-model="courseForm.description" class="form-control" rows="3" placeholder="Course description"></textarea>
          </div>
          <div class="mb-3">
            <label class="form-label">Thumbnail</label>
            <input type="file" @change="onThumbnailChange" class="form-control" accept="image/*" />
          </div>
          <div v-if="courseForm.preview" class="mb-3">
            <label class="form-label">Preview</label><br />
            <img :src="courseForm.preview" alt="Thumbnail Preview" style="width:120px; height:auto; border-radius:4px;" />
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" :disabled="saving" @click="saveCourse">
            {{ saving ? "Saving..." : (editingCourseId ? "Update Course" : "Save Course") }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>