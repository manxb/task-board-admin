-- MySQL schema derived from data/task.json

CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(64) PRIMARY KEY,
  username VARCHAR(64) NOT NULL,
  name VARCHAR(64) NOT NULL,
  role VARCHAR(32) NOT NULL,
  admin TINYINT(1) NOT NULL DEFAULT 0,
  active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS tasks (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  site VARCHAR(32) NOT NULL,
  type VARCHAR(64) NOT NULL,
  live TINYINT(1) NOT NULL DEFAULT 0,
  migration_review TINYINT(1) NOT NULL DEFAULT 0,
  template VARCHAR(255),
  description TEXT,
  date DATE,
  activity_start DATE,
  sheet VARCHAR(512),
  axure VARCHAR(512),
  zeplin VARCHAR(512),
  prototype_missing TINYINT(1) DEFAULT 0,
  product VARCHAR(64),
  design VARCHAR(64),
  frontend VARCHAR(64),
  backend VARCHAR(64),
  ios VARCHAR(64),
  android VARCHAR(64),
  qa VARCHAR(64),
  status VARCHAR(32) NOT NULL,
  blocked TINYINT(1) NOT NULL DEFAULT 0,
  overdue JSON,
  design_missing TINYINT(1) DEFAULT 0,
  launched_at BIGINT,
  revision INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS task_rings (
  task_id VARCHAR(64) NOT NULL,
  ring VARCHAR(32) NOT NULL,
  progress VARCHAR(32) NOT NULL,
  completed_at BIGINT,
  blocked TINYINT(1) NOT NULL DEFAULT 0,
  reason TEXT,
  enabled TINYINT(1) NOT NULL DEFAULT 0,
  user_id VARCHAR(64),
  due VARCHAR(64),
  progress_percent INT,
  PRIMARY KEY (task_id, ring),
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS tickets (
  id VARCHAR(64) PRIMARY KEY,
  submitted_by_id VARCHAR(64),
  submitted_by_name VARCHAR(64),
  description TEXT,
  site VARCHAR(32),
  task_id VARCHAR(64),
  priority VARCHAR(16),
  evidence VARCHAR(512),
  regression_id VARCHAR(64),
  reporter_id VARCHAR(64),
  reporter VARCHAR(64),
  assignee VARCHAR(64),
  assignee_ids JSON,
  status VARCHAR(32) NOT NULL,
  fix_note TEXT,
  return_reason TEXT,
  close_category VARCHAR(64),
  close_category_note TEXT,
  title VARCHAR(512),
  close_request_status VARCHAR(64),
  close_request_reason TEXT,
  close_request_detail TEXT,
  close_request_related_ticket_id VARCHAR(64),
  close_request_review_date VARCHAR(64),
  close_requested_by_id VARCHAR(64),
  close_requested_by_name VARCHAR(64),
  deferred TINYINT(1) DEFAULT 0,
  deferred_reason TEXT,
  deferred_detail TEXT,
  next_review_date VARCHAR(64),
  special_close_reason TEXT,
  special_close_detail TEXT,
  special_close_related_ticket_id VARCHAR(64),
  number INT,
  revision INT NOT NULL DEFAULT 0,
  created_at BIGINT,
  updated_at BIGINT,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ticket_attachments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ticket_id VARCHAR(64) NOT NULL,
  url VARCHAR(512) NOT NULL,
  name VARCHAR(255),
  type VARCHAR(64),
  FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS logs (
  id BIGINT PRIMARY KEY,
  task_id VARCHAR(64),
  ticket_id VARCHAR(64),
  actor_id VARCHAR(64),
  actor_name VARCHAR(64),
  action VARCHAR(64),
  detail JSON,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL,
  FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
