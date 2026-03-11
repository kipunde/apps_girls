<script>
import { apiService } from "@/services/apiService";

export default {
  data() {
    return {
      user: null,
      notifications: [],
      notifCount: 0,
      recentCustomers: [
        { name: "Aron Varu", avatar: require("@/assets/img/profiles/avator1.jpg") },
        { name: "Jonita", avatar: require("@/assets/img/profiles/avatar-01.jpg") },
        { name: "Aaron", avatar: require("@/assets/img/profiles/avatar-10.jpg") },
      ],
      notifications: [
        { user: "John Doe", avatar: require("@/assets/img/profiles/avatar-02.jpg"), action: "added new task", target: "Patient appointment booking", time: "4 mins ago", link: "/activities" },
        { user: "Tarah Shropshire", avatar: require("@/assets/img/profiles/avatar-03.jpg"), action: "changed the task name", target: "Appointment booking with payment gateway", time: "6 mins ago", link: "/activities" },
      ],
    };
  },
  mounted() {
    this.initMouseoverListener();
    this.getLoggedUser();
    this.getNotificationData();
  },
  methods: {
    // get login user
   async getLoggedUser() {
  try {
    const data = await apiService.getUser();
    console.log("USER API RESPONSE:", data);
    if (data?.code === 200 && data?.users?.length > 0) {
      const user = data.users[0];
      this.user = user;
    } else {
      console.warn("User not authenticated or session expired");
      this.user = null;
    }
  } catch (err) {
    console.error("Failed to fetch user:", err);
    this.user = null;
  }
},
// Fetch notifications from API
    async getNotificationData() {
      try {
        const data = await apiService.getNotifications();
        if (data.code === 200) {
          this.notifications = data.notifications;
          this.notifCount = data.total_new_users;
        } else {
          this.notifications = [];
          this.notifCount = 0;
        }
      } catch (err) {
        console.error("Failed to fetch notifications:", err);
        this.notifications = [];
        this.notifCount = 0;
      }
    },

    toggleSidebar1() {
      document.body.classList.toggle("slide-nav");
    },
    toggleSidebar() {
      document.body.classList.toggle("mini-sidebar");
    },
    initFullScreen() {
      document.body.classList.toggle("fullscreen-enable");
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen?.();
      } else {
        document.exitFullscreen?.();
      }
    },
    initMouseoverListener() {
      document.addEventListener("mouseover", this.handleMouseover);
    },
    handleMouseover(e) {
      e.stopPropagation();
      const body = document.body;
      const toggleBtn = document.getElementById("toggle_btn");
      if (body.classList.contains("mini-sidebar") && this.isElementVisible(toggleBtn)) {
        const target = e.target.closest(".sidebar, .header-left");
        if (target) {
          body.classList.add("expand-menu");
          this.slideDownSubmenu();
        } else {
          body.classList.remove("expand-menu");
          this.slideUpSubmenu();
        }
        e.preventDefault();
      }
    },
    isElementVisible(element) {
      return element.offsetWidth > 0 || element.offsetHeight > 0;
    },
    slideDownSubmenu() {
      const subdropPlusUl = document.getElementsByClassName("subdrop");
      for (let i = 0; i < subdropPlusUl.length; i++) {
        const submenu = subdropPlusUl[i].nextElementSibling;
        if (submenu && submenu.tagName.toLowerCase() === "ul") submenu.style.display = "block";
      }
    },
    slideUpSubmenu() {
      const subdropPlusUl = document.getElementsByClassName("subdrop");
      for (let i = 0; i < subdropPlusUl.length; i++) {
        const submenu = subdropPlusUl[i].nextElementSibling;
        if (submenu && submenu.tagName.toLowerCase() === "ul") submenu.style.display = "none";
      }
    },
  },
  beforeUnmount() {
    document.removeEventListener("mouseover", this.handleMouseover);
  },
};
</script>

