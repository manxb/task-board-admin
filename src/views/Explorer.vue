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
        <option value="待回归">待回归</option>
        <option value="待处理">待处理</option>
        <option value="已关闭">已关闭</option>
        <option value="处理中">处理中</option>
      </select>
      <select v-model="filters.assignee" class="border rounded px-2 py-1 text-sm">
        <option value="">全部处理人</option>
        <option v-for="n in ticketAssignees" :key="n" :value="n">{{ n }}</option>
      </select>
      <input v-model="filters.keyword" placeholder="搜索标题/任务名" class="border rounded px-2 py-1 text-sm flex-1 min-w-[200px]" />
      <button @click="exportCsv" class="px-3 py-1 border rounded text-sm hover:bg-gray-50">导出 CSV</button>
    </div>

    <div class="bg-white rounded border overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-gray-50">
          <tr>
            <th class="text-left p-2">#</th>
            <th class="text-left p-2">工单标题</th>
            <th class="text-left p-2">状态</th>
            <th class="text-left p-2">优先级</th>
            <th class="text-left p-2">站点</th>
            <th class="text-left p-2">处理人</th>
            <th class="text-left p-2">报单人</th>
            <th class="text-left p-2">任务</th>
            <th class="text-left p-2">更新时间</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="tk in filteredTickets" :key="tk.id" class="border-t hover:bg-gray-50">
            <td class="p-2">{{ tk.number }}</td>
            <td class="p-2 max-w-[320px]">
              <a v-if="hasAttachments(tk)" :href="(tk.attachments as any)[0].url" target="_blank" rel="noopener noreferrer" class="text-black-600 hover:text-blue-800 hover:underline text-left truncate max-w-[320px] inline-block" :title="tk.title">{{ tk.title }}</a>
              <span v-else class="truncate max-w-[320px] inline-block text-gray-600" :title="tk.title">{{ tk.title }}</span>
            </td>
            <td class="p-2"><span :class="ticketStatusClass(tk.status)">{{ tk.status }}</span></td>
            <td class="p-2">{{ tk.priority }}</td>
            <td class="p-2">{{ tk.site }}</td>
            <td class="p-2">{{ tk.assignee || '-' }}</td>
            <td class="p-2">{{ tk.reporter || tk.submittedByName || '-' }}</td>
            <td class="p-2 max-w-[240px] truncate" :title="taskName(tk.taskId)">{{ taskName(tk.taskId) }}</td>
            <td class="p-2">{{ formatTime(tk.updatedAt) }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="bg-white rounded border overflow-x-auto">
      <h2 class="text-lg font-medium p-3 border-b">任务原始数据</h2>
      <table class="w-full text-xs">
        <thead class="bg-gray-50">
          <tr>
            <th class="text-left p-2">任务</th>
            <th class="text-left p-2">站点</th>
            <th class="text-left p-2">类型</th>
            <th class="text-left p-2">状态</th>
            <th class="text-left p-2">Live</th>
            <th class="text-left p-2">活动开始</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="t in tasksWithMeta" :key="t.id" class="border-t">
            <td class="p-2 max-w-[240px] truncate">{{ t.name }}</td>
            <td class="p-2">{{ t.site }}</td>
            <td class="p-2">{{ t.type }}</td>
            <td class="p-2"><span :class="taskStatusClass(t.status)">{{ t.status }}</span></td>
            <td class="p-2">{{ t.live ? '是' : '否' }}</td>
            <td class="p-2">{{ t.activityStart || '-' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive } from 'vue'
import dayjs from 'dayjs'
import { useData } from '../composables/useData'
import { countBy } from '../utils'

const { data, tasksWithMeta, fetchData } = useData()
onMounted(fetchData)

const filters = reactive({ site:'', status:'', assignee:'', keyword:'' })

const ticketStatusClass = (s: string) => {
  if (s === '已关闭') return 'text-green-700 bg-green-100 px-2 py-0.5 rounded text-xs'
  if (s === '待回归') return 'text-orange-700 bg-orange-100 px-2 py-0.5 rounded text-xs'
  if (s === '待处理') return 'text-red-700 bg-red-100 px-2 py-0.5 rounded text-xs'
  if (s === '处理中') return 'text-blue-700 bg-blue-100 px-2 py-0.5 rounded text-xs'
  return 'text-gray-700 bg-gray-100 px-2 py-0.5 rounded text-xs'
}

const taskStatusClass = (s: string) => {
  if (s === '已上线') return 'text-green-700 bg-green-100 px-2 py-0.5 rounded text-xs'
  if (s === '测试中') return 'text-orange-700 bg-orange-100 px-2 py-0.5 rounded text-xs'
  if (s === '开发中') return 'text-blue-700 bg-blue-100 px-2 py-0.5 rounded text-xs'
  if (s === '设计中') return 'text-purple-700 bg-purple-100 px-2 py-0.5 rounded text-xs'
  return 'text-gray-700 bg-gray-100 px-2 py-0.5 rounded text-xs'
}

const formatTime = (ts:number) => dayjs(ts).format('YYYY-MM-DD HH:mm')

const ticketAssignees = computed(() => {
  const c = countBy(data.value?.tickets||[], t=>t.assignee||'-')
  return Object.keys(c).filter(k=>k!=='-').sort()
})

const taskMap = computed(() => {
  const m = new Map<string,string>()
  for (const t of data.value?.tasks||[]) m.set(t.id, t.name)
  return m
})

const taskName = (id:string) => taskMap.value.get(id) || id

const statusOrder: Record<string, number> = {
  '待处理': 1,
  '处理中': 2,
  '待回归': 3,
  '已关闭': 4
}

const hasAttachments = (tk: any) => Array.isArray(tk.attachments) && tk.attachments.length > 0

const filteredTickets = computed(() => {
  return (data.value?.tickets||[]).filter(tk => {
    if (filters.site && tk.site !== filters.site) return false
    if (filters.status && tk.status !== filters.status) return false
    if (filters.assignee && (tk.assignee||'-') !== filters.assignee) return false
    if (filters.keyword) {
      const kw = filters.keyword
      if (!(tk.title||'').includes(kw) && !(taskName(tk.taskId)||'').includes(kw)) return false
    }
    return true
  }).sort((a,b) => {
    const sa = statusOrder[a.status] || 99
    const sb = statusOrder[b.status] || 99
    if (sa !== sb) return sa - sb
    return (b.updatedAt||0) - (a.updatedAt||0)
  })
})

function exportCsv() {
  const rows = filteredTickets.value
  const headers = ['number','title','status','priority','site','assignee','reporter','taskName','updatedAt']
  const csv = [headers.join(',')]
  for (const r of rows) {
    csv.push(headers.map(h=>{
      let v: any
      if (h==='taskName') v = taskName(r.taskId)
      else if (h==='updatedAt') v = formatTime(r.updatedAt)
      else if (h==='reporter') v = r.reporter || r.submittedByName || ''
      else if (h==='assignee') v = r.assignee || ''
      else v = (r as any)[h] ?? ''
      const s = String(v).replace(/"/g,'""')
      return '"' + s + '"'
    }).join(','))
  }
  const blob = new Blob([csv.join('\n')], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'tickets.csv'
  a.click()
  URL.revokeObjectURL(url)
}
</script>
