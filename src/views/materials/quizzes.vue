<script>
import { Modal } from "bootstrap";
import { apiService } from "@/services/apiService";
import Swal from "sweetalert2";

export default {
  data() {
    return {
      loading: false,
      saving: false,
      editingId: null,
      filters: { search: "" },

      coursesList: [],
      modulesList: [],
      quizzes: [],

      // ✅ FIXED (moved outside)
      viewingQuiz: null,
      userAnswers: {},

      quizForm: {
        course_id: null,
        module_id: null,
        title: "",
        questions: [
          {
            question: "",
            options: ["", "", "", ""],
            correct_answer: "",
            score: 1
          }
        ]
      },

      columns: [
        { title: "ID", dataIndex: "id" },
        { title: "Course", dataIndex: "course_name" },
        { title: "Module", dataIndex: "module_name" },
        { title: "Title", dataIndex: "title" },
        { title: "Questions", dataIndex: "questions" },
        { title: "Created At", dataIndex: "created_at" },
        { title: "Action", key: "action" }
      ]
    };
  },

  computed: {
    filteredQuizzes() {
      const q = this.filters.search.toLowerCase();
      return this.quizzes.filter(a => a.title.toLowerCase().includes(q));
    },

    filteredModules() {
      if (!this.quizForm.course_id) return [];
      return this.modulesList.filter(m => m.course_id === this.quizForm.course_id);
    }
  },

  watch: {
    "quizForm.course_id"(newCourseId) {
      this.quizForm.module_id = null;
      const modules = this.modulesList.filter(m => m.course_id === newCourseId);
      if (modules.length) this.quizForm.module_id = modules[0].id;
    }
  },

  methods: {
    async fetchCourses() {
      try {
        const res = await apiService.getCourses();
        if (res.code === 200) this.coursesList = res.courses;
      } catch (err) { console.error(err); }
    },

    async fetchModules() {
      try {
        const res = await apiService.getModules();
        if (res.code === 200) this.modulesList = res.modules;
      } catch (err) { console.error(err); }
    },

    async fetchQuizzes() {
      this.loading = true;
      try {
        const res = await apiService.getQuizzes();
        if (res.code === 200) {
          this.quizzes = res.quizzes.map(q => ({
            ...q,
            // ✅ ensure questions is ARRAY
            questions: typeof q.questions === "string"
              ? JSON.parse(q.questions)
              : q.questions,
            module_title: q.module_title || "-",
            course_title: q.course_title || "-"
          }));
        }
      } catch (err) { console.error(err); }
      finally { this.loading = false; }
    },

    addQuiz() {
      this.editingId = null;
      this.quizForm = {
        course_id: null,
        module_id: null,
        title: "",
        questions: [
          { question: "", options: ["", "", "", ""], correct_answer: "", score: 1 }
        ]
      };
      new Modal(document.getElementById("quizModal")).show();
    },

    editQuiz(record) {
      this.editingId = record.id;
      this.quizForm = {
        course_id: record.course_id,
        module_id: record.module_id,
        title: record.title,
        questions: record.questions.length
          ? record.questions
          : [{ question: "", options: ["", "", "", ""], correct_answer: "", score: 1 }]
      };
      new Modal(document.getElementById("quizModal")).show();
    },

    // ✅ FIXED VIEW
    viewQuiz(record) {
      this.viewingQuiz = {
        ...record,
        questions: typeof record.questions === "string"
          ? JSON.parse(record.questions)
          : record.questions
      };

      this.userAnswers = {};
      new Modal(document.getElementById("viewQuizModal")).show();
    },

    addQuestion() {
      this.quizForm.questions.push({
        question: "",
        options: ["", "", "", ""],
        correct_answer: "",
        score: 1
      });
    },

    formatQuestions(questions) {
      if (!questions) return "";
      return questions
        .map((q, i) => `${i + 1}. ${q.question} (Answer: ${q.correct_answer})`)
        .join("<br/>");
    },

    removeQuestion(index) {
      this.quizForm.questions.splice(index, 1);
    },

    addOption(qIndex) {
      this.quizForm.questions[qIndex].options.push("");
    },

    removeOption(qIndex, oIndex) {
      this.quizForm.questions[qIndex].options.splice(oIndex, 1);
    },

    async saveQuiz() {
      if (!this.quizForm.course_id || !this.quizForm.module_id || !this.quizForm.title.trim()) {
        Swal.fire("Validation", "Fill all required fields", "warning");
        return;
      }

      for (let q of this.quizForm.questions) {
        if (!q.question.trim() || q.options.some(o => !o.trim()) || !q.correct_answer.trim()) {
          Swal.fire("Validation", "Complete all questions properly", "warning");
          return;
        }
      }

      this.saving = true;
      try {
        const payload = {
          ...this.quizForm,
          questions: this.quizForm.questions
        };

        let response = this.editingId
          ? await apiService.updateQuiz({ ...payload, id: this.editingId })
          : await apiService.saveQuiz(payload);

        if (response.code === 200) {
          Swal.fire("Success", "Quiz saved!", "success");
          this.fetchQuizzes();
          Modal.getInstance(document.getElementById("quizModal"))?.hide();
        }
      } catch (err) {
        Swal.fire("Error", "Failed to save quiz", "error");
      } finally {
        this.saving = false;
      }
    },

    async deleteQuiz(record) {
      const result = await Swal.fire({
        title: "Are you sure you want to remove this quiz?",
        icon: "warning",
        showCancelButton: true
      });

      if (!result.isConfirmed) return;

      try {
        const res = await apiService.deleteQuiz(record.id);
        if (res.code === 200) {
          Swal.fire("Deleted", "Quiz deleted", "success");
          this.fetchQuizzes();
        }
      } catch {
        Swal.fire("Error", "Delete failed", "error");
      }
    }
  },

  mounted() {
    this.fetchCourses();
    this.fetchModules();
    this.fetchQuizzes();
  }
};
</script>
<template>
  <layout-header />
  <layout-sidebar />

  <div class="page-wrapper">
    <div class="content">
      <div class="d-flex justify-content-between mb-3">
        <h4>Quiz Management</h4>
        <button class="btn btn-primary" @click="addQuiz">+ Add Quiz</button>
      </div>

      <input v-model="filters.search" class="form-control mb-3" placeholder="Search..." />

      <a-table :columns="columns" :data-source="filteredQuizzes" :loading="loading" rowKey="id"  :scroll="{ x: 'max-content' }"
