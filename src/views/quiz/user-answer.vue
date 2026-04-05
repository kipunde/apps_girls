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

        // ✅ FIXED SCORE MARKS
        { title: "Score Marks", key: "score_marks" },

        { title: "Score (%)", dataIndex: "percentage", key: "percentage" },
        { title: "Status", key: "status" },
        { title: "Action", key: "action" }
      ]
    };
  },

  methods: {
    // ✅ Fetch results
    async fetchResults() {
      this.loading = true;
      try {
        const res = await apiService.getAllQuizResults();
        console.log("Results:", res);

        if (res.code === 200) {
          this.results = res.results || [];
        }
      } catch (err) {
        console.error("Error fetching results:", err);
      } finally {
        this.loading = false;
      }
    },

    // ✅ View detailed result
    async viewResult(record) {
      try {
        const res = await apiService.getQuizResult({
          user_id: record.user_id,
          module_id: record.module_id,
          quiz_id: record.quiz_id
        });

        this.selectedResult = {
          ...record,
          details: res.details || [],
          total_score: res.total_score ?? record.total_score,
          max_score: res.max_score ?? record.max_score,
          status: res.status || record.status
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
  <layout-header />
  <layout-sidebar />

  <div class="page-wrapper">
    <div class="content">

      <!-- HEADER -->
      <div class="page-header mb-3">
        <h4>Users Quiz Results</h4>
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

              <!-- SCORE MARKS -->
              <template v-if="column.key === 'score_marks'">
                {{ record.total_score }} / {{ record.max_score }}
              </template>

              <!-- STATUS -->
              <template v-else-if="column.key === 'status'">
                <span
                  :class="record.status === 'PASS'
                    ? 'text-success fw-bold'
                    : 'text-danger fw-bold'"
                >
                  {{ record.status }}
                </span>
              </template>

              <!-- ACTION -->
              <template v-else-if="column.key === 'action'">
                <button
                  class="btn btn-sm btn-primary"
                  @click="viewResult(record)"
                >
                  View
                </button>
              </template>

              <!-- DEFAULT -->
              <template v-else>
                {{ record[column.dataIndex] }}
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
          <h5 class="modal-title">Quiz Result Details</h5>
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
            {{ selectedResult.total_score }} /
            {{ selectedResult.max_score }}
          </p>

          <p>
            <strong>Status:</strong>
            <span
              :class="selectedResult.status === 'PASS'
                ? 'text-success'
                : 'text-danger'"
            >
              {{ selectedResult.status }}
            </span>
          </p>

          <hr>

          <!-- QUESTIONS + ANSWERS -->
          <div
            v-for="(q, index) in selectedResult.details"
            :key="index"
            class="card mb-2 p-3"
            :class="q.is_correct
              ? 'bg-light-success'
              : 'bg-light-danger'"
          >
            <strong>Question {{ index + 1 }}</strong>

            <p class="mt-2">{{ q.question }}</p>

            <p>
              <strong>Your Answer:</strong>
              {{ q.user_answer || 'No Answer' }}
            </p>

            <p>
              <strong>Correct Answer:</strong>
              {{ q.correct_answer }}
            </p>

            <p>
              <strong>Result:</strong>
              <span :class="q.is_correct ? 'text-success' : 'text-danger'">
                {{ q.is_correct ? 'Correct' : 'Wrong' }}
              </span>
            </p>
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