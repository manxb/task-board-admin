<template>
  <div class="space-y-6">
    <div class="bg-white rounded-lg border p-4">
      <h2 class="text-lg font-medium mb-3">按处理人统计工单（总数）</h2>
      <v-chart :option="ticketsByAssignee" autoresize class="w-full h-[340px]" />
    </div>
    <div class="bg-white rounded-lg border p-4">
      <h2 class="text-lg font-medium mb-3">按角色环节分配（负责人）</h2>
      <v-chart :option="roleOwner" autoresize class="w-full h-[340px]" />
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
onMounted(fetchData)

const ticketsByAssignee = computed(() => {
  const tickets = data.value?.tickets || []
  const c = countBy(tickets, t => t.assignee || '-')
  const entries = Object.entries(c).filter(e => e[0] !== '-').sort((a,b)=>b[1]-a[1])
  return {
    tooltip: { trigger: 'axis' as const },
    xAxis: { type: 'category' as const, data: entries.map(e=>e[0]), axisLabel:{ rotate:30 } },
    yAxis: { type: 'value' as const, minInterval: 1 },
    series: [{ type: 'bar' as const, data: entries.map(e=>e[1]), itemStyle:{ color:'#8b5cf6' } }]
  }
})

const roleOwner = computed(() => {
  const pairs: Array<[string,string]> = []
  const tasks = data.value?.tasks || []
  for (const t of tasks) {
    for (const r of ['product','design','frontend','backend','qa'] as const) {
      const uid = t.rings[r].userId
      if (uid) {
        const a = accountMap.value.get(uid)
        if (a) pairs.push([a.role, a.name])
      }
    }
  }
  const c = countBy(pairs, p => `${p[0]}·${p[1]}`)
  const entries = Object.entries(c)
  return {
    tooltip: { trigger: 'axis' as const },
    xAxis: { type: 'category' as const, data: entries.map(e=>e[0].split('·')[1]), axisLabel:{ rotate:30 } },
    yAxis: { type: 'value' as const, minInterval: 1 },
    series: [{ type: 'bar' as const, data: entries.map(e=>e[1]), itemStyle:{ color:'#06b6d4' } }]
  }
})
</script>
