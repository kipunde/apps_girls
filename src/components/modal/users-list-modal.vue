<template>
  <!-- Add User -->
  <div class="modal fade" id="add-user">
    <div class="modal-dialog modal-dialog-centered custom-modal-two">
      <div class="modal-content">
        <div class="page-wrapper-new p-0">
          <div class="content">
            <div class="modal-header border-0 custom-modal-header">
              <div class="page-title"><h4>Add User</h4></div>
              <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div class="modal-body custom-modal-body">
              <form @submit.prevent="submitForm('add')">
                <div class="row">
                  <!-- Full Name -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Full Name</label>
                      <input type="text" class="form-control" v-model="form.fullname"/>
                    </div>
                  </div>

                  <!-- Phone -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Phone</label>
                      <input type="text" class="form-control" v-model="form.mobile"/>
                    </div>
                  </div>

                  <!-- Email -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Email</label>
                      <input type="email" class="form-control" v-model="form.email"/>
                    </div>
                  </div>

                  <!-- Role -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Role</label>
                      <vue-select :options="ListUs" v-model="form.role" placeholder="Choose" />
                    </div>
                  </div>

                  <!-- Password -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Password</label>
                      <div class="pass-group">
                        <input type="password" class="pass-input" v-model="form.password"/>
                        <span class="fas toggle-password fa-eye-slash"></span>
                      </div>
                    </div>
                  </div>

                  <!-- Confirm Password -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Confirm Password</label>
                      <div class="pass-group">
                        <input type="password" class="pass-input" v-model="form.confirmPassword"/>
                        <span class="fas toggle-password fa-eye-slash"></span>
                      </div>
                    </div>
                  </div>

                  <!-- Location -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Location</label>
                      <input type="text" class="form-control" v-model="form.location" placeholder="Enter Location"/>
                    </div>
                  </div>

                  <!-- Status -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Status</label>
                      <select class="form-control" v-model="form.status">
                        <option value="2">Active</option>
                        <option value="1">Inactive</option>
                      </select>
                    </div>
                  </div>

                </div>

                <div class="modal-footer-btn">
                  <button type="button" class="btn btn-cancel me-2" data-bs-dismiss="modal">Cancel</button>
                  <button type="submit" class="btn btn-submit">Submit</button>
                </div>

              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Edit User -->
  <div class="modal fade" id="edit-units">
    <div class="modal-dialog modal-dialog-centered custom-modal-two">
      <div class="modal-content">
        <div class="page-wrapper-new p-0">
          <div class="content">
            <div class="modal-header border-0 custom-modal-header">
              <div class="page-title"><h4>Edit User</h4></div>
              <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div class="modal-body custom-modal-body">
              <form @submit.prevent="submitForm('edit')">
                <div class="row">

                  <!-- Full Name -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>User Name</label>
                      <input type="text" class="form-control" v-model="form.fullname"/>
                    </div>
                  </div>

                  <!-- Phone -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Phone</label>
                      <input type="text" class="form-control" v-model="form.mobile"/>
                    </div>
                  </div>

                  <!-- Email -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Email</label>
                      <input type="email" class="form-control" v-model="form.email"/>
                    </div>
                  </div>

                  <!-- Role -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Role</label>
                      <vue-select :options="ListUsOne" v-model="form.role" />
                    </div>
                  </div>

                  <!-- Password -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Password</label>
                      <div class="pass-group">
                        <input type="password" class="pass-input" v-model="form.password"/>
                        <span class="fas toggle-password fa-eye-slash"></span>
                      </div>
                    </div>
                  </div>

                  <!-- Confirm Password -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Confirm Password</label>
                      <div class="pass-group">
                        <input type="password" class="pass-input" v-model="form.confirmPassword"/>
                        <span class="fas toggle-password fa-eye-slash"></span>
                      </div>
                    </div>
                  </div>

                  <!-- Location -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Location</label>
                      <input type="text" class="form-control" v-model="form.location"/>
                    </div>
                  </div>

                  <!-- Status -->
                  <div class="col-lg-6">
                    <div class="input-blocks">
                      <label>Status</label>
                      <select class="form-control" v-model="form.status">
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                      </select>
                    </div>
                  </div>

                </div>

                <div class="modal-footer-btn">
                  <button type="button" class="btn btn-cancel me-2" data-bs-dismiss="modal">Cancel</button>
                  <button type="submit" class="btn btn-submit">Submit</button>
                </div>

              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { Modal } from "bootstrap";
import { apiService } from "@/services/apiService";
import Swal from "sweetalert2";

export default {
  data() {
    return {
      ListUs: ["user", "admin"],
      ListUsOne: ["admin"],
      form: {
        id: null,
        fullname: "",
        mobile: "",
        email: "",
        role: "",
        password: "",
        confirmPassword: "",
        location: "",
        status: "",
      },
    };
  },
  methods: {
    async submitForm(type) {
      try {
        if(type === "add") {
          const response = await apiService.register(this.form);
          if(response.success){
            Swal.fire("Success", "User added successfully!", "success");
          } else {
            Swal.fire("Error", response.message || "Failed to add user", "error");
          }
        } else if(type === "edit") {
          const response = await apiService.updateUser(this.form.id, this.form);
          if(response.success){
            Swal.fire("Success", "User updated successfully!", "success");
          } else {
            Swal.fire("Error", response.message || "Failed to update user", "error");
          }
        }
      } catch (error) {
        console.error(error);
        Swal.fire("Error", "Something went wrong", "error");
      } finally {
        // Close modals
        const addModalEl = document.getElementById("add-units");
        const editModalEl = document.getElementById("edit-units");
        const addModal = Modal.getInstance(addModalEl) || new Modal(addModalEl);
        const editModal = Modal.getInstance(editModalEl) || new Modal(editModalEl);
        addModal.hide();
        editModal.hide();

        // Refresh user list
        this.$emit("refreshUsers");
      }
    },

    edit(record) {
      this.form = {
        id: record.id,
        fullname: record.fullname,
        mobile: record.mobile,
        email: record.email,
        role: record.role,
        password: "",
        location: record.location,
        status: record.status,
      };
      const editModalEl = document.getElementById("edit-units");
      const modal = new Modal(editModalEl);
      modal.show();
    }
  }
};
</script>