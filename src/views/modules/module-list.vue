<script>
import { Modal } from "bootstrap";
import { apiService } from "@/services/apiService";
import Swal from "sweetalert2";

export default {
  data() {
    return {
      loading: false,
      filters: { search: "" },
      modules: [],
      coursesList: [],
      moduleForm: {
        course_id: null,
        title: "",
        short_detail: "",
        document: null,
        document_preview: null,
        audio_link: "",
        video_link: "",
        audio_preview: null,   // ✅ added
        video_preview: null,   // ✅ added
      },
      saving: false,
      editingModuleId: null,
      columns: [
        { title: "ID", dataIndex: "id", key: "id" },
        { title: "Title", dataIndex: "title", key: "title" },
        { title: "Course", dataIndex: "course_title", key: "course_title" },
        { title: "Short Detail", dataIndex: "short_detail", key: "short_detail" },
        { title: "Document", dataIndex: "document_path", key: "document" },
        { title: "Audio Link", dataIndex: "audio_link", key: "audio_link" },
        { title: "Video Link", dataIndex: "video_link", key: "video_link" },
        { title: "Created On", dataIndex: "created_at", key: "created_at" },
        { title: "Action", key: "action" },
      ],
    };
  },

  computed: {
    filteredModules() {
      const query = this.filters.search.toLowerCase();
      return this.modules.filter(
        (m) =>
          m.title.toLowerCase().includes(query) ||
          m.short_detail.toLowerCase().includes(query)
      );
    },
  },

  methods: {
    async fetchModules() {
      this.loading = true;
      try {
        const res = await apiService.getModules();
        if (res.code === 200) {
          this.modules = res.modules.map((m) => ({
            ...m,
            course_title: m.course_title || "-",
          }));
        }
      } catch (err) {
        console.error("Error loading modules:", err);
      } finally {
        this.loading = false;
      }
    },

    async fetchCoursesList() {
      try {
        const res = await apiService.getCourses();
        if (res.code === 200) {
          this.coursesList = res.courses.map((c) => ({
            id: c.id,
            title: c.title,
          }));
        }
      } catch (err) {
        console.error("Error fetching courses:", err);
      }
    },

    clearFilters() {
      this.filters.search = "";
    },

    onDocumentChange(event) {
      const file = event.target.files[0];
      if (file) {
        this.moduleForm.document = file;
        this.moduleForm.document_preview = file.name;
      } else {
        this.moduleForm.document = null;
        this.moduleForm.document_preview = null;
      }
    },

    // ✅ FIXED (audio correct)
    onAudioChange(event) {
      const file = event.target.files[0];
      if (file) {
        this.moduleForm.audio_link = file;
        this.moduleForm.audio_preview = file.name;
      } else {
        this.moduleForm.audio_link = null;
        this.moduleForm.audio_preview = null;
      }
    },

    // ✅ FIXED (was wrongly using audio_link)
    onVideoChange(event) {
      const file = event.target.files[0];
      if (file) {
        this.moduleForm.video_link = file;
        this.moduleForm.video_preview = file.name;
      } else {
        this.moduleForm.video_link = null;
        this.moduleForm.video_preview = null;
      }
    },

    addModule() {
      this.editingModuleId = null;
      this.moduleForm = {
        course_id: null,
        title: "",
        short_detail: "",
        document: null,
        document_preview: null,
        audio_preview: null,   // ✅ added
        video_preview: null,   // ✅ added
        audio_link: null,
        video_link: null,
      };
      const modalEl = document.getElementById("moduleModal");
      const modalInstance = Modal.getInstance(modalEl) || new Modal(modalEl);
      modalInstance.show();
    },

    editModule(module) {
      this.editingModuleId = module.id;
      this.moduleForm.course_id = module.course_id;
      this.moduleForm.title = module.title;
      this.moduleForm.short_detail = module.short_detail;
      this.moduleForm.document = null;
      this.moduleForm.document_preview = module.document_path;
      this.moduleForm.audio_link = module.audio_link;
      this.moduleForm.video_link = module.video_link;
      this.moduleForm.audio_preview = module.audio_link; // ✅ show existing
      this.moduleForm.video_preview = module.video_link; // ✅ show existing
      const modalEl = document.getElementById("moduleModal");
      const modalInstance = Modal.getInstance(modalEl) || new Modal(modalEl);
      modalInstance.show();
    },

    async saveModule() {
      if (
        !this.moduleForm.title ||
        !this.moduleForm.short_detail ||
        !this.moduleForm.course_id
      ) {
        Swal.fire("Validation", "Please fill all required fields", "warning");
        return;
      }

      this.saving = true;
      try {
        const payload = {
          course_id: this.moduleForm.course_id,
          title: this.moduleForm.title,
          short_detail: this.moduleForm.short_detail,
          document: this.moduleForm.document,
          audio_link: this.moduleForm.audio_link,
          video_link: this.moduleForm.video_link,
        };

        let response;
        if (this.editingModuleId) {
          payload.id = this.editingModuleId;
          response = await apiService.updateModule(payload);
        } else {
          response = await apiService.saveModule(payload);
        }

        if (response.code === 200) {
          Swal.fire(
            "Success",
            this.editingModuleId ? "Module updated!" : "Module created!",
            "success"
          );
          this.editingModuleId = null;
          this.moduleForm = {
            course_id: null,
            title: "",
            short_detail: "",
            document: null,
            document_preview: null,
            audio_link: "",
            video_link: "",
            audio_preview: null,   // ✅ added
            video_preview: null,   // ✅ added
          };
          this.fetchModules();
          const modalEl = document.getElementById("moduleModal");
          Modal.getInstance(modalEl)?.hide();
        } else {
          Swal.fire("Error", response.message || "Failed to save module", "error");
        }
      } catch (err) {
        console.error("Save module error:", err);
        Swal.fire("Error", "Failed to save module", "error");
      } finally {
        this.saving = false;
      }
    },

    async deleteModule(module) {
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
        const response = await apiService.deleteModule(module.id);
        if (response.code === 200) {
          Swal.fire("Deleted!", "Module has been deleted.", "success");
          this.fetchModules();
        }
      } catch (err) {
        console.error("Delete module error:", err);
        Swal.fire("Error", "Failed to delete module", "error");
      }
    },
  },

  mounted() {
    this.fetchModules();
    this.fetchCoursesList();
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
          <h4>Module List</h4>
          <h6>Manage Your Modules</h6>
        </div>
        <div class="page-btn">
          <button class="btn btn-added" @click="addModule">
            <vue-feather type="plus-circle" class="me-2"></vue-feather>
            Add Module
          </button>
        </div>
      </div>

      <div class="d-flex mb-3">
        <input type="text" v-model="filters.search" class="form-control me-2" placeholder="Search by title or short detail" />
        <button class="btn btn-primary ms-2" @click="filters.search=''">Clear</button>
      </div>

      <div class="card table-list-card">
        <div class="card-body">
          <div class="table-responsive">
            <a-table :columns="columns" :data-source="filteredModules" :loading="loading" rowKey="id">
              <template #bodyCell="{ column, record }">
  <template v-if="column.key === 'action'">
    <div class="edit-delete-action">
      <a @click="editModule(record)" class="me-2"><vue-feather type="edit-2" /></a>
      <a @click="deleteModule(record)" class="me-2"><vue-feather type="trash-2" /></a>
    </div>
  </template>

  <!-- Document link -->
  <template v-else-if="column.key === 'document'">
    <a v-if="record.document_url" :href="record.document_url" target="_blank">
      Download
    </a>
    <span v-else>—</span>
  </template>

  <!-- Audio link -->
  <template v-else-if="column.key === 'audio_link'">
    <a v-if="record.audio_url" :href="record.audio_url" target="_blank">
      Listen
    </a>
    <span v-else>—</span>
  </template>

  <!-- Video link -->
  <template v-else-if="column.key === 'video_link'">
    <a v-if="record.video_url" :href="record.video_url" target="_blank">
      Watch
    </a>
    <span v-else>—</span>
  </template>

  <!-- Default text -->
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

  <!-- Module Modal -->
  <div class="modal fade" id="moduleModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">{{ editingModuleId ? "Edit Module" : "Add New Module" }}</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label">Course</label>
            <select v-model="moduleForm.course_id" class="form-select">
              <option value="" disabled>Select Course</option>
              <option v-for="course in coursesList" :key="course.id" :value="course.id">{{ course.title }}</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label">Title</label>
            <input type="text" v-model="moduleForm.title" class="form-control" />
          </div>
          <div class="mb-3">
            <label class="form-label">Short Detail</label>
            <textarea v-model="moduleForm.short_detail" class="form-control"></textarea>
          </div>
          <div class="mb-3">
            <label class="form-label">Document</label>
            <input type="file" @change="onDocumentChange" class="form-control" />
            <span v-if="moduleForm.document_preview">Current: {{ moduleForm.document_preview }}</span>
          </div>
          <div class="mb-3">
            <label class="form-label">Audio File</label>
            <input type="file" @change="onAudioChange" class="form-control" accept="audio/*" />
            <span v-if="moduleForm.audio_preview">Current: {{ moduleForm.audio_preview }}</span>
          </div>
           <div class="mb-3">
            <label class="form-label">Video File</label>
            <input type="file" @change="onVideoChange" class="form-control" accept="video/*" />
            <span v-if="moduleForm.video_preview">Current: {{ moduleForm.video_preview }}</span>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" :disabled="saving" @click="saveModule">
            {{ saving ? "Saving..." : (editingModuleId ? "Update Module" : "Save Module") }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>