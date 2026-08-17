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

submit_job() {
    read -p "Enter student ID: " sid
    read -p "Enter job name: " jname
    read -p "Enter estimated execution time (seconds): " exectime
    read -p "Enter priority (1=highest, 10=lowest): " priority

    if ! [[ "$exectime" =~ ^[0-9]+$ ]]; then
        echo "Invalid execution time."
        return
    fi
    if ! [[ "$priority" =~ ^[0-9]+$ ]] || [ "$priority" -lt 1 ] || [ "$priority" -gt 10 ]; then
        echo "Priority must be a number between 1 and 10."
        return
    fi

    echo "${sid}|${jname}|${exectime}|${priority}" >> "$QUEUE_FILE"
    echo "Job submitted: $jname for student $sid"
}

view_pending() {
    if [ ! -f "$QUEUE_FILE" ] || [ ! -s "$QUEUE_FILE" ]; then
        echo "No pending jobs."
        return
    fi
    echo "--- Pending Jobs ---"
    printf "%-12s %-15s %-10s %-8s\n" "StudentID" "JobName" "ExecTime" "Priority"
    while IFS='|' read -r sid jname exectime priority; do
        printf "%-12s %-15s %-10s %-8s\n" "$sid" "$jname" "$exectime" "$priority"
    done < "$QUEUE_FILE"
}

round_robin() {
    if [ ! -f "$QUEUE_FILE" ] || [ ! -s "$QUEUE_FILE" ]; then
        echo "No pending jobs to schedule."
        return
    fi

    echo "--- Running Round Robin (quantum = ${TIME_QUANTUM}s) ---"

    mapfile -t jobs < "$QUEUE_FILE"
    > "$QUEUE_FILE"
    queue=("${jobs[@]}")

    while [ "${#queue[@]}" -gt 0 ]; do
        entry="${queue[0]}"
        queue=("${queue[@]:1}")

        IFS='|' read -r sid jname remaining priority <<< "$entry"

        if [ "$remaining" -le "$TIME_QUANTUM" ]; then
            echo "Running $jname ($sid) for ${remaining}s -> COMPLETED"
            sleep "$remaining"
            echo "${sid}|${jname}|RoundRobin|$(date '+%Y-%m-%d %H:%M:%S')" >> "$COMPLETED_FILE"
        else
            echo "Running $jname ($sid) for ${TIME_QUANTUM}s (remaining after: $((remaining - TIME_QUANTUM))s)"
            sleep "$TIME_QUANTUM"
            new_remaining=$((remaining - TIME_QUANTUM))
            queue+=("${sid}|${jname}|${new_remaining}|${priority}")
        fi
    done

    echo "Round Robin scheduling complete."
}

while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
        1) view_pending ;;
        2) submit_job ;;
        3) round_robin ;;
        4) echo "[stub] view completed jobs" ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
