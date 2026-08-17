#!/bin/bash

QUEUE_FILE="job_queue.txt"
COMPLETED_FILE="completed_jobs.txt"
LOG_FILE="scheduler_log.txt"
TIME_QUANTUM=5

show_menu() {
    echo ""
    echo "===== Research Cluster Job Scheduler ====="
    echo "1) View pending jobs"
    echo "2) Submit a job request"
    echo "3) Process job queue (Round Robin / Priority)"
    echo "4) View completed jobs"
    echo "5) Exit"
    echo "==========================================="
}

while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
        1) echo "[stub] view pending jobs" ;;
        2) echo "[stub] submit a job" ;;
        3) echo "[stub] process queue" ;;
        4) echo "[stub] view completed jobs" ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
