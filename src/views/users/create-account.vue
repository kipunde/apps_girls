<script>
import { Form, Field } from "vee-validate";
import * as Yup from "yup";
import { router } from "@/router";
import Swal from "sweetalert2";
import Logo from "@/assets/img/register02.png";
import { apiService } from "@/services/apiService";

export default {
  components: { Form, Field },
  data() {
    return {
      showPassword: false,
      terms: false,
      loading: false,
      Logo,
    };
  },
  methods: {
    toggleShow() {
      this.showPassword = !this.showPassword;
    },
    async onSubmit(values) {
      if (!this.terms) {
        Swal.fire({
          icon: "warning",
          title: "Oops...",
          text: "You must agree to the terms.",
        });
        return;
      }

      this.loading = true;
      try {
        const data = await apiService.register({ ...values, role: "user" });

        if (data.code === 200) {
          Swal.fire({
            icon: "success",
            title: "Registration Successful",
            text: data.message || "Your account has been created!",
            confirmButtonText: "Sign In",
          }).then(() => router.push("/"));
        } else {
          Swal.fire({
            icon: "error",
            title: "Registration Failed",
            text: data.message || "Something went wrong!",
          });
        }
      } catch (err) {
        console.error(err);
        Swal.fire({
          icon: "error",
          title: "Server Error",
          text: "Unable to connect to server. Please try again later.",
        });
      } finally {
        this.loading = false;
      }
    },
  },
  setup() {
    const schema = Yup.object({
      fullname: Yup.string().required("Full Name is required"),
      mobile: Yup.string()
        .required("Mobile is required")
        .matches(/^[0-9]+$/, "Only numbers allowed"),
      email: Yup.string().required("Email is required").email("Invalid email"),
      password: Yup.string()
        .required("Password is required")
        .min(6, "Minimum 6 characters"),
      location: Yup.string().required("Location is required"),
    });

    return { schema };
  },
};
</script>
<template>
  <div class="register-page">
    <div class="register-container">
      <div class="register-card">
        <div class="register-header">
          <!-- <img :src="Logo" alt="Logo" class="logo" /> -->
          <h2>Create Your Account</h2>
          <p>Sign up to access all features</p>
        </div>

        <Form :validation-schema="schema" @submit="onSubmit" v-slot="{ errors, values }">
          <div class="form-group">
            <label>Full Name</label>
            <Field
              name="fullname"
              type="text"
              class="form-control"
              placeholder="Enter full name"
              :class="{ 'is-invalid': errors.fullname }"
            />
            <div class="invalid-feedback">{{ errors.fullname }}</div>
          </div>

          <!-- Mobile -->
          <div class="form-group">
            <label>Mobile</label>
            <Field
              name="mobile"
              type="text"
              class="form-control"
              placeholder="Enter mobile number"
              :class="{ 'is-invalid': errors.mobile }"
            />
            <div class="invalid-feedback">{{ errors.mobile }}</div>
          </div>

          <!-- Email -->
          <div class="form-group">
            <label>Email</label>
            <Field
              name="email"
              type="email"
              class="form-control"
              placeholder="Enter email"
              :class="{ 'is-invalid': errors.email }"
            />
            <div class="invalid-feedback">{{ errors.email }}</div>
          </div>

          <!-- Password -->
          <div class="form-group password-group">
            <label>Password</label>
            <Field
              name="password"
              :type="showPassword ? 'text' : 'password'"
              class="form-control"
              placeholder="Enter password"
              :class="{ 'is-invalid': errors.password }"
            />
            <span class="toggle-password" @click="toggleShow">
              <i :class="showPassword ? 'fas fa-eye' : 'fas fa-eye-slash'"></i>
            </span>
            <div class="invalid-feedback">{{ errors.password }}</div>
          </div>

          <!-- Location -->
          <div class="form-group">
            <label>Location</label>
            <Field
              name="location"
              type="text"
              class="form-control"
              placeholder="Enter your location"
              :class="{ 'is-invalid': errors.location }"
            />
            <div class="invalid-feedback">{{ errors.location }}</div>
          </div>

          <!-- Terms -->
          <div class="form-group terms">
            <label>
              <input type="checkbox" v-model="terms" />
              I agree to the <a href="#">Terms & Privacy Policy</a>
            </label>
          </div>

          <!-- Submit -->
          <div class="form-group">

            <button
              type="submit"
              class="btn btn-primary btn-block"
              :disabled="loading"
            >
              {{ loading ? "Saving user..." : "Create Account" }}
            </button>
          </div>

          <!-- Login link -->
          <div class="form-footer">
            Already have an account? <router-link to="/">Sign In</router-link>
          </div>
        </Form>
      </div>
    </div>
  </div>
</template>
<style scoped>
.register-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f7f9fc;
}

.register-container {
  width: 100%;
  max-width: 450px;
  padding: 20px;
}

.register-card {
  background: #fff;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 6px 25px rgba(0,0,0,0.1);
}

.register-header {
  text-align: center;
  margin-bottom: 20px;
}

.register-header .logo {
  width: 80px;
  margin-bottom: 10px;
}

.register-header h2 {
  margin-bottom: 5px;
  font-size: 24px;
  color: #333;
}

.register-header p {
  font-size: 14px;
  color: #666;
}

.form-group {
  margin-bottom: 15px;
  position: relative;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
}

.form-control {
  width: 100%;
  padding: 10px 12px;
  border-radius: 6px;
  border: 1px solid #ccc;
}

.is-invalid {
  border-color: #e74c3c !important;
}

.invalid-feedback {
  color: #e74c3c;
  font-size: 12px;
  margin-top: 2px;
}

.password-group .toggle-password {
  position: absolute;
  right: 10px;
  top: 38px;
  cursor: pointer;
  color: #666;
}

.btn-primary {
  width: 100%;
  padding: 10px;
  background-color: #007bff;
  color: white;
  border-radius: 6px;
  border: none;
  font-weight: 600;
  cursor: pointer;
}

.btn-primary:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.form-footer {
  text-align: center;
  margin-top: 15px;
  font-size: 14px;
}

.form-footer a {
  color: #007bff;
  text-decoration: none;
}
</style>