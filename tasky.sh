#!/usr/bin/env bash

# Constants
DB_FILE="./tasks.json"

# Function to load tasks from file
load_tasks() {
  if [ -f "$DB_FILE" ]; then
    cat "$DB_FILE"
  else
    echo "[]" >"$DB_FILE"
    echo "Created new task database at: $DB_FILE"
  fi
}

# Function to save tasks to file
save_tasks() {
  echo "$1" >"$DB_FILE"
}

# Initial setup - create directory and empty JSON array if not exists
mkdir -p "$(dirname "$DB_FILE")"
if [ ! -f "$DB_FILE" ]; then
  echo "[]" >"$DB_FILE"
fi

show_help() {
  echo "Usage: tasky [command] [arguments]"
  echo ""
  echo "Available commands will be added in future commits."
}

case "$1" in
help) show_help ;;
*) echo "Unknown command. Use 'help' to see available commands." ;;
esac
