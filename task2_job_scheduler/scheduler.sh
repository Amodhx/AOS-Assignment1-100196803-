#!/bin/bash

QUEUE_FILE="job_queue.txt"
COMPLETED_FILE="completed_jobs.txt"
LOG_FILE="scheduler_log.txt"
TIME_QUANTUM=5

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

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
    log_action "Job submitted - Student: $sid, Job: $jname, ExecTime: ${exectime}s, Priority: $priority"
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

view_completed() {
    if [ ! -f "$COMPLETED_FILE" ] || [ ! -s "$COMPLETED_FILE" ]; then
        echo "No completed jobs yet."
        return
    fi
    echo "--- Completed Jobs ---"
    printf "%-12s %-15s %-12s %-20s\n" "StudentID" "JobName" "SchedType" "CompletedAt"
    while IFS='|' read -r sid jname schedtype ts; do
        printf "%-12s %-15s %-12s %-20s\n" "$sid" "$jname" "$schedtype" "$ts"
    done < "$COMPLETED_FILE"
}

round_robin() {
    echo "--- Running Round Robin (quantum = ${TIME_QUANTUM}s) ---"
    log_action "Started Round Robin scheduling"

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
            log_action "Job completed (Round Robin) - Student: $sid, Job: $jname"
        else
            echo "Running $jname ($sid) for ${TIME_QUANTUM}s (remaining after: $((remaining - TIME_QUANTUM))s)"
            sleep "$TIME_QUANTUM"
            new_remaining=$((remaining - TIME_QUANTUM))
            queue+=("${sid}|${jname}|${new_remaining}|${priority}")
        fi
    done

    echo "Round Robin scheduling complete."
    log_action "Finished Round Robin scheduling"
}

priority_schedule() {
    echo "--- Running Priority Scheduling (1=highest) ---"
    log_action "Started Priority scheduling"

    sort -t'|' -k4,4n "$QUEUE_FILE" -o "$QUEUE_FILE"
    mapfile -t jobs < "$QUEUE_FILE"
    > "$QUEUE_FILE"

    for entry in "${jobs[@]}"; do
        IFS='|' read -r sid jname exectime priority <<< "$entry"
        echo "Running $jname ($sid) - priority $priority - for ${exectime}s -> COMPLETED"
        sleep "$exectime"
        echo "${sid}|${jname}|Priority|$(date '+%Y-%m-%d %H:%M:%S')" >> "$COMPLETED_FILE"
        log_action "Job completed (Priority) - Student: $sid, Job: $jname, Priority: $priority"
    done

    echo "Priority scheduling complete."
    log_action "Finished Priority scheduling"
}

process_queue() {
    if [ ! -f "$QUEUE_FILE" ] || [ ! -s "$QUEUE_FILE" ]; then
        echo "No pending jobs to schedule."
        return
    fi

    read -p "Choose scheduling type - (R)ound Robin or (P)riority: " sched_choice
    case $sched_choice in
        R|r) round_robin ;;
        P|p) priority_schedule ;;
        *) echo "Invalid choice." ;;
    esac
}

while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
        1) view_pending ;;
        2) submit_job ;;
        3) process_queue ;;
        4) view_completed ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
