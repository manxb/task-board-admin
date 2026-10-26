<template>
  <div class="space-y-6">
    <div class="bg-white rounded-2xl border border-slate-200/60 p-4 shadow-sm">
      <h2 class="text-lg font-medium mb-3">按处理人统计工单（总数）</h2>
      <div class="w-full h-[340px]">
        <v-chart v-if="hasTicketData" :option="ticketsByAssignee" autoresize class="w-full h-full" />
        <div v-else class="text-sm text-gray-500 py-12 text-center">暂无数据</div>
      </div>
    </div>
    <div class="bg-white rounded-2xl border border-slate-200/60 p-4 shadow-sm">
      <h2 class="text-lg font-medium mb-3">按角色环节分配（负责人）</h2>
      <div class="w-full h-[340px]">
        <v-chart v-if="hasRoleData" :option="roleOwner" autoresize class="w-full h-full" />
        <div v-else class="text-sm text-gray-500 py-12 text-center">暂无数据</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart } from 'echarts/charts'
import { TitleComponent, TooltipComponent, LegendComponent, GridComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { useData } from '../composables/useData'
import { countBy } from '../utils'

use([CanvasRenderer, BarChart, TitleComponent, TooltipComponent, LegendComponent, GridComponent])

const { data, accountMap, fetchData } = useData()
onMounted(async () => {
  await fetchData()
})

const ticketsByAssignee = computed(() => {
  const tickets = data.value?.tickets || []
  const c = countBy(tickets, t => (t.assignee && String(t.assignee).trim()) || '未分配')
  const entries = Object.entries(c).filter(e => e[0] !== '未分配').sort((a,b)=>b[1]-a[1])
  const names = entries.map(e => e[0])
  const values = entries.map(e => e[1])
  return {
    tooltip: { trigger: 'axis' as const },
    grid: { left: 30, right: 20, bottom: 40, top: 20, containLabel: true },
    xAxis: { type: 'category' as const, data: names, axisLabel:{ rotate:30, interval:0 } },
    yAxis: { type: 'value' as const, minInterval: 1 },
    series: [{ type: 'bar' as const, data: values, itemStyle:{ color:'#8b5cf6' }, barMaxWidth:40 }]
  }
})

const hasTicketData = computed(() => (ticketsByAssignee.value.xAxis.data as any[]).length > 0)

const roleOwner = computed(() => {
  const pairs: Array<[string,string]> = []
  const tasks = data.value?.tasks || []
  const amap = accountMap.value
  for (const t of tasks) {
    const rings: any = (t as any).rings
    for (const r of ['product','design','frontend','backend','qa'] as const) {
      const ring = rings?.[r]
      const uid = ring?.userId
      if (uid && amap.has(uid)) {
        const a = amap.get(uid)!
        pairs.push([a.role || '-', a.name || uid])
      }
    }
  }
  const c = countBy(pairs, p => `${p[0]}·${p[1]}`)
  const entries = Object.entries(c).sort((a,b)=>b[1]-a[1])
  const names = entries.map(e => e[0].split('·')[1])
  const values = entries.map(e => e[1])
  return {
    tooltip: { trigger: 'axis' as const },
    grid: { left: 30, right: 20, bottom: 40, top: 20, containLabel: true },
    xAxis: { type: 'category' as const, data: names, axisLabel:{ rotate:30, interval:0 } },
    yAxis: { type: 'value' as const, minInterval: 1 },
    series: [{ type: 'bar' as const, data: values, itemStyle:{ color:'#06b6d4' }, barMaxWidth:40 }]
  }
})

const hasRoleData = computed(() => (roleOwner.value.xAxis.data as any[]).length > 0)
</script>
