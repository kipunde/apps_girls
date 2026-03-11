<template>
  <layout-header></layout-header>
  <layout-sidebar></layout-sidebar>

  <div class="page-wrapper">
    <div class="content">
      <!-- Page Header -->
      <div class="page-header d-flex justify-content-between align-items-center">
        <div class="page-title">
          <h4>User List</h4>
          <h6>Manage Your Users .....</h6>
        </div>
        <div class="page-btn">
          <a
            href="javascript:void(0);"
            class="btn btn-added"
            data-bs-toggle="modal"
            data-bs-target="#add-units"
          >
            <vue-feather type="plus-circle" class="me-2"></vue-feather>
            Add New User
          </a>
        </div>
      </div>

      <!-- Users Table -->
      <div class="card table-list-card">
        <div class="card-body">
          <div class="table-responsive">
            <a-table
              :columns="columns"
              :data-source="data"
              :loading="loading"
              rowKey="email"
            >
              <template #bodyCell="{ column, record }">
                <!-- USER NAME -->
                <template v-if="column.key === 'fullname'">
                  <div class="userimgname">
                    <a href="javascript:void(0);" class="userslist-img bg-img">
                      <img
                        :src="record.profile_pic ? `/assets/img/users/${record.profile_pic}` : '/assets/img/user.png'"
                        alt="user"
                      />
                    </a>
                    <div>
                      <a href="javascript:void(0);">{{ record.fullname }}</a>
                    </div>
                  </div>
                </template>

                <!-- STATUS -->
                <template v-else-if="column.key === 'status'">
                  <span :class="record.Class">{{ record.statusText }}</span>
                </template>

                <!-- ACTION -->
                <template v-else-if="column.key === 'action'">
                  <div class="edit-delete-action">
                    <a class="me-2 p-2 mb-0"><vue-feather type="eye"></vue-feather></a>
                    <a class="me-2 p-2 mb-0"><vue-feather type="edit"></vue-feather></a>
                    <a class="me-2 p-2 mb-0"><vue-feather type="trash-2"></vue-feather></a>
                  </div>
                </template>

                <!-- DEFAULT DISPLAY -->
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

  <users-list-modal></users-list-modal>
</template>

<script>
import { apiService } from "@/services/apiService";

export default {
  data() {
    return {
      loading: false,
      data: [],
      columns: [
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

  methods: {
    async fetchUsers() {
      this.loading = true;
      try {
        const response = await apiService.getAllUsers();
        if (response.code === 200) {
          this.data = response.users.map((user) => {
            let statusText = "";
            let badgeClass = "";

            switch (user.status) {
              case "1":
                statusText = "Pending Approval";
                badgeClass = "badge badge-linewarning";
                break;
              case "2":
                statusText = "Active";
                badgeClass = "badge badge-linesuccess";
                break;
              case "5":
                statusText = "Blocked";
                badgeClass = "badge badge-linedanger";
                break;
              default:
                statusText = "Inactive";
                badgeClass = "badge badge-linedanger";
            }

            return {
              fullname: user.fullname,
              mobile: user.mobile,
              email: user.email,
              profile_pic: user.profile_pic,
              location: user.location,
              role: user.role,
              created_at: user.created_at,
              statusText: statusText,
              Class: badgeClass,
            };
          });
        } else {
          console.error(response.message);
        }
      } catch (error) {
        console.error("Error loading users:", error);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>