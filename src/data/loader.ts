import type { RootData, Account, Task, Ticket } from '../types/data'

export async function loadData(): Promise<RootData> {
  const res = await fetch('/data/task.json')
  if (!res.ok) throw new Error('Failed to load data/task.json')
  return res.json()
}

export function buildAccountMap(accounts: Account[]) {
  const map = new Map<string, Account>()
  for (const a of accounts) map.set(a.id, a)
  return map
}

export function getTaskCompletion(task: Task) {
  const enabled = Object.values(task.rings).filter(r => r.enabled)
  if (enabled.length === 0) return 0
  const done = enabled.filter(r => r.progress === '已完成' || r.progress === '已通过').length
  return Math.round((done / enabled.length) * 100)
}

export function getFirstCompletedAt(task: Task) {
  const times = Object.values(task.rings)
    .filter(r => r.enabled && r.completedAt)
    .map(r => r.completedAt as number)
  if (times.length === 0) return null
  return Math.min(...times)
}

export function getRingNames() {
  return ['product', 'design', 'frontend', 'backend', 'ios', 'android', 'qa'] as const
}

export function isOpenTicket(t: Ticket) {
  return t.status === '待回归' || t.status === '待处理'
}
