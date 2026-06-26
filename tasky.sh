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

list_tasks() {
  load_tasks | jq . > "$DB_FILE" # Refresh tasks from file
  if [ ! -s "$DB_FILE" ]; then
    echo "No tasks found."
    return 0
  fi
  
  # Display tasks in a formatted way (can be improved with more complex formatting)
  echo "Tasks:"
  load_tasks | jq '.[] | "\(.id): \(.task) - Done: \(.done)"'
}

complete_task() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a task ID."
    return 1
  fi
  
  # Find the task and set done to true
  load_tasks | jq ".[] | select(.id == $1) | .done = true" > tmp.json && mv tmp.json "$DB_FILE"
  
  if [ ! -s "$DB_FILE" ]; then
    echo "Task with ID $1 not found."
    return 1
  fi
  
  echo "Task $1 marked as complete."
}

show_help() {
  echo "Usage: tasky [command] [arguments]"
  echo ""
  echo "Available commands:"
  echo "  add \"Task description\" - Add a new task"
  echo "  list - List all tasks"
  echo "  help - Show this help message"
  echo "  done <id> - Mark a task as complete"
}

case "$1" in
  add) add_task "$2" ;;
  list) list_tasks ;;
  help) show_help ;;
  *) echo "Unknown command. Use 'help' to see available commands."
esac