<template>
  <!-- Header -->
  <div class="header">

    <!-- Logo -->
    <div class="header-left active">
      <router-link to="/dashboard" class="logo logo-normal">
        <!-- <img src="@/assets/img/logo.png" alt=""> -->
         Logo here
      </router-link>
      <router-link to="/dashboard" class="logo logo-white">
        <!-- <img src="@/assets/img/logo-white.png" alt=""> -->
      </router-link>
      <router-link to="/dashboard" class="logo-small">
        <!-- <img src="@/assets/img/logo-small.png" alt=""> -->
      </router-link>
      <a id="toggle_btn" href="javascript:void(0);" @click="toggleSidebar">
        <vue-feather type="chevrons-left"></vue-feather>
      </a>
    </div>
    <!-- /Logo -->

    <a id="mobile_btn" class="mobile_btn" href="javascript:void(0);" @click="toggleSidebar1">
      <span class="bar-icon">
        <span></span>
        <span></span>
        <span></span>
      </span>
    </a>

    <!-- Header Menu -->
    <ul class="nav user-menu">

      <!-- Search -->
      <li class="nav-item nav-searchinputs">
        <div class="top-nav-search">
          <a href="javascript:void(0);" class="responsive-search">
            <i class="fa fa-search"></i>
          </a>
          <form action="javascript:void(0);" class="dropdown">
            <div class="searchinputs dropdown-toggle" id="dropdownMenuClickable" data-bs-toggle="dropdown"
              data-bs-auto-close="false">
              <input type="text" placeholder="Search">
              <div class="search-addon">
                <span><vue-feather type="x-circle" class="feather-14"></vue-feather></span>
              </div>
            </div>
            <div class="dropdown-menu search-dropdown" aria-labelledby="dropdownMenuClickable">
              <div class="search-info">
                <h6><span><vue-feather type="search" class="feather-16"></vue-feather></span>Recent Searches</h6>
                <ul class="search-tags">
                  <li><a href="javascript:void(0);">Products</a></li>
                  <li><a href="javascript:void(0);">Sales</a></li>
                  <li><a href="javascript:void(0);">Applications</a></li>
                </ul>
              </div>
              <div class="search-info">
                <h6><span><vue-feather type="help-circle" class="feather-16"></vue-feather></span>Help</h6>
                <p>How to Change Product Volume from 0 to 200 on Inventory management</p>
                <p>Change Product Name</p>
              </div>
              <div class="search-info">
                <h6><span><vue-feather type="user" class="feather-16"></vue-feather></span>Customers</h6>
                <ul class="customers">
                  <li v-for="customer in recentCustomers" :key="customer.name">
                    <a href="javascript:void(0);">
                      {{ customer.name }}
                      <img :src="customer.avatar" alt="" class="img-fluid">
                    </a>
                  </li>
                </ul>
              </div>
            </div>
          </form>
        </div>
      </li>
      <!-- /Search -->

      <!-- Flag -->
      <li class="nav-item dropdown has-arrow flag-nav nav-item-box">
        <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="javascript:void(0);" role="button">
          <img src="@/assets/img/flags/us.png" alt="Language" class="img-fluid">
        </a>
        <div class="dropdown-menu dropdown-menu-right">
          <a href="javascript:void(0);" class="dropdown-item active">
            <img src="@/assets/img/flags/us.png" alt="" height="16"> English
          </a>
          <a href="javascript:void(0);" class="dropdown-item">
            <img src="@/assets/img/flags/fr.png" alt="" height="16"> Kiswahili
          </a>
        </div>
      </li>
      <!-- /Flag -->

      <li class="nav-item nav-item-box">
        <a href="javascript:void(0);" id="btnFullscreen" @click="initFullScreen">
          <vue-feather type="maximize"></vue-feather>
        </a>
      </li>
      <li class="nav-item nav-item-box">
        <router-link to="/application/email">
          <vue-feather type="mail"></vue-feather>
          <span class="badge rounded-pill">0</span>
        </router-link>
      </li>

     <!-- Notifications -->
<li class="nav-item dropdown nav-item-box">
  <router-link to="/users/list">
    <vue-feather type="bell"></vue-feather>
    <span class="badge rounded-pill">{{ notifCount }}</span>
  </router-link>
</li>
      <li class="nav-item nav-item-box">
        <router-link to="/settings/general-settings"><vue-feather type="settings"></vue-feather></router-link>
      </li>

      <!-- User Dropdown -->
      <li class="nav-item dropdown has-arrow main-drop">
        <a href="javascript:void(0);" class="dropdown-toggle nav-link userset" data-bs-toggle="dropdown">
          <span class="user-info">
            <span class="user-letter">
              <img :src="user?.avatar || require('@/assets/img/profiles/avator1.jpg')" alt="" class="img-fluid">
            </span>
            <span class="user-detail">
              <span class="user-name">{{ user?.fullname }}</span>
              <span class="user-role">{{ user?.role }}</span>
            </span>
          </span>
        </a>
        <div class="dropdown-menu menu-drop-user">
          <div class="profilename">
            <div class="profileset">
              <span class="user-img">
                <img :src="user?.avatar || require('@/assets/img/profiles/avator1.jpg')" alt="">
                <span class="status online"></span>
              </span>
              <div class="profilesets">
                <h6>{{ user?.fullname }}</h6>
                <h5>{{ user?.role }}</h5>
              </div>
            </div>
            <hr class="m-0">
            <router-link class="dropdown-item" to="/pages/profile">
              <vue-feather class="me-2" type="user"></vue-feather> My Profile
            </router-link>
            <router-link class="dropdown-item" to="/settings/general-settings">
              <vue-feather class="me-2" type="settings"></vue-feather> Settings
            </router-link>
            <hr class="m-0">
            <router-link class="dropdown-item logout pb-0" to="/">
              <img src="@/assets/img/icons/log-out.svg" class="me-2" alt="img"> Logout
            </router-link>
          </div>
        </div>
      </li>
      <!-- /User Dropdown -->

    </ul>
    <!-- /Header Menu -->

    <!-- Mobile Menu -->
    <div class="dropdown mobile-user-menu">
      <a href="javascript:void(0);" class="nav-link dropdown-toggle" data-bs-toggle="dropdown"
        aria-expanded="false"><i class="fa fa-ellipsis-v"></i></a>
      <div class="dropdown-menu dropdown-menu-right">
        <router-link class="dropdown-item" to="/pages/profile">My Profile</router-link>
        <router-link class="dropdown-item" to="/settings/general-settings">Settings</router-link>
        <router-link class="dropdown-item" to="/">Logout</router-link>
      </div>
    </div>
    <!-- /Mobile Menu -->

  </div>
  <!-- /Header -->

  <side-settings></side-settings>
</template>

