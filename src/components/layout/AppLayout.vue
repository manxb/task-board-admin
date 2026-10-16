<template>
  <div class="min-h-screen flex bg-gray-50">
    <aside class="w-60 bg-white border-r flex flex-col">
      <div class="p-4 border-b">
        <h1 class="text-lg font-semibold">任务看板</h1>
        <div class="text-xs text-gray-500">Task Board Admin</div>
      </div>
      <nav class="flex-1 p-3 space-y-1">
        <router-link v-for="r in routes" :key="r.path" :to="r.path"
          class="block px-3 py-2 rounded text-sm hover:bg-gray-100"
          :class="{ 'bg-gray-100 font-medium': $route.path.startsWith(r.path) }">
          {{ r.name }}
        </router-link>
      </nav>
      <div class="p-3 border-t text-xs text-gray-500">
        基于 data/task.json
      </div>
    </aside>
    <main class="flex-1 flex flex-col">
      <header class="bg-white border-b p-3 flex items-center justify-between">
        <div class="text-sm font-medium">{{ currentName }} <span v-if="pendingCount>0" class="ml-2 inline-flex items-center px-2 py-0.5 rounded-full text-xs bg-red-100 text-red-700">待处理 {{ pendingCount }}</span></div>
        <div class="text-xs text-gray-500">{{ now }}</div>
      </header>
      <div class="p-4 flex-1 overflow-auto">
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
    pendingCount.value = (d.tickets || []).filter(t => t.status === '待处理' || t.status === '待回归').length
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
