#!/bin/bash

LOG_FILE="system_monitor_log.txt"

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

while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
        1) cpu_mem_usage ;;
        2) top_processes ;;
        3) echo "[stub] terminate process" ;;
        4) echo "[stub] manage logs" ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
