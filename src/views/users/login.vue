<script>
import { router } from "@/router";
import { apiService } from "@/services/apiService";

export default {
  data() {
    return {
      email: "",
      password: "",
      showPassword: false,
      loading: false,
      apiError: "",
      errors: {},
    };
  },
  methods: {
    toggleShow() {
      this.showPassword = !this.showPassword;
    },
    validate() {
      this.errors = {};
      if (!this.email) this.errors.email = "Email is required";
      else if (!/\S+@\S+\.\S+/.test(this.email)) this.errors.email = "Email is invalid";

      if (!this.password) this.errors.password = "Password is required";
      else if (this.password.length < 6) this.errors.password = "Password must be at least 6 characters";

      return Object.keys(this.errors).length === 0;
    },
    async onSubmit() {
      if (!this.validate()) return;

      this.loading = true;
      this.apiError = "";

      try {
        const data = await apiService.login(this.email, this.password);

        if (data.code === 200) {
          // Check if user role exists and is admin
          if (data.user.role && data.user.role.toLowerCase() !== "admin") {
            this.apiError = "Only administrator allowed to login";
            this.loading = false;
            return;
          }

          // Save token and user info
          localStorage.setItem("token", data.token || "");
          localStorage.setItem("user", JSON.stringify(data.user));

          router.push("/dashboard");
        } else {
          this.apiError = data.message || "Invalid username or password";
        }
      } catch (err) {
        console.error(err);
        this.apiError = "Server error. Please try again.";
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>
<template>
  <div class="register-page">
    <div class="register-container">
      <div class="register-card">

        <!-- Header -->
        <div class="register-header">
          <!-- <img src="@/assets/img/logo.png" alt="logo" class="logo"/> -->
          <h3>Sign In</h3>
          <p>Enter your credentials to access your account</p>
        </div>

        <!-- Login Form -->
        <form @submit.prevent="onSubmit">

          <!-- Email -->
          <div class="form-group">
            <label>Email Address</label>
            <input
              type="email"
              class="form-control"
              placeholder="Enter your email"
              v-model="email"
            />
            <div class="text-danger">{{ errors.email }}</div>
          </div>

          <!-- Password -->
          <div class="form-group password-group">
            <label>Password</label>
            <div class="password-wrapper">
              <input
                :type="showPassword ? 'text' : 'password'"
                class="form-control"
                placeholder="Enter password"
                v-model="password"
              />
              <span @click="toggleShow" class="toggle-password">
                <i :class="showPassword ? 'fas fa-eye' : 'fas fa-eye-slash'"></i>
              </span>
            </div>
            <div class="text-danger">{{ errors.password }}</div>
            <div v-if="apiError" class="text-danger mt-2">{{ apiError }}</div>
          </div>

          <!-- Submit Button -->
          <div class="form-group">
            <button
              type="submit"
              class="btn btn-primary btn-block"
              :disabled="loading"
            >
              {{ loading ? "Signing in..." : "Sign In" }}
            </button>
          </div>

          <!-- Register Link -->
          <div class="form-footer">
            New on our platform?
            <router-link to="create-account" class="hover-a">Create an account</router-link>
          </div>

        </form>

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
  max-width: 400px;
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
  margin-bottom: 25px;
}

.register-header .logo {
  width: 80px;
  margin-bottom: 10px;
}

.register-header h3 {
  font-size: 26px;
  font-weight: 600;
  margin-bottom: 5px;
}

.register-header p {
  font-size: 14px;
  color: #666;
}

.form-group {
  margin-bottom: 20px;
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

.password-wrapper {
  position: relative;
}

.toggle-password {
  position: absolute;
  right: 10px;
  top: 10px;
  cursor: pointer;
  color: #666;
}

.text-danger {
  color: #e74c3c;
  font-size: 13px;
  margin-top: 3px;
}

.btn-primary {
  width: 100%;
  padding: 12px;
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