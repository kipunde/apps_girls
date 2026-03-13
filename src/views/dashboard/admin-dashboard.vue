
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
       

        <!-- Recent Enrollments -->
        

      </div>
    </div>
  </div>
</template>

