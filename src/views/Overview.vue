<template>
  <div class="space-y-6">
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <div class="bg-white rounded-lg border p-4">
        <div class="text-sm text-gray-500">任务总数</div>
        <div class="text-2xl font-semibold">{{ tasksCount }}</div>
      </div>
      <div class="bg-white rounded-lg border p-4">
        <div class="text-sm text-gray-500">进行中（开发中/设计中）</div>
        <div class="text-2xl font-semibold">{{ inProgress }}</div>
      </div>
      <div class="bg-white rounded-lg border p-4">
        <div class="text-sm text-gray-500">测试中</div>
        <div class="text-2xl font-semibold">{{ testing }}</div>
      </div>
      <div class="bg-white rounded-lg border p-4">
        <div class="text-sm text-gray-500">已上线</div>
        <div class="text-2xl font-semibold">{{ launched }}</div>
      </div>
      <div class="bg-white rounded-lg border p-4">
        <div class="text-sm text-gray-500">待回归+待处理（工单）</div>
        <div class="text-2xl font-semibold">{{ openCount }}</div>
      </div>
      <div class="bg-white rounded-lg border p-4">
        <div class="text-sm text-gray-500">已关闭（工单）</div>
        <div class="text-2xl font-semibold">{{ closedCount }}</div>
      </div>
      <div class="bg-white rounded-lg border p-4">
        <div class="text-sm text-gray-500">工单总数</div>
        <div class="text-2xl font-semibold">{{ ticketsCount }}</div>
      </div>
      <div class="bg-white rounded-lg border p-4">
        <div class="text-sm text-gray-500">1JJ/JJB</div>
        <div class="text-lg font-medium">{{ siteStats }}</div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <div class="bg-white rounded-lg border p-4">
        <h2 class="text-lg font-medium mb-3">任务状态分布</h2>
        <v-chart :option="statusPie" :autoresize="false" class="w-full h-[260px]" />
      </div>
      <div class="bg-white rounded-lg border p-4">
        <h2 class="text-lg font-medium mb-3">按站点/类型统计</h2>
        <div class="w-full h-[260px] overflow-hidden">
          <v-chart :option="siteTypeBar" :autoresize="false" class="w-full h-full" />
        </div>
      </div>
    </div>

    <div class="bg-white rounded-lg border p-4">
      <h2 class="text-lg font-medium mb-3">环节进度概览（已完成占比）</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
        <div v-for="t in tasksWithMeta" :key="t.id" class="border rounded p-3">
          <div class="text-sm font-medium mb-1 truncate" :title="t.name">{{ t.name }}</div>
          <div class="text-xs text-gray-500 mb-2">{{ t.site }} · {{ t.status }}</div>
          <div class="flex items-center gap-2">
            <div class="h-2 bg-gray-200 flex-1 rounded">
              <div class="h-2 bg-green-500 rounded" :style="{ width: t.completion + '%' }"></div>
            </div>
            <div class="text-xs w-10 text-right">{{ t.completion }}%</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, BarChart } from 'echarts/charts'
import { TitleComponent, TooltipComponent, LegendComponent, GridComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { useData } from '../composables/useData'
import { countBy } from '../utils'

use([CanvasRenderer, PieChart, BarChart, TitleComponent, TooltipComponent, LegendComponent, GridComponent])

const { data, tasksWithMeta, openTickets, closedTickets, fetchData } = useData()

onMounted(fetchData)

const tasksCount = computed(() => data.value?.tasks?.length ?? 0)
const ticketsCount = computed(() => data.value?.tickets?.length ?? 0)
const openCount = computed(() => openTickets.value?.length ?? 0)
const closedCount = computed(() => closedTickets.value?.length ?? 0)
const inProgress = computed(() => data.value?.tasks.filter(t => t.status === '开发中' || t.status === '设计中').length || 0)
const testing = computed(() => data.value?.tasks.filter(t => t.status === '测试中').length || 0)
const launched = computed(() => data.value?.tasks.filter(t => t.status === '已上线').length || 0)

const siteStats = computed(() => {
  const s = countBy(data.value?.tasks || [], t => t.site)
  return Object.entries(s).map(([k,v]) => `${k}:${v}`).join(' · ')
})

const statusPie = computed(() => {
  const s = countBy(data.value?.tasks || [], t => t.status)
  const entries = Object.entries(s)
  return {
    tooltip: { trigger: 'item' as const },
    animation: false,
    series: [{
      type: 'pie' as const,
      radius: '55%',
      center: ['50%', '50%'],
      data: entries.map(([name, value]) => ({ name, value })),
      silent: true
    }]
  }
})

const siteTypeBar = computed(() => {
  const sites = ['1JJ', 'JJB']
  const tasks = data.value?.tasks || []
  const types = ['活动页面', '功能开发']
  const dataSeries = types.map(type => ({
    name: type,
    type: 'bar' as const,
    barWidth: 24,
    data: sites.map(site => tasks.filter(t => t.site === site && t.type === type).length),
    silent: true
  }))
  return {
    tooltip: { trigger: 'axis' as const },
    legend: { data: types },
    animation: false,
    xAxis: { type: 'category' as const, data: sites, axisTick: { alignWithLabel: true } },
    yAxis: { type: 'value' as const, minInterval: 1, splitNumber: 2, max: 6 },
    series: dataSeries,
    grid: { left: 20, right: 12, bottom: 20, top: 36, containLabel: true }
  }
})
</script>
