#!/bin/bash

LOG_FILE="system_monitor_log.txt"
ARCHIVE_DIR="ArchiveLogs"
PROTECTED_PIDS="1"
PROTECTED_NAMES="init systemd sshd"

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

show_menu() {
    echo ""
    echo "===== Smart Campus IoT Device Manager ====="
    echo "1) Show CPU/Memory usage"
    echo "2) Show top 10 memory-consuming processes"
    echo "3) Terminate a process"
    echo "4) Manage sensor logs (inspect/archive)"
    echo "5) Bye (exit)"
    echo "============================================"
}

cpu_mem_usage() {
    echo "--- Memory Usage ---"
    free -h
    echo ""
    echo "--- CPU Usage ---"
    top -bn1 | head -n 5
    log_action "Viewed CPU/Memory usage"
}

top_processes() {
    echo "--- Top 10 Memory-Consuming Processes ---"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 11
    log_action "Viewed top 10 memory-consuming processes"
}

terminate_process() {
    read -p "Enter PID to terminate: " pid

    if ! ps -p "$pid" > /dev/null 2>&1; then
        echo "No such process."
        return
    fi

    pname=$(ps -p "$pid" -o comm=)

    if [[ " $PROTECTED_PIDS " == *" $pid "* ]] || [[ " $PROTECTED_NAMES " == *" $pname "* ]]; then
        echo "Refused: PID $pid ($pname) is a protected/critical process."
        log_action "Refused termination attempt on protected process PID $pid ($pname)"
        return
    fi

    read -p "Are you sure you want to kill PID $pid ($pname)? (Y/N): " confirm
    if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
        kill "$pid" && echo "Process $pid terminated."
        log_action "Terminated process PID $pid ($pname)"
    else
        echo "Cancelled."
        log_action "Cancelled termination of PID $pid ($pname)"
    fi
}

manage_logs() {
    read -p "Enter path to sensor log directory: " logdir

    if [ ! -d "$logdir" ]; then
        echo "Directory does not exist."
        return
    fi

    echo "--- Disk usage of $logdir ---"
    du -sh "$logdir"
    du -ah "$logdir" | sort -rh | head -n 10

    echo ""
    echo "--- Files larger than 50MB ---"
    big_files=$(find "$logdir" -type f -size +50M)

    if [ -z "$big_files" ]; then
        echo "No files over 50MB found."
        log_action "Checked $logdir - no large files found"
        return
    fi

    echo "$big_files"
    mkdir -p "$ARCHIVE_DIR"

    for file in $big_files; do
        timestamp=$(date +%Y%m%d_%H%M%S)
        base=$(basename "$file")
        tar -czf "$ARCHIVE_DIR/${base}_${timestamp}.tar.gz" "$file"
        echo "Archived: $file -> $ARCHIVE_DIR/${base}_${timestamp}.tar.gz"
        log_action "Archived large log file $file into $ARCHIVE_DIR"
    done

    archive_size=$(du -sb "$ARCHIVE_DIR" | cut -f1)
    if [ "$archive_size" -gt 1073741824 ]; then
        echo "WARNING: $ARCHIVE_DIR has exceeded 1GB!"
        log_action "WARNING - ArchiveLogs exceeded 1GB"
    fi
}

exit_program() {
    read -p "Are you sure you want to exit? (Y/N): " confirm
    if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
        log_action "User exited the system."
        echo "Goodbye!"
        exit 0
    fi
}

while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
        1) cpu_mem_usage ;;
        2) top_processes ;;
        3) terminate_process ;;
        4) manage_logs ;;
        5) exit_program ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
