<script>
import { apiService } from "@/services/apiService";

export default {
  data() {
    return {
      loading: false,
      filters: { search: "" },

      userReports: [],

      columns: [
        { title: "ID", dataIndex: "id", key: "id" },
        { title: "Student Name", dataIndex: "student_name", key: "student_name" },
        { title: "Course Enrolled", dataIndex: "course_title", key: "course_title" },
        { title: "Module", dataIndex: "module_title", key: "module_title" },
        { title: "Progress (%)", dataIndex: "progress", key: "progress" },
        { title: "Score", dataIndex: "score", key: "score" },
        { title: "Status", dataIndex: "status", key: "status" },
        { title: "Last Activity", dataIndex: "last_activity", key: "last_activity" }
      ]
    };
  },

  computed: {
    filteredReports() {
      const q = this.filters.search.toLowerCase();
      return this.userReports.filter(r =>
        r.student_name.toLowerCase().includes(q) ||
        r.course_title.toLowerCase().includes(q)
      );
    }
  },

  methods: {
    async fetchUserReports() {
      this.loading = true;
      try {
        const res = await apiService.getUserReports();

        if (res.code === 200) {
          this.userReports = res.reports.map(r => ({
            id: r.id,
            student_name: r.student_name || "-",
            course_title: r.course_title || "-",
            module_title: r.module_title || "-",
            progress: r.progress || 0,
            score: r.score || 0,
            status: this.getStatus(r.progress, r.score),
            last_activity: r.last_activity || "-"
          }));
        }
      } catch (err) {
        console.error("Error fetching reports:", err);
      } finally {
        this.loading = false;
      }
    },

    getStatus(progress, score) {
      if (progress === 100 && score >= 50) return "Completed";
      if (progress > 0) return "In Progress";
      return "Not Started";
    }
  },

  mounted() {
    this.fetchUserReports();
  }
};
</script>

<template>
  <layout-header></layout-header>
  <layout-sidebar></layout-sidebar>

  <div class="page-wrapper">
    <div class="content">
      <div class="page-header d-flex justify-content-between align-items-center mb-3">
        <div class="page-title">
          <h4>User Report</h4>
        </div>
      </div>

      <!-- Search -->
      <div class="d-flex mb-3">
        <input
          type="text"
          v-model="filters.search"
          class="form-control me-2"
          placeholder="Search by student or course"
        />
        <button class="btn btn-primary ms-2" @click="filters.search=''">
          Clear
        </button>
      </div>

      <!-- Report Table -->
      <div class="card table-list-card">
        <div class="card-body table-responsive">
          <a-table
            :columns="columns"
            :data-source="filteredReports"
            :loading="loading"
            rowKey="id"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'status'">
                <span
                  :class="{
                    'badge bg-success': record.status === 'Completed',
                    'badge bg-warning': record.status === 'In Progress',
                    'badge bg-secondary': record.status === 'Not Started'
                  }"
                >
                  {{ record.status }}
                </span>
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
</template>