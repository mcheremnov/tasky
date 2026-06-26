#!/usr/bin/env bash

# --- Constants ---
DB_DIR="$HOME/.local/share/tasky"
DB_FILE="$DB_DIR/tasks.json"
PASSWORD_FILE="$DB_DIR/password"
SALT="DartMole"

# --- Colors ---
CYAN='\033[36m'
BLUE='\033[34m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Password Hashing ---
encrypt() {
  echo -n "$1" | sha256sum | awk '{print $1}'
}

# --- Password Setup ---
if [ ! -f "$PASSWORD_FILE" ]; then
  read -s -p "Please set a password for tasky: " PASSWORD
  echo ""
  if [ -z "$PASSWORD" ]; then
    echo "Error: Password cannot be empty. Exiting."
    exit 1
  fi

  read -s -p "Confirm your password: " PASSWORD_CONFIRM
  echo ""
  if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    echo "Error: Passwords do not match. Exiting."
    exit 1
  fi

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

  if [ -f "$session_file" ]; then
    local last_auth
    last_auth=$(cat "$session_file")
    local now
    now=$(date +%s)
    
    if (( now - last_auth < timeout )); then
      date +%s > "$session_file"
      return 0
    fi
  fi

  read -s -p "Enter your password: " PASSWORD
  echo ""
  
  if [ "$(encrypt "$PASSWORD$SALT")" = "$(cat "$PASSWORD_FILE")" ]; then
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

  local description="$1"
  local parent_id="${2:-null}"
  local id

  id=$(jq '[.[].id] | max // 0 | . + 1' "$DB_FILE")

  if [ "$parent_id" != "null" ]; then
    if ! jq -e ".[] | select(.id == ($parent_id | tonumber))" "$DB_FILE" >/dev/null; then
      echo "Error: Parent task ID $parent_id does not exist."
      return 1
    fi
  fi
  
  update_db ". += [{id: $id, task: \"$description\", done: false, parentId: $parent_id}]"
  
  if [ "$parent_id" != "null" ]; then
    echo "Subtask added successfully under Task $parent_id! (ID: $id)"
  else
    echo "Task added successfully! (ID: $id)"
  fi
}

list_tasks() {
  local count pending completed
  
  count=$(jq 'length' "$DB_FILE")
  pending=$(jq '[.[] | select(.done == false)] | length' "$DB_FILE")
  completed=$(jq '[.[] | select(.done == true)] | length' "$DB_FILE")

  # Print Header
  printf "${BOLD}${CYAN}%-4s %-8s %s${RESET}\n" "ID" "STATUS" "TASK"

  # Print Tasks
  jq -r --arg cyan "$CYAN" --arg blue "$BLUE" --arg reset "$RESET" '
    [.[] | select(.parentId == null)] as $parents |
    . as $all |
    $parents[] | . as $p |
    "\(.id)\t[\(if .done then $cyan + "✔" + $reset else " " end)]\t\(if .done then $cyan + .task + $reset else .task end)",
    ($all[] | select(.parentId == $p.id) | "  ↳ \(.id)\t[\(if .done then $cyan + "✔" + $reset else " " end)]\t\(if .done then $cyan + "  " + .task + $reset else "  " + .task end)")
  ' "$DB_FILE" | while IFS=$'\t' read -r id status task; do
    # Use printf to force fixed-width columns
    printf "%-4s %-8s %s\n" "$id" "$status" "$task"
  done | case "$1" in
    done|completed) grep -E "\[✔\]" ;;
    pending|incomplete) grep -v -E "\[✔\]" ;;
    *) cat ;;
  esac

  echo -e "\nTotal tasks: $count"
  echo -e "Summary:     ${CYAN}$pending${RESET} pending, ${BLUE}$completed${RESET} completed"
}

complete_task() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a task ID."
    return 1
  fi
  update_db "map(if .id == ($1 | tonumber) or .parentId == ($1 | tonumber) then .done = true else . end)"
  echo "Task $1 (and any subtasks) marked as complete."
}

