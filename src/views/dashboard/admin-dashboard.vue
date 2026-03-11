
<script>
import { basicAreaChart } from "./data";
import { apiService } from "@/services/apiService";
export default {
  data() {
    return {
      basicAreaChart,
      topStats: [],
      quickStats: [],
      recentCourses: [
        { id: 1, title: "Vue 3 Mastery", instructor: "Sarah" },
        { id: 2, title: "Laravel Basics", instructor: "John" },
        { id: 3, title: "API Development", instructor: "David" },
      ],
      recentEnrollments: [
        { id: 1, user: "Alice", course: "Vue 3 Mastery", date: "2026-03-01", status: "Active" },
        { id: 2, user: "Bob", course: "Laravel Basics", date: "2026-03-02", status: "Active" },
        { id: 3, user: "Charlie", course: "API Development", date: "2026-03-03", status: "Inactive" },
      ],
    };
  },
async mounted() {
    this.loading = true;
    try {
      const data = await apiService.getDashboardData();
      if (data.code === 200) {
        this.topStats = data.dashboardStats;
        this.quickStats = data.quickStats;
      } else {
        this.error = data.message || "Failed to load dashboard data";
      }
    } catch (err) {
      this.error = err.message || "Something went wrong";
    } finally {
      this.loading = false;
    }
  },

};
</script>
<template>
  <div>
    <layout-header></layout-header>
    <layout-sidebar></layout-sidebar>

    <div class="page-wrapper">
      <div class="content">
        <!-- Top Statistics Cards -->
        <div class="row">
          <div class="col-xl-3 col-sm-6 col-12 d-flex" v-for="(stat, index) in topStats" :key="index">
            <div class="dash-widget w-100">
              <div class="dash-widgetimg">
                <span><vue-feather :type="stat.icon"></vue-feather></span>
              </div>
              <div class="dash-widgetcontent">
                <h5>
                  <vue3-autocounter
                    class="counters"
                    :startAmount="0"
                    :endAmount="stat.value"
                    :duration="3"
                    :autoinit="true"
                  />
                </h5>
                <h6>{{ stat.title }}</h6>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Stats -->
        <div class="row mt-4">
          <div class="col-xl-3 col-sm-6 col-12 d-flex" v-for="(quick, index) in quickStats" :key="index">
            <div :class="['dash-count', quick.className]">
              <div class="dash-counts">
                <h4>{{ quick.value }}</h4>
                <h5>{{ quick.title }}</h5>
              </div>
              <div class="dash-imgs">
                <vue-feather :type="quick.icon"></vue-feather>
              </div>
            </div>
          </div>
        </div>

        <!-- Charts & Recent Courses -->
        <div class="row mt-4">
          <div class="col-xl-7 col-sm-12 col-12 d-flex">
            <div class="card flex-fill">
              <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0">Course Enrollments</h5>
                <div class="graph-sets">
                  <ul class="mb-0">
                    <li><span>Enrollments</span></li>
                    <li><span>Completed</span></li>
                  </ul>
                  <div class="dropdown dropdown-wraper">
                    <button
                      class="btn btn-light btn-sm dropdown-toggle"
                      type="button"
                      id="dropdownMenuButton"
                      data-bs-toggle="dropdown"
                      aria-expanded="false"
                    >
                      2026
                    </button>
                    <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                      <li v-for="year in [2026,2025,2024]" :key="year">
                        <a href="javascript:void(0);" class="dropdown-item">{{ year }}</a>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
              <div class="card-body">
                <apexchart
                  type="bar"
                  height="300"
                  :options="basicAreaChart.sline"
                  :series="basicAreaChart.series"
                ></apexchart>
              </div>
            </div>
          </div>

          <div class="col-xl-5 col-sm-12 col-12 d-flex">
            <div class="card flex-fill default-cover mb-4">
              <div class="card-header d-flex justify-content-between align-items-center">
                <h4 class="card-title mb-0">Recent Courses</h4>
                <div class="view-all-link">
                  <router-link to="/courses" class="view-all d-flex align-items-center">
                    View All <vue-feather type="arrow-right" class="feather-16 ps-2"></vue-feather>
                  </router-link>
                </div>
              </div>
              <div class="card-body">
                <div class="table-responsive dataview">
                  <table class="table dashboard-recent-products">
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>Course</th>
                        <th>Instructor</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="course in recentCourses" :key="course.id">
                        <td>{{ course.id }}</td>
                        <td>{{ course.title }}</td>
                        <td>{{ course.instructor }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Enrollments -->
        <div class="card mt-4">
          <div class="card-header">
            <h4 class="card-title">Recent Enrollments</h4>
          </div>
          <div class="card-body">
            <div class="table-responsive dataview">
              <table class="table dashboard-expired-products">
                <thead>
                  <tr>
                    <th>User</th>
                    <th>Course</th>
                    <th>Date</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="enroll in recentEnrollments" :key="enroll.id">
                    <td>{{ enroll.user }}</td>
                    <td>{{ enroll.course }}</td>
                    <td>{{ enroll.date }}</td>
                    <td>
                      <span :class="['badge', enroll.status === 'Active' ? 'bg-success' : 'bg-secondary']">
                        {{ enroll.status }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

