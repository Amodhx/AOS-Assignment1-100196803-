# AOS Assignment 1 — Operating System Automation Scripts
**Student ID:** 100196803
**Module:** Advanced Operating Systems

This repository contains three menu-driven scripts developed for AOS
Assignment 1, along with logging output, sample data, and the written report.

---

## Requirements

- Ubuntu / any Linux distribution with `bash`
- `python3` (for Task 3 hashing and login-attempt tracking)
- Standard coreutils: `ps`, `top`, `free`, `du`, `find`, `tar`, `stat`

No external packages need to be installed — everything used is part of a
standard Ubuntu installation.

---

## Repository Structure

```
AOS-Assignment1-100196803/
├── task1_iot_management/
│   └── iot_manager.sh          # Task 1 — IoT device management
├── task2_job_scheduler/
│   └── scheduler.sh            # Task 2 — Research cluster job scheduler
├── task3_submission_system/
│   ├── submission.sh           # Task 3 — Submission & login menu (Bash)
│   ├── hash_utils.py           # Task 3 — SHA-256 duplicate detection (Python)
│   └── auth_utils.py           # Task 3 — Login attempt / lockout logic (Python)
├── docs/
│   └── screenshots/            # Execution evidence used in the report
├── report/
│   └── AOS_Assignment1_Report.docx
├── .gitignore
└── README.md
```

---

## Task 1 — Smart Campus IoT Device Management

```bash
cd task1_iot_management
chmod +x iot_manager.sh
./iot_manager.sh
```

Menu options:
1. Show CPU/Memory usage
2. Show top 10 memory-consuming processes
3. Terminate a process (protected PIDs/names are refused automatically)
4. Manage sensor logs — inspects a directory, archives files >50MB into
   `ArchiveLogs/`, and warns if `ArchiveLogs/` exceeds 1GB
5. Bye (exit, with Y/N confirmation)

All actions are logged with timestamps to `system_monitor_log.txt`, created
in the same folder the script is run from.

---

## Task 2 — Research Cluster Job Scheduler

```bash
cd task2_job_scheduler
chmod +x scheduler.sh
./scheduler.sh
```

Menu options:
1. View pending jobs
2. Submit a job request (student ID, job name, execution time, priority 1–10)
3. Process job queue — choose **R**ound Robin (5-second time quantum) or
   **P**riority (priority 1 runs first)
4. View completed jobs
5. Exit (with Y/N confirmation)

Pending jobs are stored in `job_queue.txt`, completed jobs in
`completed_jobs.txt`, and every event is timestamped into
`scheduler_log.txt`.

---

## Task 3 — Secure Submission & Authentication System

```bash
cd task3_submission_system
chmod +x submission.sh
./submission.sh
```

Menu options:
1. Submit an assignment — only `.pdf`/`.docx` accepted, max 5MB, duplicate
   content rejected (SHA-256 hash comparison via `hash_utils.py`)
2. View all submissions
3. Simulate a login attempt — 3 consecutive failures locks the account;
   two attempts within 60 seconds are flagged as suspicious
   (`auth_utils.py`)
4. Bye (exit, with Y/N confirmation)

Accepted files are copied into `submissions/`. All submission and login
events are timestamped into `submission_log.txt`. Hashes are stored in
`submission_hashes.json`; login attempt history is stored in
`login_attempts.json`.

---

## Git Workflow Used

Each task was developed on its own feature branch
(`task1-iot-management`, `task2-job-scheduler`, `task3-submission-system`)
and merged into `main` once complete. Commits follow a
`feat:` / `fix:` / `docs:` / `chore:` convention, with one commit per
working sub-feature to show clear development progression — run
`git log --oneline` to view the full history.

---

## Report

The written report (design justification, OS concept mapping, challenges,
execution evidence, and references) is in
[`report/AOS_Assignment1_Report.docx`](./report/AOS_Assignment1_Report.docx).