delete_task() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a task ID."
    return 1
  fi
  update_db "map(select(.id != ($1 | tonumber) and .parentId != ($1 | tonumber)))"
  echo "Task $1 (and its subtasks if any) deleted."
}

show_greeting() {
  local hour
  hour=$(date +%H)
  local greeting="Hello"

  if (( hour >= 5 && hour < 12 )); then
    greeting="Good morning"
  elif (( hour >= 12 && hour < 17 )); then
    greeting="Good afternoon"
  else
    greeting="Good evening"
  fi

  # Heavy Braille Octopus with Integrated Sign
  
  echo '               ┌─[ TASKY ]─┐'
  echo '         ╭─────└─── • • ───┘'
  echo '         │  ⢀⣀⣠⣀⣀⡀'
  echo '         ╰⣠⣾⣿⣿⣿⣿⣿⣿⣷⣦⡀'
  echo '       ⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⣠⣶⣾⣷⣶⣄'
  echo '       ⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⢰⣿⠟⠉⠻⣿⣿⣷'
  echo '       ⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢷⣄⠘⠿⠀⠀⠀⢸⣿⣿⡆'
  echo '       ⠀⠀⠀⠀⠈⠿⣿⣿⣿⣿⣿⣀⣸⣿⣷⣤⣴⠟⠀⠀⠀⠀⢀⣼⣿⣿⠁'
  echo '       ⠀⠀⠀⠀⠀⠀⠈⠙⣛⣿⣿⣿⣿⣿⣿⣿⣿⣦⣀⣀⣀⣴⣾⣿⣿⡟'
  echo '       ⠀⠀⠀⢀⣠⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠋ ⣠⣤⣀'
  echo '       ⠀⠀⣴⣿⣿⣿⠿⠟⠛⠛⢛⣿⣿⣿⣿⣿⣿⣧⡈⠉⠁⠀⠀⠀ ⠈⠉⢻⣿⣧'
  echo '       ⠀⣼⣿⣿⠋⠀⠀⠀⠀⢠⣾⣿⣿⠟⠉⠻⣿⣿⣿⣦⣄      ⣸⣿⣿⠃'
  echo '       ⠀⣿⣿⡇⠀⠀⠀⠀⠀⣿⣿⡿⠃   ⠈⠛⢿⣿⣿⣿⣿⣶⣿⣿⣿⡿⠋'
  echo '       ⠀⢿⣿⣧⡀⠀⣶⣄⠘⣿⣿⡇   ⠠⠶⣿⣶⡄⠈⠙⠛⠻⠟⠛⠛⠁'
  echo '       ⠀⠈⠻⣿⣿⣿⣿⠏⠀⢻⣿⣿⣄    ⣸⣿⡇'
  echo '       ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣶⣾⣿⣿⠃'
  echo '                   ⠈⠙⠛⠛⠛⠋'

  echo -e "${CYAN}${BOLD}👋 ${greeting}, ${USER}! Welcome back to Tasky.${RESET}\n"
}

show_help() {
  echo "Usage: tasky [command] [arguments]"
  echo ""
  echo "Commands:"
  echo "  add \"Task text\" [parent_id]  Add a new task (or subtask)"
  echo "  list [done|pending|all]       List tasks hierarchically"
  echo "  done <id>                     Mark a task and its subtasks as complete"
  echo "  del <id>                      Delete a task and its subtasks"
  echo "  help                          Show this help message"
}

# --- Global Authentication Lock ---
if ! authenticate; then
  echo "Access denied. Incorrect password."
  exit 1
fi

# --- Router ---
case "$1" in
  add) add_task "$2" "$3" ;;
  list) list_tasks "$2" ;;
  done) complete_task "$2" ;;
  del) delete_task "$2" ;;
  help|"") 
    show_greeting
    show_help 
    ;;
  *) echo "Unknown command. Use 'help' to see available commands." ;;
esac