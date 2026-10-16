export interface User {
  id: string
  username: string
  name: string
  role: string
  admin: boolean
  active: boolean
}

export interface Account {
  id: string
  username: string
  name: string
  role: string
  admin: boolean
  active: boolean
}

export interface RingProgress {
  progress: string
  completedAt: number | null
  blocked: boolean
  reason: string
  enabled: boolean
  userId: string
  due: string
  progressPercent: number | null
}

export interface Rings {
  product: RingProgress
  design: RingProgress
  frontend: RingProgress
  backend: RingProgress
  ios: RingProgress
  android: RingProgress
  qa: RingProgress
}

export interface Task {
  id: string
  name: string
  site: string
  type: string
  rings: Rings
  live: boolean
  migrationReview: boolean
  template: string
  description: string
  date: string
  activityStart: string
  sheet: string
  axure: string
  zeplin: string
  prototypeMissing?: boolean
  product: string
  design: string
  frontend: string
  backend: string
  ios: string
  android: string
  qa: string
  status: string
  blocked: boolean
  overdue: any[]
  designMissing?: boolean
  launchedAt?: number
  revision: number
}

export interface TicketAttachment {
  url: string
  name: string
  type: string
}

export interface Ticket {
  id: string
  submittedById?: string
  submittedByName?: string
  description: string
  site: string
  taskId: string
  priority: string
  evidence: string
  regressionId?: string
  attachments?: TicketAttachment[]
  reporterId?: string
  assigneeIds?: string[]
  status: string
  fixNote?: string
  returnReason?: string
  closeCategory?: string
  closeCategoryNote?: string
  title: string
  reporter?: string
  assignee?: string
  closeRequestStatus?: string
  closeRequestReason?: string
  closeRequestDetail?: string
  closeRequestRelatedTicketId?: string
  closeRequestReviewDate?: string
  closeRequestedById?: string
  closeRequestedByName?: string
  deferred?: boolean
  deferredReason?: string
  deferredDetail?: string
  nextReviewDate?: string
  specialCloseReason?: string
  specialCloseDetail?: string
  specialCloseRelatedTicketId?: string
  number: number
  revision: number
  createdAt: number
  updatedAt: number
}

export interface RootData {
  user: User
  accounts: Account[]
  tasks: Task[]
  tickets: Ticket[]
}
