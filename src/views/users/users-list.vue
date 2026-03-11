<script>
import { apiService } from "@/services/apiService";
import Swal from "sweetalert2";

export default {
  data() {
    return {
      loading: false,
      data: [],
      filters: {
        fullname: "", // this is the search input
        status: "",
      },
      columns: [
        { title: "RegNo", dataIndex: "id", key: "id" },
        { title: "Full Name", dataIndex: "fullname", key: "fullname" },
        { title: "Mobile", dataIndex: "mobile", key: "mobile" },
        { title: "Email", dataIndex: "email", key: "email" },
        { title: "Location", dataIndex: "location", key: "location" },
        { title: "Role", dataIndex: "role", key: "role" },
        { title: "Created On", dataIndex: "created_at", key: "created_at" },
        { title: "Status", dataIndex: "status", key: "status" },
        { title: "Action", key: "action" },
      ],
    };
  },

  mounted() {
    this.fetchUsers();
  },

  computed: {
    filteredData() {
      return this.data.filter(user => {
        const query = this.filters.fullname.toLowerCase();
        const searchMatch =
          user.fullname.toLowerCase().includes(query) ||
          user.mobile.toLowerCase().includes(query) ||
          user.email.toLowerCase().includes(query);

        const statusMatch = this.filters.status
          ? user.status === this.filters.status
          : true;

        return searchMatch && statusMatch;
      });
    },
  },

  methods: {
    async fetchUsers() {
      this.loading = true;
      try {
        const response = await apiService.getAllUsers();
        if (response.code === 200) {
          this.data = response.users.map(user => ({
            id: user.id,
            fullname: user.fullname,
            mobile: user.mobile,
            email: user.email,
            profile_pic: user.profile_pic,
            location: user.location,
            role: user.role,
            created_at: user.created_at,
            status: user.status,
          }));
        } else {
          console.error(response.message);
        }
      } catch (error) {
        console.error("Error loading users:", error);
      } finally {
        this.loading = false;
      }
    },

    clearFilters() {
      this.filters.fullname = "";
      this.filters.status = "";
    },

    async toggleStatus(record) {
      if (record.role === "admin") {
        Swal.fire("Action Denied", "Admin user status cannot be changed!", "warning");
        return;
      }

      const newStatus = record.status === "1" ? "2" : "1";
      const statusText = newStatus === "1" ? "Inactive" : "Active";

      const result = await Swal.fire({
        title: "Are you sure?",
        text: `Do you want to change the status to "${statusText}"?`,
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Yes, change it!",
        cancelButtonText: "Cancel",
      });

      if (!result.isConfirmed) return;

      try {
        const response = await apiService.toggleUserStatus(record.id, newStatus);
        console.log("Status Data",response);
        
        if (response.success === true) {
          record.status = newStatus;
          Swal.fire({
            icon: "success",
            title: `Status changed to "${statusText}"`,
            timer: 1500,
            showConfirmButton: false,
          });
        } else {
          Swal.fire("Error", response.message || "Failed to update status", "error");
        }
      } catch (error) {
        console.error("Toggle status error:", error);
        Swal.fire("Error", "Failed to update status", "error");
      }
    },

    async deleteRecord(record) {
      if (record.role === "admin") {
        Swal.fire("Action Denied", "Admin user cannot be deleted!", "warning");
        return;
      }

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

      if (result.isConfirmed) {
        try {
          const response = await apiService.deleteUser(record.id);
          if (response.code === 200) {
            Swal.fire({
              icon: "success",
              title: "Deleted!",
              text: "Record has been deleted.",
              timer: 1500,
              showConfirmButton: false,
            });
            setTimeout(() => this.fetchUsers(), 1500);
          } else {
            Swal.fire("Error", response.message || "Failed to delete record", "error");
          }
        } catch (error) {
          console.error("Delete record error:", error);
          Swal.fire("Error", "Failed to delete record", "error");
        }
      }
    },
  },
};
</script>

<template>
  <layout-header></layout-header>
  <layout-sidebar></layout-sidebar>

  <div class="page-wrapper">
    <div class="content">
      <!-- Page Header -->
      <div class="page-header d-flex justify-content-between align-items-center">
        <div class="page-title">
          <h4>User List</h4>
          <h6>Manage Your Users</h6>
        </div>
        <!-- <div class="page-btn">
          <a
            href="javascript:void(0);"
            class="btn btn-added"
            data-bs-toggle="modal"
            data-bs-target="#add-user"
          >
            <vue-feather type="plus-circle" class="me-2"></vue-feather>
            Add New User
          </a>
        </div> -->
      </div>

      <!-- Filters -->
      <div class="d-flex mb-3">
        <input
          type="text"
          v-model="filters.fullname"
          class="form-control me-2"
          placeholder="Search by name, mobile or email"
        />
        <select v-model="filters.status" class="form-select w-auto">
          <option value="">All Status</option>
          <option value="2">Active</option>
          <option value="1">Inactive</option>
        </select>
        <button class="btn btn-primary ms-2" @click="clearFilters">Clear</button>
      </div>

      <!-- Users Table -->
      <div class="card table-list-card">
        <div class="card-body">
          <div class="table-responsive">
            <a-table
              :columns="columns"
              :data-source="filteredData"
              :loading="loading"
              rowKey="email"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'fullname'">
                  <div class="userimgname">
                    <div><a href="javascript:void(0);">{{ record.fullname }}</a></div>
                  </div>
                </template>

                <template v-else-if="column.key === 'status'">
                  <span
                    :class="record.status === '2' ? 'badge badge-linesuccess' : 'badge badge-linedanger'"
                  >
                    {{ record.status === '2' ? 'Active' : 'Inactive' }}
                  </span>
                </template>

                <template v-else-if="column.key === 'action'">
                  <div class="edit-delete-action">
                    <!-- <a
                      href="javascript:void(0);"
                      class="me-2 p-2 mb-0"
                      @click="$refs.userModal.edit(record)"
                    >
                      <vue-feather type="edit"></vue-feather>
                    </a> -->

                    <a class="me-2 p-2 mb-0" @click="toggleStatus(record)">
                      <vue-feather type="eye"></vue-feather>
                    </a>

                    <a class="me-2 p-2 mb-0" @click="deleteRecord(record)">
                      <vue-feather type="trash-2"></vue-feather>
                    </a>
                  </div>
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

  <!-- User Modal -->
  <users-list-modal ref="userModal" @refreshUsers="fetchUsers"></users-list-modal>
</template>