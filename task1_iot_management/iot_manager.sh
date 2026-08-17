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

while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
        1) echo "[stub] CPU/memory usage" ;;
        2) echo "[stub] top 10 processes" ;;
        3) echo "[stub] terminate process" ;;
        4) echo "[stub] manage logs" ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
