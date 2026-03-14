import {createRouter, createWebHistory} from 'vue-router';
import SignIn from '@/views/users/login.vue'
import Registration from '@/views/users/create-account.vue'
import AdminDashboard from '@/views/dashboard/admin-dashboard.vue'
import UserDashboard from '@/views/dashboard/sales-dashboard.vue'
import UserList from '@/views/users/users-list.vue'
import CourseList from '@/views/courses/course-list.vue'
import CourseEnrollment from '@/views/courses/course-enrollment.vue'
import ModuleList from '@/views/modules/module-list.vue'
import ModuleAttachment from '@/views/modules/module-attachment.vue'
const routes = [
  {
    path: '/',
    name: 'login',
    component: SignIn
  },

  {
    path: '/create-account',
    name: 'create-account',
    component: Registration
  },

  {
    path: '/dashboard',
    name: 'admin-dashboard',
    component: AdminDashboard
  },

   {
    path: '/users/list',
    name: 'users-list',
    component: UserList
  },

   {
    path: '/courses/list',
    name: 'course-list',
    component: CourseList
  },

   {
    path: '/courses/course-enrollment',
    name: 'course-enrollment',
    component: CourseEnrollment
  },

   {
    path: '/modules/list',
    name: 'module-list',
    component: ModuleList
  },

   {
    path: '/modules/attachments',
    name: 'module-attachment',
    component: ModuleAttachment
  },

];

export const router = createRouter({
  history: createWebHistory('/app'),
    linkActiveClass: 'active',
    routes,
}); 

router.beforeEach((to, from, next) => {
// Scroll to the top of the page
window.scrollTo({ top: 0, behavior: 'smooth' });
// Continue with the navigation
next();
});