>
       <template #bodyCell="{ column, record }">
  <!-- Total Questions -->
  <template v-if="column.key === 'questions_count'">
    {{ record.questions ? record.questions.length : 0 }}
  </template>

  <!-- Questions (break line) -->
  <template v-else-if="column.dataIndex === 'questions'">
    <span v-html="formatQuestions(record.questions)"></span>
  </template>

  <!-- Action -->
  <template v-else-if="column.key === 'action'">
  <div class="edit-delete-action">
  <a
  href="javascript:void(0);"
  class="me-2 p-2 mb-0"
  @click="editQuiz(record)"
  >
  <vue-feather type="edit"></vue-feather>
  </a>
  <a class="me-2 p-2 mb-0" @click="deleteQuiz(record)">
  <vue-feather type="trash-2"></vue-feather>
  </a>
  <a class="me-2 p-2 mb-0" @click="viewQuiz(record)">
  <vue-feather type="eye"></vue-feather>
  </a>
  </div>
  </template>
  <!-- Default -->
  <template v-else>
    {{ record[column.dataIndex] }}
  </template>
</template>
      </a-table>
    </div>
  </div>

  <!-- QUIZ MODAL -->
  <div class="modal fade" id="quizModal">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">

        <div class="modal-header">
          <h5>{{ editingId ? "Edit Quiz" : "Add Quiz" }}</h5>
        </div>

        <div class="modal-body">
        <label class="me-2">Select Course</label>
          <select v-model="quizForm.course_id" class="form-control mb-2">
            <option disabled value="">Select Course</option>
            <option v-for="c in coursesList" :key="c.id" :value="c.id">{{ c.title }}</option>
          </select>
            <label class="me-2">Select Module</label>
          <select v-model="quizForm.module_id" class="form-control mb-2">
            <option disabled value="">Select Module</option>
            <option v-for="m in filteredModules" :key="m.id" :value="m.id">{{ m.title }}</option>
          </select>

          <input v-model="quizForm.title" class="form-control mb-2" placeholder="Quiz Title" />

          <!-- QUESTIONS -->
          <div v-for="(q, qIndex) in quizForm.questions" :key="qIndex" class="card p-3 mb-3">
            <input v-model="q.question" class="form-control mb-2" placeholder="Question" />

            <div v-for="(opt, oIndex) in q.options" :key="oIndex" class="d-flex mb-2">
              <input v-model="q.options[oIndex]" class="form-control me-2" />
              <button @click="removeOption(qIndex, oIndex)" class="btn btn-sm btn-danger">X</button>
            </div>

            <div class="d-flex mb-2 align-items-center">
              <label class="me-2">Correct Answer:</label>
              <input v-model="q.correct_answer" class="form-control w-50" placeholder="Type correct answer" />
            </div>

            <div class="d-flex mb-2 align-items-center">
              <label class="me-2">Marks:</label>
              <input type="number" min="1" v-model.number="q.score" class="form-control w-25" />
            </div>

            <button @click="addOption(qIndex)" class="btn btn-sm btn-secondary me-2">+ Option</button>
            <button @click="removeQuestion(qIndex)" class="btn btn-sm btn-danger">Remove Question</button>
          </div>

          <button @click="addQuestion" class="btn btn-secondary">+ Add Question</button>

        </div>

        <div class="modal-footer">
          <button @click="saveQuiz" class="btn btn-success" :disabled="saving">
            {{ saving ? "Saving..." : "Save Quiz" }}
          </button>
        </div>

      </div>
    </div>
  </div>
  <!-- VIEW QUIZ MODAL -->
<!-- VIEW QUIZ MODAL -->
<div class="modal fade" id="viewQuizModal">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">

      <div class="modal-header">
        <h5 v-if="viewingQuiz">{{ viewingQuiz.title }}</h5>
      </div>

      <div class="modal-body">
        <div v-if="viewingQuiz && viewingQuiz.questions && viewingQuiz.questions.length">

          <div v-for="(q, qIndex) in viewingQuiz.questions" :key="qIndex" class="mb-3">
            <strong>{{ qIndex + 1 }}. {{ q.question }}</strong>

            <div v-for="(opt, oIndex) in q.options" :key="oIndex">
              <label>
                <input
                  type="radio"
                  :name="'q_' + qIndex"
                  :value="opt"
                  v-model="userAnswers[qIndex]"
                />
                {{ opt }}
              </label>
            </div>
          </div>

        </div>

        <div v-else>
          No questions found
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </div>

    </div>
  </div>
</div>
</template>