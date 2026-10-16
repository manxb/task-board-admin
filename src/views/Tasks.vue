<template>
  <div class="space-y-6">
    <div class="flex flex-wrap gap-3 items-center bg-white rounded border p-3">
      <select v-model="filters.site" class="border rounded px-2 py-1 text-sm">
        <option value="">全部站点</option>
        <option value="1JJ">1JJ</option>
        <option value="JJB">JJB</option>
      </select>
      <select v-model="filters.status" class="border rounded px-2 py-1 text-sm">
        <option value="">全部状态</option>
        <option value="设计中">设计中</option>
        <option value="开发中">开发中</option>
        <option value="测试中">测试中</option>
        <option value="已上线">已上线</option>
      </select>
      <select v-model="filters.assignee" class="border rounded px-2 py-1 text-sm">
        <option value="">全部负责人</option>
        <option v-for="n in assignees" :key="n" :value="n">{{ n }}</option>
      </select>
      <select v-model="filters.role" class="border rounded px-2 py-1 text-sm">
        <option value="">全部角色</option>
        <option v-for="r in roles" :key="r" :value="r">{{ r }}</option>
      </select>
      <input v-model="filters.keyword" placeholder="搜索任务名称" class="border rounded px-2 py-1 text-sm flex-1 min-w-[200px]" />
    </div>

    <div class="bg-white rounded-lg border overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-gray-50">
          <tr>
            <th class="text-left p-2">任务</th>
            <th class="text-left p-2">站点</th>
            <th class="text-left p-2">类型</th>
            <th class="text-left p-2">状态</th>
            <th class="text-left p-2">完成度</th>
            <th class="text-left p-2">Product</th>
            <th class="text-left p-2">Design</th>
            <th class="text-left p-2">FE</th>
            <th class="text-left p-2">BE</th>
            <th class="text-left p-2">QA</th>
            <th class="text-left p-2">外链</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="t in filteredTasks" :key="t.id" class="border-t hover:bg-gray-50">
            <td class="p-2 max-w-[240px] truncate" :title="t.name">{{ t.name }}</td>
            <td class="p-2">{{ t.site }}</td>
            <td class="p-2">{{ t.type }}</td>
            <td class="p-2">{{ t.status }}</td>
            <td class="p-2">{{ t.completion }}%</td>
            <td class="p-2">{{ ringOwner(t, 'product') }} ({{ t.rings.product.progress }})</td>
            <td class="p-2">{{ ringOwner(t, 'design') }} ({{ t.rings.design.progress }})</td>
            <td class="p-2">{{ ringOwner(t, 'frontend') }} ({{ t.rings.frontend.progress }})</td>
            <td class="p-2">{{ ringOwner(t, 'backend') }} ({{ t.rings.backend.progress }})</td>
            <td class="p-2">{{ ringOwner(t, 'qa') }} ({{ t.rings.qa.progress }})</td>
            <td class="p-2 flex gap-2">
              <a v-if="t.sheet" :href="t.sheet" target="_blank" class="text-blue-600">Sheet</a>
              <a v-if="t.axure" :href="t.axure" target="_blank" class="text-blue-600">Axure</a>
              <a v-if="t.zeplin" :href="t.zeplin" target="_blank" class="text-blue-600">Zeplin</a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="bg-white rounded-lg border p-4">
      <h2 class="text-lg font-medium mb-3">各任务环节堆叠（完成度拆解）</h2>
      <v-chart :option="stackedOption" autoresize class="w-full h-[380px]" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart } from 'echarts/charts'
import { TitleComponent, TooltipComponent, LegendComponent, GridComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { useData } from '../composables/useData'
import type { Task } from '../types/data'

use([CanvasRenderer, BarChart, TitleComponent, TooltipComponent, LegendComponent, GridComponent])

const { data, tasksWithMeta, accountMap, fetchData } = useData()

onMounted(fetchData)

const filters = reactive({ site: '', status: '', assignee: '', role: '', keyword: '' })

const ringOwner = (t: Task, ring: keyof Task['rings']) => {
  const uid = t.rings[ring].userId
  if (!uid) return (t as any)[ring] || '-'
  const a = accountMap.value.get(uid)
  return a?.name || (t as any)[ring] || uid
}

const assignees = computed(() => {
  const set = new Set<string>()
  for (const t of tasksWithMeta.value) {
    for (const r of ['product','design','frontend','backend','qa'] as const) {
      const uid = t.rings[r].userId
      if (uid) {
        const a = accountMap.value.get(uid)
        if (a?.name) set.add(a.name)
      } else if ((t as any)[r]) set.add(String((t as any)[r]))
    }
  }
  return Array.from(set).sort()
})

const roles = computed(() => Array.from(new Set((data.value?.accounts||[]).map(a=>a.role))).sort())

const filteredTasks = computed(() => {
  return tasksWithMeta.value.filter(t => {
    if (filters.site && t.site !== filters.site) return false
    if (filters.status && t.status !== filters.status) return false
    if (filters.keyword && !t.name.includes(filters.keyword)) return false
    if (filters.assignee) {
      const names = new Set<string>()
      for (const r of ['product','design','frontend','backend','qa'] as const) {
        const uid = t.rings[r].userId
        if (uid) names.add(accountMap.value.get(uid)?.name || '')
        else names.add(String((t as any)[r]))
      }
      if (!names.has(filters.assignee)) return false
    }
    if (filters.role) {
      const roles = new Set<string>()
      for (const r of ['product','design','frontend','backend','qa'] as const) {
        const uid = t.rings[r].userId
        if (uid) roles.add(accountMap.value.get(uid)?.role || '')
      }
      if (!roles.has(filters.role)) return false
    }
    return true
  })
})

const stackedOption = computed(() => {
  const names = filteredTasks.value.map(t => t.name.length>12 ? t.name.slice(0,12)+'…' : t.name)
  return {
    tooltip: { trigger: 'axis', axisPointer:{ type:'shadow' } },
    legend: { data: ['完成度'] },
    xAxis: { type: 'category', data: names, axisLabel:{ rotate:30 } },
    yAxis: { type: 'value', max: 100 },
    series: [{
      name: '完成度',
      type: 'bar',
      data: filteredTasks.value.map(t => t.completion),
      itemStyle:{ color: '#3b82f6' }
    }]
  }
})
</script>
