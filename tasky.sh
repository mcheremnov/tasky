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

add_task() {
  if [ -z "$1" ]; then
    echo "Error: Task description cannot be empty."
    return 1
  fi
  
  local task_id=$(date +%s)
  local new_task='{"id":'$task_id', "task": "'$1'", "done": false}'
  
  # Load existing tasks, append the new one, and save
  load_tasks | jq -s '.[] + ['"$new_task"']' | save_tasks
  
  echo "Task added successfully! ID: $task_id"
}

show_help() {
  echo "Usage: tasky [command] [arguments]"
  echo ""
  echo "Available commands:"
  echo "  add \"Task description\" - Add a new task"
  echo "  help - Show this help message"
}

case "$1" in
  add) add_task "$2" ;;
  help) show_help ;;
  *) echo "Unknown command. Use 'help' to see available commands."
esac
