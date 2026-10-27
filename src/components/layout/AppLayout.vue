<template>
  <div class="min-h-screen flex" style="background: linear-gradient(135deg,#f4f6fb 0%,#eef2ff 100%)">
    <aside class="w-64 flex flex-col bg-white border-r border-slate-200">
      <div class="p-5 border-b border-slate-200">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-xl flex items-center justify-center" style="background: linear-gradient(135deg,#3b82f6,#8b5cf6)">
            <span class="text-white font-bold text-sm">TB</span>
          </div>
          <div>
            <h1 class="text-base font-semibold text-slate-800">任务看板</h1>
            <div class="text-xs text-slate-500">Task Board Admin</div>
          </div>
        </div>
      </div>
      <nav class="flex-1 p-3 space-y-1">
        <router-link v-for="r in routes" :key="r.path" :to="r.path"
          class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm transition-all"
          :class="$route.path.startsWith(r.path) ? 'bg-blue-50 text-blue-700 font-medium' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'">
          <span class="w-1.5 h-1.5 rounded-full" :class="$route.path.startsWith(r.path) ? 'bg-blue-500' : 'bg-slate-300'"></span>
          {{ r.name }}
        </router-link>
      </nav>
      <div class="p-4 border-t border-slate-200 text-xs text-slate-500">
        基于 data/task.json
      </div>
    </aside>
    <main class="flex-1 flex flex-col min-w-0">
      <header class="px-6 py-3 flex items-center justify-between border-b border-slate-200/60 backdrop-blur" style="background: rgba(255,255,255,0.7)">
        <div class="text-sm font-semibold text-slate-800 flex items-center gap-2">
          {{ currentName }}
          <span v-if="pendingCount>0" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-600">待处理 {{ pendingCount }}</span>
        </div>
        <div class="text-xs text-slate-500">{{ now }}</div>
      </header>
      <div class="p-6 flex-1 overflow-auto">
        <router-view />
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, watchEffect } from 'vue'
import { useRoute } from 'vue-router'
import dayjs from 'dayjs'
import { loadData } from '../../data/loader'

const route = useRoute()
const routes = [
  { path: '/overview', name: '概览' },
  { path: '/tasks', name: '任务进度' },
  { path: '/workload', name: '团队负载' },
  { path: '/quality', name: '质量回归' },
  { path: '/explorer', name: '数据总览' },
]
const currentName = computed(() => routes.find(r=>route.path.startsWith(r.path))?.name || '')
const now = ref(dayjs().format('YYYY-MM-DD HH:mm:ss'))
setInterval(()=>{ now.value = dayjs().format('YYYY-MM-DD HH:mm:ss') }, 1000)

const pendingCount = ref(0)
onMounted(async () => {
  try {
    const d = await loadData()
    pendingCount.value = (d.tickets || []).filter(t => t.status === '待处理').length
  } catch {}
})

watchEffect(() => {
  if (pendingCount.value > 0) {
    document.title = `【待处理 ${pendingCount.value}】任务看板`
  } else {
    document.title = '任务看板'
  }
})
</script>
