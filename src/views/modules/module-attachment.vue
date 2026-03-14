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

      coursesList: [],    // All courses
      modulesList: [],    // All modules from backend
      attachments: [],

      attachmentForm: {
        course_id: null,
        module_id: null,
        title: "",
        attachment_type: "document",
        file: null,
        file_preview: null,
        external_url: "",
        description: ""
      },

      columns: [
        { title: "ID", dataIndex: "id", key: "id" },
        { title: "Course", dataIndex: "course_title", key: "course_title" },
        { title: "Module", dataIndex: "module_title", key: "module_title" },
        { title: "Title", dataIndex: "title", key: "title" },
        { title: "File / Link", key: "file_url" },
        { title: "Created On", dataIndex: "created_at", key: "created_at" },
        { title: "Action", key: "action" }
      ]
    };
  },

  computed: {
    filteredAttachments() {
      const q = this.filters.search.toLowerCase();
      return this.attachments.filter(a => a.title.toLowerCase().includes(q));
    },

    // Filter modules by selected course
    filteredModules() {
      if (!this.attachmentForm.course_id) return [];
      return this.modulesList.filter(
        m => m.course_id === this.attachmentForm.course_id
      );
    }
  },

  watch: {
    "attachmentForm.attachment_type"(newType) {
      if (newType === "link") {
        this.attachmentForm.file = null;
        this.attachmentForm.file_preview = null;
      } else {
        this.attachmentForm.external_url = "";
      }
    },

    // Reset module selection when course changes
    "attachmentForm.course_id"(newCourseId) {
      this.attachmentForm.module_id = null;
      // Optionally auto-select first module:
      const modules = this.modulesList.filter(m => m.course_id === newCourseId);
      if (modules.length) this.attachmentForm.module_id = modules[0].id;
    }
  },

  methods: {
    // Fetch all courses
    async fetchCourses() {
      try {
        const res = await apiService.getCourses();
        if (res.code === 200) this.coursesList = res.courses;
      } catch (err) {
        console.error(err);
      }
    },

    // Fetch all modules (all courses)
    async fetchModules() {
      try {
        const res = await apiService.getModules(); // Returns all modules
        if (res.code === 200) this.modulesList = res.modules;
      } catch (err) {
        console.error(err);
      }
    },

    // Fetch attachments
    async fetchAttachments() {
      this.loading = true;
      try {
        const res = await apiService.getModuleAttachments();
        if (res.code === 200) {
          this.attachments = res.attachments.map(a => ({
            ...a,
            module_title: a.module_title || "-",
            course_title: a.course_title || "-"
          }));
        }
      } catch (err) {
        console.error(err);
      } finally {
        this.loading = false;
      }
    },

    addAttachment() {
      this.editingId = null;
      this.attachmentForm = {
        course_id: null,
        module_id: null,
        title: "",
        attachment_type: "document",
        file: null,
        file_preview: null,
        external_url: "",
        description: ""
      };
      const modalEl = document.getElementById("attachmentModal");
      const modal = Modal.getInstance(modalEl) || new Modal(modalEl);
      modal.show();
    },

    editAttachment(record) {
      this.editingId = record.id;
      this.attachmentForm.course_id = record.course_id || null;
      this.attachmentForm.module_id = record.module_id || null;
      this.attachmentForm.title = record.title;
      this.attachmentForm.attachment_type = record.attachment_type;
      this.attachmentForm.description = record.description;

      if (record.attachment_type === "link") {
        this.attachmentForm.external_url = record.external_url || "";
        this.attachmentForm.file = null;
        this.attachmentForm.file_preview = null;
      } else {
        this.attachmentForm.file_preview = record.file_url || null;
        this.attachmentForm.file = null;
        this.attachmentForm.external_url = "";
      }

      const modalEl = document.getElementById("attachmentModal");
      const modal = Modal.getInstance(modalEl) || new Modal(modalEl);
      modal.show();
    },

    onFileChange(event) {
      const file = event.target.files[0];
      if (file) {
        this.attachmentForm.file = file;
        this.attachmentForm.file_preview = file.name;
      }
    },

    async saveAttachment() {
      if (
        !this.attachmentForm.course_id ||
        !this.attachmentForm.module_id ||
        !this.attachmentForm.title ||
        !this.attachmentForm.attachment_type
      ) {
        Swal.fire("Validation", "Please fill all required fields", "warning");
        return;
      }

      this.saving = true;

      try {
        const payload = {
          course_id: this.attachmentForm.course_id,
          module_id: this.attachmentForm.module_id,
          title: this.attachmentForm.title,
          attachment_type: this.attachmentForm.attachment_type,
          description: this.attachmentForm.description,
          external_url:
            this.attachmentForm.attachment_type === "link"
              ? this.attachmentForm.external_url
              : null
        };

        if (this.attachmentForm.file) payload.file = this.attachmentForm.file;

        let response;
        if (this.editingId) {
          payload.id = this.editingId;
          response = await apiService.updateModuleAttachment(payload);
        } else {
          response = await apiService.saveModuleAttachment(payload);
        }

        if (response.code === 200) {
          Swal.fire(
            "Success",
            this.editingId ? "Attachment updated!" : "Attachment created!",
            "success"
          );

          this.editingId = null;
          this.attachmentForm = {
            course_id: null,
            module_id: null,
            title: "",
            attachment_type: "document",
            file: null,
            file_preview: null,
            external_url: "",
            description: ""
          };

          this.fetchAttachments();
          const modalEl = document.getElementById("attachmentModal");
          Modal.getInstance(modalEl)?.hide();
        } else {
          Swal.fire("Error", response.message || "Failed to save attachment", "error");
        }
      } catch (err) {
        console.error("Save attachment error:", err);
        Swal.fire("Error", "Failed to save attachment", "error");
      } finally {
        this.saving = false;
      }
    },

    async deleteAttachment(record) {
      const result = await Swal.fire({
        title: "Are you sure?",
        text: "This action cannot be undone!",
        icon: "warning",
        showCancelButton: true
      });
      if (!result.isConfirmed) return;

      try {
        const res = await apiService.deleteModuleAttachment(record.id);
        if (res.code === 200) {
          Swal.fire("Deleted", "Attachment has been deleted", "success");
          this.fetchAttachments();
        }
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "Failed to delete attachment", "error");
      }
    }
  },

  mounted() {
    this.fetchCourses();
    this.fetchModules();
    this.fetchAttachments();
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
          <h4>Module Attachments</h4>
          <h6>Manage learning materials</h6>
        </div>
        <button class="btn btn-added" @click="addAttachment">
          <vue-feather type="plus-circle" class="me-2" /> Add Attachment
        </button>
      </div>

      <!-- Search -->
      <div class="d-flex mb-3">
        <input
          type="text"
          v-model="filters.search"
          class="form-control me-2"
          placeholder="Search by title"
        />
        <button class="btn btn-primary ms-2" @click="filters.search=''">Clear</button>
      </div>

      <!-- Attachments Table -->
      <div class="card table-list-card">
        <div class="card-body table-responsive">
          <a-table
            :columns="columns"
            :data-source="filteredAttachments"
            :loading="loading"
            rowKey="id"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'action'">
                <div class="edit-delete-action">
                  <a @click="editAttachment(record)" class="me-2"><vue-feather type="edit-2" /></a>
                  <a @click="deleteAttachment(record)"><vue-feather type="trash-2" /></a>
                </div>
              </template>

              <template v-else-if="column.key === 'file_url'">
                <a
                  v-if="record.file_url || record.external_url"
                  :href="record.file_url || record.external_url"
                  target="_blank"
                >
                  Open
                </a>
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

  <!-- Add/Edit Modal -->
  <div class="modal fade" id="attachmentModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">{{ editingId ? "Edit Attachment" : "Add Attachment" }}</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">

          <!-- Course -->
          <div class="mb-3">
            <label class="form-label">Course</label>
            <select v-model="attachmentForm.course_id" class="form-select">
              <option disabled value="">Select Course</option>
              <option v-for="c in coursesList" :key="c.id" :value="c.id">{{ c.title }}</option>
            </select>
          </div>

          <!-- Module (filtered by course) -->
          <div class="mb-3">
            <label class="form-label">Module</label>
            <select v-model="attachmentForm.module_id" class="form-select">
              <option disabled value="">Select Module</option>
              <option v-for="m in filteredModules" :key="m.id" :value="m.id">{{ m.title }}</option>
            </select>
          </div>

          <!-- Title -->
          <div class="mb-3">
            <label class="form-label">Attachment Title</label>
            <input type="text" v-model="attachmentForm.title" class="form-control" />
          </div>

          <!-- Type -->
          <div class="mb-3">
            <label class="form-label">Attachment Type</label>
            <select v-model="attachmentForm.attachment_type" class="form-select">
              <option value="document">Document</option>
              <option value="audio">Audio</option>
              <option value="video">Video</option>
              <option value="link">External Link</option>
            </select>
          </div>

          <!-- File -->
          <div v-if="attachmentForm.attachment_type !== 'link'" class="mb-3">
            <label class="form-label">Upload File</label>
            <input type="file" @change="onFileChange" class="form-control" />
            <div v-if="attachmentForm.file_preview" class="mt-2">
              <span class="text-muted">Current: </span>
              <a
                v-if="attachmentForm.file_preview.startsWith('http')"
                :href="attachmentForm.file_preview"
                target="_blank"
              >View File</a>
              <span v-else>{{ attachmentForm.file_preview }}</span>
            </div>
          </div>

          <!-- External URL -->
          <div v-if="attachmentForm.attachment_type === 'link'" class="mb-3">
            <label class="form-label">External URL</label>
            <input type="text" v-model="attachmentForm.external_url" class="form-control" />
          </div>

          <!-- Description -->
          <div class="mb-3">
            <label class="form-label">Description</label>
            <textarea v-model="attachmentForm.description" class="form-control"></textarea>
          </div>

        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" :disabled="saving" @click="saveAttachment">
            {{ saving ? "Saving..." : (editingId ? "Update Attachment" : "Save Attachment") }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>