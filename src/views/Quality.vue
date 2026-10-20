<template>
  <div class="space-y-6">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div class="bg-white rounded border p-4">
        <div class="text-sm text-gray-500">待回归</div>
        <div class="text-2xl font-semibold">{{ pendingRegression.length }}</div>
      </div>
      <div class="bg-white rounded border p-4">
        <div class="text-sm text-gray-500">待处理</div>
        <div class="text-2xl font-semibold">{{ pendingHandle.length }}</div>
      </div>
      <div class="bg-white rounded border p-4">
        <div class="text-sm text-gray-500">已关闭</div>
        <div class="text-2xl font-semibold">{{ closedTickets.length }}</div>
      </div>
    </div>

    <div class="bg-white rounded border overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-gray-50">
          <tr>
            <th class="text-left p-2">#</th>
            <th class="text-left p-2">标题</th>
            <th class="text-left p-2">状态</th>
            <th class="text-left p-2">优先级</th>
            <th class="text-left p-2">站点</th>
            <th class="text-left p-2">处理人</th>
            <th class="text-left p-2">报单人</th>
            <th class="text-left p-2">创建时间</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="tk in regressionList" :key="tk.id" class="border-t hover:bg-gray-50">
            <td class="p-2">{{ tk.number }}</td>
            <td class="p-2 max-w-[320px] truncate" :title="tk.title">{{ tk.title }}</td>
            <td class="p-2"><span :class="ticketStatusClass(tk.status)">{{ tk.status }}</span></td>
            <td class="p-2">{{ tk.priority }}</td>
            <td class="p-2">{{ tk.site }}</td>
            <td class="p-2">{{ tk.assignee || '-' }}</td>
            <td class="p-2">{{ tk.reporter || tk.submittedByName || '-' }}</td>
            <td class="p-2">{{ formatTime(tk.createdAt) }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="bg-white rounded-lg border p-4">
      <h2 class="text-lg font-medium mb-3">待回归按处理人分布</h2>
      <div class="w-full h-[320px]">
        <v-chart v-if="hasRegData" :option="regByAssignee" autoresize class="w-full h-full" />
        <div v-else class="text-sm text-gray-500 py-12 text-center">暂无数据</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart, PieChart } from 'echarts/charts'
import { TitleComponent, TooltipComponent, LegendComponent, GridComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import dayjs from 'dayjs'
import { useData } from '../composables/useData'
import { countBy } from '../utils'

use([CanvasRenderer, BarChart, PieChart, TitleComponent, TooltipComponent, LegendComponent, GridComponent])

const { data, closedTickets, fetchData } = useData()
onMounted(fetchData)

const ticketStatusClass = (s: string) => {
  if (s === '已关闭') return 'text-green-700 bg-green-100 px-2 py-0.5 rounded text-xs'
  if (s === '待回归') return 'text-orange-700 bg-orange-100 px-2 py-0.5 rounded text-xs'
  if (s === '待处理') return 'text-red-700 bg-red-100 px-2 py-0.5 rounded text-xs'
  if (s === '处理中') return 'text-blue-700 bg-blue-100 px-2 py-0.5 rounded text-xs'
  return 'text-gray-700 bg-gray-100 px-2 py-0.5 rounded text-xs'
}

const pendingRegression = computed(() => data.value?.tickets.filter(t=>t.status==='待回归')||[])
const pendingHandle = computed(() => data.value?.tickets.filter(t=>t.status==='待处理')||[])
const regressionList = computed(() => [...pendingRegression.value, ...pendingHandle.value].sort((a,b)=>(a.number||0)-(b.number||0)))

const formatTime = (ts:number) => dayjs(ts).format('YYYY-MM-DD HH:mm')

const regByAssignee = computed(() => {
  const c = countBy(pendingRegression.value, t=> (t.assignee && String(t.assignee).trim()) || '未分配')
  const entries = Object.entries(c).filter(e=>e[0]!=='未分配').sort((a,b)=>b[1]-a[1])
  const names = entries.map(e=>e[0])
  const values = entries.map(e=>e[1])
  return {
    tooltip:{ trigger:'axis' as const },
    grid:{ left:30, right:20, bottom:40, top:20, containLabel:true },
    xAxis:{ type:'category' as const, data: names, axisLabel:{ rotate:30, interval:0 } },
    yAxis:{ type:'value' as const, minInterval:1 },
    series:[{ type:'bar' as const, data: values, itemStyle:{ color:'#f59e0b' }, barMaxWidth:40 }]
  }
})

const hasRegData = computed(() => (regByAssignee.value.xAxis.data as any[]).length > 0)
</script>
