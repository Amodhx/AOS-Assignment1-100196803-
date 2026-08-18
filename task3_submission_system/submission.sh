#!/bin/bash

SUBMISSIONS_DIR="submissions"
LOG_FILE="submission_log.txt"
MAX_SIZE_MB=5

show_menu() {
    echo ""
    echo "===== Secure Student Submission System ====="
    echo "1) Submit an assignment"
    echo "2) View submissions"
    echo "3) Login simulation"
    echo "4) Bye (exit)"
    echo "=============================================="
}

submit_assignment() {
    read -p "Enter student ID: " sid
    read -p "Enter full path to file to submit: " filepath

    if [ ! -f "$filepath" ]; then
        echo "File not found."
        return
    fi

    ext="${filepath##*.}"
    if [[ "$ext" != "pdf" && "$ext" != "docx" ]]; then
        echo "Rejected: only .pdf and .docx files are accepted."
        return
    fi

    size_bytes=$(stat -c%s "$filepath")
    max_bytes=$((MAX_SIZE_MB * 1024 * 1024))
    if [ "$size_bytes" -gt "$max_bytes" ]; then
        echo "Rejected: file exceeds ${MAX_SIZE_MB}MB limit."
        return
    fi

    dup_check=$(python3 hash_utils.py check "$filepath")
    if [ "$dup_check" == "DUPLICATE" ]; then
        echo "Rejected: this file content has already been submitted."
        return
    fi

    mkdir -p "$SUBMISSIONS_DIR"
    filename=$(basename "$filepath")
    dest="${SUBMISSIONS_DIR}/${sid}_${filename}"
    cp "$filepath" "$dest"

    python3 hash_utils.py add "$filepath" "$sid" "$(basename "$dest")"
    echo "Submission accepted: $filename saved as $dest"
}

view_submissions() {
    if [ ! -d "$SUBMISSIONS_DIR" ] || [ -z "$(ls -A "$SUBMISSIONS_DIR" 2>/dev/null)" ]; then
        echo "No submissions yet."
        return
    fi
    echo "--- All Submissions ---"
    ls -lh "$SUBMISSIONS_DIR"
}
while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
        1) submit_assignment ;;
        2) "view_submissions" ;;
        3) echo "[stub] login simulation" ;;
        4) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
