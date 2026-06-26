#!/usr/bin/env bash

# --- Constants ---
DB_DIR="$HOME/.local/share/tasky"
DB_FILE="$DB_DIR/tasks.json"
PASSWORD_FILE="$DB_DIR/password"
SALT=""

# --- Password Hashing ---
encrypt() {
  echo -n "$1" | sha256sum | awk '{print $1}'
}

decrypt() {
  echo -n "$1" | sha256sum | awk '{print $1}'
}

# --- Password Setup ---
if [ ! -f "$PASSWORD_FILE" ]; then
  # 1. Ask for the initial password (hidden)
  read -s -p "Please set a password for tasky: " PASSWORD
  echo ""
  
  if [ -z "$PASSWORD" ]; then
    echo "Error: Password cannot be empty. Exiting."
    exit 1
  fi

  # 2. Ask to confirm the password (hidden)
  read -s -p "Confirm your password: " PASSWORD_CONFIRM
  echo ""

  if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    echo "Error: Passwords do not match. Exiting."
    exit 1
  fi

  # 3. Save it if they match
  ENCRYPTED_PASSWORD=$(encrypt "$PASSWORD$SALT")
  mkdir -p "$DB_DIR"
  echo "$ENCRYPTED_PASSWORD" > "$PASSWORD_FILE"
  chmod 600 "$PASSWORD_FILE"
  echo "Password set successfully. Remember this password!"
fi

# --- Authentication with a 15-Minute Session ---
authenticate() {
  local session_file="/tmp/tasky_session_$USER"
  local timeout=900 # 15 minutes in seconds

  # Check if a valid session already exists
  if [ -f "$session_file" ]; then
    local last_auth
    last_auth=$(cat "$session_file")
    local now
    now=$(date +%s)
    
    # If the session hasn't expired yet, skip password entry
    if (( now - last_auth < timeout )); then
      # Refresh the session timestamp so it stays open while active
      date +%s > "$session_file"
      return 0
    fi
  fi

  # If no session or session expired, ask for password
  read -s -p "Enter your password: " PASSWORD
  echo ""
  
  if [ "$(encrypt "$PASSWORD$SALT")" = "$(cat "$PASSWORD_FILE")" ]; then
    # Create/update the session file with the current timestamp
    mkdir -p "$(dirname "$session_file")"
    date +%s > "$session_file"
    chmod 600 "$session_file"
    return 0
  else
    return 1
  fi
}

# --- Database Setup ---
mkdir -p "$DB_DIR"
if [ ! -f "$DB_FILE" ] || [ ! -s "$DB_FILE" ]; then
  echo "[]" > "$DB_FILE"
fi

update_db() {
  local tmp
  tmp=$(mktemp)
  jq "$1" "$DB_FILE" >"$tmp" && mv "$tmp" "$DB_FILE"
}

# --- Commands ---
add_task() {
  if [ -z "$1" ]; then
    echo "Error: Task description cannot be empty."
    return 1
  fi
  local id
  # Generates a random number between 100000 and 999999
  id=$(shuf -i 100000-999999 -n 1)
  
  update_db ". += [{id: $id, task: \"$1\", done: false}]"
  echo "Task added successfully! (ID: $id)"
}

list_tasks() {
  local filter_query count pending completed

  # 1. Determine jq filter and calculate stats based on the argument
  case "$1" in
    done|completed)
      filter_query='.[] | select(.done == true)'
      count=$(jq '[.[] | select(.done == true)] | length' "$DB_FILE")
      pending=$(jq '[.[] | select(.done == false)] | length' "$DB_FILE")
      completed=$count
      ;;
    pending|incomplete)
      filter_query='.[] | select(.done == false)'
      count=$(jq '[.[] | select(.done == false)] | length' "$DB_FILE")
      completed=$(jq '[.[] | select(.done == true)] | length' "$DB_FILE")
      pending=$count
      ;;
    all|"")
      filter_query='.[]'
      count=$(jq 'length' "$DB_FILE")
      pending=$(jq '[.[] | select(.done == false)] | length' "$DB_FILE")
      completed=$(jq '[.[] | select(.done == true)] | length' "$DB_FILE")
      ;;
  esac

  # 2. Print everything (Header + Data) into a single column command for perfect alignment
  (
    echo -e "ID\tSTATUS\tTASK"
    jq -r "$filter_query | \"\(.id | tostring | .[-6:])\t[\(if .done then \"✔\" else \" \" end)]\t\(.task)\"" "$DB_FILE"
  ) | column -t -s $'\t'

  # 3. Footer / Summary
  echo "Total tasks: $count"
  echo "Summary:     $pending pending, $completed completed"
}

complete_task() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a task ID."
    return 1
  fi
  update_db "map(if .id == ($1 | tonumber) then .done = true else . end)"
  echo "Task $1 marked as complete."
}

delete_task() {
  if ! authenticate; then
    echo "Authentication failed. Task not deleted."
    return 1
  fi
  if [ -z "$1" ]; then
    echo "Error: Please provide a task ID."
    return 1
  fi
  update_db "map(select(.id != ($1 | tonumber)))"
  echo "Task $1 deleted."
}

show_help() {
  echo "Usage: tasky [command] [arguments]"
  echo ""
  echo "Commands:"
  echo "  add \"Task text\"   Add a new task"
  echo "  list [done|pending|all] List tasks by status (default: all)"
  echo "  done <id>          Mark a task as complete"
  echo "  del <id>           Delete a task (requires authentication)"
  echo "  help               Show this help message"
}

# --- Global Authentication ---
if ! authenticate; then
  echo "Access denied. Incorrect password."
  exit 1
fi

# --- Router ---
case "$1" in
  add) add_task "$2" ;;
  list) list_tasks "$2" ;;
  done) complete_task "$2" ;;
  del) delete_task "$2" ;;
  help|"") show_help ;;
  *) echo "Unknown command. Use 'help' to see available commands." ;;
esac
