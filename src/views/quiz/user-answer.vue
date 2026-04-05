<script>
import { Modal } from "bootstrap";
import { apiService } from "@/services/apiService";

export default {
  data() {
    return {
      loading: false,
      results: [],
      selectedResult: null,
      quizModal: null,
      columns: [
        { title: "User", dataIndex: "user_name", key: "user_name" },
        { title: "Course", dataIndex: "course_title", key: "course_title" },
        { title: "Module", dataIndex: "module_title", key: "module_title" },
        { title: "Quiz", dataIndex: "quiz_title", key: "quiz_title" },
        { title: "Score Marks", key: "score_marks" },
        { title: "Score (%)", dataIndex: "percentage", key: "percentage" },
        { title: "Status", key: "status" },
        { title: "Action", key: "action" }
      ]
    };
  },

  methods: {
    async fetchResults() {
      this.loading = true;
      try {
        const res = await apiService.getAllQuizResults();
        if (res.code === 200) this.results = res.results || [];
      } catch (err) {
        console.error(err);
      } finally {
        this.loading = false;
      }
    },

    async viewResult(record) {
      try {
        console.log("Record received:", record);

        // Map questions to submitted answers
        const details = (record.questions || []).map((q, index) => {
          // Use index+1 as question_id since questions have no id in data
          const questionId = index + 1;
          const userAnsObj = (record.submitted_answers || []).find(
            a => a.question_id === questionId
          );

          const selectedAnswer = userAnsObj ? userAnsObj.selected_answer : null;
          const correctAnswer = q.correct_answer || null;

          let resultType = "Missed";
          if (selectedAnswer !== null) {
            resultType = selectedAnswer === correctAnswer ? "✔️" : "❌";
          }

          console.log(
            `Question ID: ${questionId}, Text: ${q.question}, Selected: ${selectedAnswer}, Correct: ${correctAnswer}, Result: ${resultType}`
          );

          return {
            questions: q.question, // fixed from q.question_text
            selected_answer: selectedAnswer,
            correct_answer: correctAnswer,
            result: resultType,
            is_correct: resultType === "Correct"
          };
        });

        console.log("Mapped details:", details);

        this.selectedResult = {
          ...record,
          details,
          total_score: record.total_score,
          max_score: record.max_score,
          status: record.status
        };

        const modalEl = document.getElementById("quizResultModal");
        this.quizModal = Modal.getInstance(modalEl) || new Modal(modalEl);
        this.quizModal.show();
      } catch (err) {
        console.error("Error in viewResult:", err);
      }
    },

     printResult() {
    const printContent = document.querySelector('#quizResultModal .modal-body');
    const WinPrint = window.open('', '', 'width=900,height=650');
    WinPrint.document.write(`
      <html>
        <head>
          <title>Quiz Result</title>
          <style>
            body { font-family: Arial, sans-serif; padding: 20px; }
            .card { border: 1px solid #ccc; padding: 10px; margin-bottom: 10px; }
            .bg-light-success { background-color: #e6f9ec; }
            .bg-light-danger { background-color: #fdecea; }
            .bg-light-warning { background-color: #fff4e5; }
          </style>
        </head>
        <body>
          ${printContent.innerHTML}
        </body>
      </html>
    `);
    WinPrint.document.close();
    WinPrint.focus();
    WinPrint.print();
    WinPrint.close();
  },

    closeModal() {
      this.quizModal?.hide();
      this.selectedResult = null;
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
      <div class="page-header mb-3">
        <h4>Users Quiz Results</h4>
      </div>

      <div class="card">
        <div class="card-body table-responsive">
          <a-table
            :columns="columns"
            :data-source="results"
            :loading="loading"
            rowKey="id"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'score_marks'">
                {{ record.total_score }} / {{ record.max_score }}
              </template>

              <template v-else-if="column.key === 'status'">
                <span :class="record.status === 'PASS' ? 'text-success fw-bold' : 'text-danger fw-bold'">
                  {{ record.status }}
                </span>
              </template>

              <template v-else-if="column.key === 'action'">
                <button class="btn btn-sm btn-primary" @click.prevent="viewResult(record)">
                  View
                </button>
              </template>

              <template v-else>
                {{ record[column.dataIndex] }}
              </template>
            </template>
          </a-table>
        </div>
      </div>
    </div>
  </div>

  <!-- Quiz Result Modal -->
  <div class="modal fade" id="quizResultModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Quiz Result Details</h5>
          <button type="button" class="btn-close" @click="closeModal"></button>
        </div>

        <div class="modal-body" v-if="selectedResult">
          <p><strong>User/Student:</strong> {{ selectedResult.user_name }}</p>
          <p><strong>Course:</strong> {{ selectedResult.course_title }}</p>
          <p><strong>Module:</strong> {{ selectedResult.module_title }}</p>
          <p><strong>Quiz:</strong> {{ selectedResult.quiz_title }}</p>

          <hr>

          <p><strong>Score Marks:</strong> {{ selectedResult.total_score }} / {{ selectedResult.max_score }}</p>
          <p><strong>Score:</strong> {{ selectedResult.percentage }}%</p>
          <p>
            <strong>Status:</strong>
            <span :class="selectedResult.status === 'PASS' ? 'text-success' : 'text-danger'">
              {{ selectedResult.status }}
            </span>
          </p>

          <hr>

          <div
            v-for="(q, index) in selectedResult.details"
            :key="index"
            class="card mb-2 p-3"
            :class="q.is_correct ? 'bg-light-success' : (q.result === 'Missed' ? 'bg-light-warning' : 'bg-light-danger')"
          >
            <strong>Question {{ index + 1 }}</strong>
            <p class="mt-2"><b>{{ q.questions }}</b></p>
            <p><strong>User Answer:</strong> {{ q.selected_answer || 'No Answer' }}<span :class="q.result === 'Correct' ? 'text-success' : (q.result === 'Missed' ? 'text-warning' : 'text-danger')">
                {{ q.result }}
              </span></p>
            <p><strong>Correct Answer:</strong> {{ q.correct_answer }}</p>
          </div>
        </div>
        <div class="modal-footer">
        <button class="btn btn-primary" @click="printResult">Print</button>
        <button class="btn btn-secondary" @click="closeModal">Close</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style>
.bg-light-success { background-color: #e6f9ec; }
.bg-light-danger { background-color: #fdecea; }
.bg-light-warning { background-color: #fff4e5; }
</style>