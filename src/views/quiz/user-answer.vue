<script>
import { apiService } from "@/services/apiService";

export default {
  data() {
    return {
      loading: false,
      results: [],
      selectedResult: null,
      showModal: false,

      columns: [
        { title: "User", dataIndex: "user_name", key: "user_name" },
        { title: "Course", dataIndex: "course_title", key: "course_title" },
        { title: "Module", dataIndex: "module_title", key: "module_title" },
        { title: "Quiz", dataIndex: "quiz_title", key: "quiz_title" },
        { title: "Score", dataIndex: "score", key: "score" },
        { title: "Status", dataIndex: "status", key: "status" },
        { title: "Action", key: "action" }
      ]
    };
  },

  methods: {
    // ✅ Fetch all quiz submissions
    async fetchResults() {
      this.loading = true;
      try {
        const res = await apiService.getAllQuizResults();

        if (res.code === 200) {
          this.results = res.results;
        }
      } catch (err) {
        console.error("Error fetching results:", err);
      } finally {
        this.loading = false;
      }
    },

    // ✅ View detailed result (calls marking API)
    async viewResult(record) {
      try {
        const res = await apiService.getQuizResult({
          user_id: record.user_id,
          module_id: record.module_id,
          quiz_id: record.quiz_id
        });

        this.selectedResult = {
          ...record,
          details: res.details,
          total_score: res.total_score,
          max_score: res.max_score,
          status: res.status
        };

        this.showModal = true;
      } catch (err) {
        console.error("Error fetching quiz detail:", err);
      }
    }
  },

  mounted() {
    this.fetchResults();
  }
};
</script>

<template>
  <layout-header></layout-header>
  <layout-sidebar></layout-sidebar>

  <div class="page-wrapper">
    <div class="content">

      <!-- HEADER -->
      <div class="page-header mb-3">
        <div class="page-title">
          <h4>Users Quiz Results</h4>
        </div>
      </div>

      <!-- TABLE -->
      <div class="card">
        <div class="card-body table-responsive">

          <a-table
            :columns="columns"
            :data-source="results"
            :loading="loading"
            rowKey="id"
          >

            <template #bodyCell="{ column, record }">

              <!-- STATUS -->
              <template v-if="column.key === 'status'">
                <span :class="record.status === 'PASS' ? 'text-success' : 'text-danger'">
                  {{ record.status }}
                </span>
              </template>

              <!-- ACTION -->
              <template v-else-if="column.key === 'action'">
                <button class="btn btn-sm btn-primary" @click="viewResult(record)">
                  View
                </button>
              </template>

              <!-- DEFAULT -->
              <template v-else>
                <span>{{ record[column.dataIndex] }}</span>
              </template>

            </template>

          </a-table>

        </div>
      </div>

    </div>
  </div>

  <!-- ===================== -->
  <!-- RESULT MODAL -->
  <!-- ===================== -->
  <div v-if="showModal" class="modal fade show d-block">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">

        <!-- HEADER -->
        <div class="modal-header">
          <h5 class="modal-title">Quiz Result</h5>
          <button class="btn-close" @click="showModal = false"></button>
        </div>

        <!-- BODY -->
        <div class="modal-body" v-if="selectedResult">

          <p><strong>User:</strong> {{ selectedResult.user_name }}</p>
          <p><strong>Course:</strong> {{ selectedResult.course_title }}</p>
          <p><strong>Module:</strong> {{ selectedResult.module_title }}</p>
          <p><strong>Quiz:</strong> {{ selectedResult.quiz_title }}</p>

          <hr>

          <p>
            <strong>Score:</strong>
            {{ selectedResult.total_score }} / {{ selectedResult.max_score }}
          </p>

          <p>
            <strong>Status:</strong>
            <span :class="selectedResult.status === 'PASS' ? 'text-success' : 'text-danger'">
              {{ selectedResult.status }}
            </span>
          </p>

          <hr>

          <!-- QUESTIONS -->
          <div
            v-for="(q, index) in selectedResult.details"
            :key="index"
            class="card mb-2 p-2"
            :class="q.is_correct ? 'bg-light-success' : 'bg-light-danger'"
          >
            <strong>Question {{ index + 1 }}</strong>

            <p>{{ q.question }}</p>

            <p><strong>Your:</strong> {{ q.user_answer }}</p>
            <p><strong>Correct:</strong> {{ q.correct_answer }}</p>

          </div>

        </div>

      </div>
    </div>
  </div>
</template>

<style>
.modal {
  background: rgba(0, 0, 0, 0.5);
}

.bg-light-success {
  background-color: #e6f9ec;
}

.bg-light-danger {
  background-color: #fdecea;
}
</style>