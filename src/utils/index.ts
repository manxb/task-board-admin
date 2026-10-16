export function countBy<T>(arr: T[], fn: (item: T) => string) {
  const res: Record<string, number> = {}
  for (const item of arr) {
    const key = fn(item)
    res[key] = (res[key] || 0) + 1
  }
  return res
}
