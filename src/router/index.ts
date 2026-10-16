import { createRouter, createWebHashHistory } from 'vue-router'
import Overview from '../views/Overview.vue'
import Tasks from '../views/Tasks.vue'
import Workload from '../views/Workload.vue'
import Quality from '../views/Quality.vue'
import Explorer from '../views/Explorer.vue'

const routes = [
  { path: '/', redirect: '/overview' },
  { path: '/overview', component: Overview, name: '概览' },
  { path: '/tasks', component: Tasks, name: '任务进度' },
  { path: '/workload', component: Workload, name: '团队负载' },
  { path: '/quality', component: Quality, name: '质量回归' },
  { path: '/explorer', component: Explorer, name: '数据总览' },
]

export const router = createRouter({
  history: createWebHashHistory(),
  routes,
})
