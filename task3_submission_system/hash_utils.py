#!/usr/bin/env python3
"""
Handles duplicate-content detection for submissions using SHA-256 hashing.
Usage:
    python3 hash_utils.py check <filepath>
        -> prints "DUPLICATE" or "UNIQUE"
    python3 hash_utils.py add <filepath> <student_id> <saved_filename>
        -> records the hash after a successful submission
"""

import sys
import hashlib
import json
import os

HASH_STORE = "submission_hashes.json"


def compute_hash(filepath):
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            sha256.update(chunk)
    return sha256.hexdigest()


def load_store():
    if not os.path.exists(HASH_STORE):
        return {}
    with open(HASH_STORE, "r") as f:
        return json.load(f)


def save_store(store):
    with open(HASH_STORE, "w") as f:
        json.dump(store, f, indent=2)


def main():
    if len(sys.argv) < 3:
        print("ERROR: missing arguments")
        sys.exit(1)

    command = sys.argv[1]
    filepath = sys.argv[2]
    file_hash = compute_hash(filepath)
    store = load_store()

    if command == "check":
        if file_hash in store:
            print("DUPLICATE")
        else:
            print("UNIQUE")

    elif command == "add":
        student_id = sys.argv[3]
        saved_filename = sys.argv[4]
        store[file_hash] = {
            "student_id": student_id,
            "saved_filename": saved_filename
        }
        save_store(store)
        print("RECORDED")

    else:
        print("ERROR: unknown command")
        sys.exit(1)


if __name__ == "__main__":
    main()
