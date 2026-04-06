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
        { title: "Course Name", dataIndex: "course_title", key: "course_title" },
        { title: "Total Student Enrolled", dataIndex: "total_students", key: "total_students" },
        { title: "Total Modules", dataIndex: "total_modules", key: "total_modules" },
        { title: "Total Quizess", dataIndex: "total_quizzes", key: "total_quizzes" }
      ]
    };
  },

  computed: {
    filteredReports() {
      const q = this.filters.search.toLowerCase();
      return this.userReports.filter(r =>
        r.total_students.toLowerCase().includes(q) ||
        r.course_title.toLowerCase().includes(q)
      );
    }
  },

  methods: {
    async fetchCourseReports() {
      this.loading = true;
      try {
        const res = await apiService.getCourseReports();

        if (res.code === 200) {
          this.userReports = res.reports.map(r => ({
            id: r.id,
            total_students: r.total_students || "-",
            course_title: r.course_title || "-",
            total_modules: r.total_modules || "-",
            total_quizzes: r.total_quizzes || 0
          }));
        }
      } catch (err) {
        console.error("Error fetching reports:", err);
      } finally {
        this.loading = false;
      }
    },

    getStatus(total_quizzes, score) {
      if (total_quizzes === 100 && score >= 50) return "Completed";
      if (total_quizzes > 0) return "In total_quizzes";
      return "Not Started";
    }
  },

  mounted() {
    this.fetchCourseReports();
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
          <h4>Course Report</h4>
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
                    'badge bg-warning': record.status === 'In total_quizzes',
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