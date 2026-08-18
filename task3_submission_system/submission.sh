#!/bin/bash

SUBMISSIONS_DIR="submissions"
LOG_FILE="submission_log.txt"

show_menu() {
    echo ""
    echo "===== Secure Student Submission System ====="
    echo "1) Submit an assignment"
    echo "2) View all submissions"
    echo "3) Login simulation"
    echo "4) Bye (exit)"
    echo "=============================================="
}

while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
        1) echo "[stub] submit assignment" ;;
        2) echo "[stub] view submissions" ;;
        3) echo "[stub] login simulation" ;;
        4) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
