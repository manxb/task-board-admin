import { ref, computed } from 'vue'
import { loadData, buildAccountMap, getTaskCompletion, getFirstCompletedAt, isOpenTicket } from '../data/loader'
import type { RootData, Task } from '../types/data'

const data = ref<RootData | null>(null)
const loading = ref(false)
const error = ref<Error | null>(null)

export function useData() {
  const accountMap = computed(() => data.value ? buildAccountMap(data.value.accounts) : new Map())

  const tasksWithMeta = computed(() => {
    if (!data.value) return [] as Array<Task & { completion: number, firstCompletedAt: number | null }>
    return data.value.tasks.map(t => ({
      ...t,
      completion: getTaskCompletion(t),
      firstCompletedAt: getFirstCompletedAt(t)
    }))
  })

  const openTickets = computed(() => (data.value?.tickets || []).filter(isOpenTicket))
  const closedTickets = computed(() => (data.value?.tickets || []).filter(t => t.status === '已关闭'))

  async function fetchData() {
    loading.value = true
    error.value = null
    try {
      data.value = await loadData()
    } catch (e) {
      error.value = e as Error
    } finally {
      loading.value = false
    }
  }

  return {
    data,
    loading,
    error,
    accountMap,
    tasksWithMeta,
    openTickets,
    closedTickets,
    fetchData
  }
}
