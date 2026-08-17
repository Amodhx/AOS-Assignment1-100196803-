#!/bin/bash

LOG_FILE="system_monitor_log.txt"
PROTECTED_PIDS="1"
PROTECTED_NAMES="init systemd sshd"

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
}

top_processes() {
    echo "--- Top 10 Memory-Consuming Processes ---"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 11
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
        return
    fi

    read -p "Are you sure you want to kill PID $pid ($pname)? (Y/N): " confirm
    if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
        kill "$pid" && echo "Process $pid terminated."
    else
        echo "Cancelled."
    fi
}

while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
        1) cpu_mem_usage ;;
        2) top_processes ;;
        3) terminate_process ;;
        4) echo "[stub] manage logs" ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
