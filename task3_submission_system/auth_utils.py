#!/usr/bin/env python3
"""
Handles login attempt tracking, account lockout, and suspicious activity
detection for the submission system.
Usage:
    python3 auth_utils.py attempt <student_id> <success: true|false>
        -> returns one of: OK | LOCKED | SUSPICIOUS
"""

import sys
import json
import os
from datetime import datetime

ATTEMPTS_STORE = "login_attempts.json"
MAX_FAILED_ATTEMPTS = 3
SUSPICIOUS_WINDOW_SECONDS = 60


def load_store():
    if not os.path.exists(ATTEMPTS_STORE):
        return {}
    with open(ATTEMPTS_STORE, "r") as f:
        return json.load(f)


def save_store(store):
    with open(ATTEMPTS_STORE, "w") as f:
        json.dump(store, f, indent=2)


def main():
    if len(sys.argv) < 4:
        print("ERROR: missing arguments")
        sys.exit(1)

    student_id = sys.argv[2]
    success = sys.argv[3].lower() == "true"
    now = datetime.now()

    store = load_store()
    record = store.get(student_id, {"failed_count": 0, "locked": False, "history": []})

    if record.get("locked"):
        print("LOCKED")
        save_store(store)
        return

    record["history"].append(now.isoformat())
    record["history"] = record["history"][-5:]

    # Suspicious check: 2+ attempts within the time window
    suspicious = False
    if len(record["history"]) >= 2:
        t1 = datetime.fromisoformat(record["history"][-2])
        t2 = datetime.fromisoformat(record["history"][-1])
        if (t2 - t1).total_seconds() <= SUSPICIOUS_WINDOW_SECONDS:
            suspicious = True

    if success:
        record["failed_count"] = 0
        store[student_id] = record
        save_store(store)
        print("SUSPICIOUS" if suspicious else "OK")
        return

    record["failed_count"] += 1
    if record["failed_count"] >= MAX_FAILED_ATTEMPTS:
        record["locked"] = True
        store[student_id] = record
        save_store(store)
        print("LOCKED")
        return

    store[student_id] = record
    save_store(store)
    print("SUSPICIOUS" if suspicious else "OK")


if __name__ == "__main__":
    main()
