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
import DocumentAttachment from '@/views/materials/document-attachment.vue'
import AudioAttachment from '@/views/materials/audio-attachment.vue'
import VideoAttachment from '@/views/materials/video-attachment.vue'
import Questions from '@/views/quiz/questions.vue'
import UserAnswer from '@/views/quiz/user-answer.vue'
import CreateLiveClasses from '@/views/live/create-live-classes.vue'
import AllLiveClasses from '@/views/live/all-live-classes.vue'
import LiveClassParticipants from '@/views/live/live-class-participants.vue'
import DocumentViews from '@/views/activity/document-views.vue'
import VideoViews from '@/views/activity/video-views.vue'
import Downloads from '@/views/activity/video-views.vue'
import UserReport from '@/views/reports/user-report.vue'
import CourseReport from '@/views/reports/course-report.vue'
import CourseEnrollmentReport from '@/views/reports/course-enrollment-report.vue'

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

   {
    path: '/materials/documents',
    name: 'document-attachment',
    component: DocumentAttachment
  },

  {
    path: '/materials/audio',
    name: 'audio-attachment',
    component: AudioAttachment
  },

  {
    path: '/materials/videos',
    name: 'video-attachment',
    component: VideoAttachment
  },

   {
    path: '/quiz/questions',
    name: 'questions',
    component: Questions
  },

   {
    path: '/quiz/user-answers',
    name: 'user-answer',
    component: UserAnswer
  },


 {
  path: '/live/create',
  name: 'create-live-classes', 
  component: CreateLiveClasses
},
{
  path: '/live/live-classes',
  name: 'all-live-classes',
  component: AllLiveClasses
},
{
  path: '/live/participants',
  name: 'live-class-participants',
  component: LiveClassParticipants
},

 // User Activity
  {
    path: '/activity/document-views',
    name: 'document-views',
    component: DocumentViews
  },
  {
    path: '/activity/video-views',
    name: 'video-views',
    component: VideoViews
  },
  {
    path: '/activity/downloads',
    name: 'downloads',
    component: Downloads
  },

  // Reports
  {
    path: '/reports/users',
    name: 'user-report',
    component: UserReport
  },
  {
    path: '/reports/courses',
    name: 'course-report',
    component: CourseReport
  },
  {
    path: '/reports/enrollments',
    name: 'course-enrollment-report',
    component: CourseEnrollmentReport
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
