# Tasky - Command-Line Task Management Tool

               ┌─[ TASKY ]─┐
         ╭─────└─── • • ───┘
         │  ⢀⣀⣠⣀⣀⡀
         ╰⣠⣾⣿⣿⣿⣿⣿⣿⣷⣦⡀
       ⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⣠⣶⣾⣷⣶⣄
       ⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⢰⣿⠟⠉⠻⣿⣿⣷
       ⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢷⣄⠘⠿⠀⠀⠀⢸⣿⣿⡆
       ⠀⠀⠀⠀⠈⠿⣿⣿⣿⣿⣿⣀⣸⣿⣷⣤⣴⠟⠀⠀⠀⠀⢀⣼⣿⣿⠁
       ⠀⠀⠀⠀⠀⠀⠈⠙⣛⣿⣿⣿⣿⣿⣿⣿⣿⣦⣀⣀⣀⣴⣾⣿⣿⡟
       ⠀⠀⠀⢀⣠⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠋ ⣠⣤⣀
       ⠀⠀⣴⣿⣿⣿⠿⠟⠛⠛⢛⣿⣿⣿⣿⣿⣿⣧⡈⠉⠁⠀⠀⠀ ⠈⠉⢻⣿⣧
       ⠀⣼⣿⣿⠋⠀⠀⠀⠀⢠⣾⣿⣿⠟⠉⠻⣿⣿⣿⣦⣄      ⣸⣿⣿⠃
       ⠀⣿⣿⡇⠀⠀⠀⠀⠀⣿⣿⡿⠃   ⠈⠛⢿⣿⣿⣿⣿⣶⣿⣿⣿⡿⠋
       ⠀⢿⣿⣧⡀⠀⣶⣄⠘⣿⣿⡇   ⠠⠶⣿⣶⡄⠈⠙⠛⠻⠟⠛⠛⠁
       ⠀⠈⠻⣿⣿⣿⣿⠏⠀⢻⣿⣿⣄    ⣸⣿⡇
       ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣶⣾⣿⣿⠃
                   ⠈⠙⠛⠛⠛⠋

## Description

Tasky is a lightweight, secure, and hierarchical command-line task management tool written in Bash. Designed for the terminal, it stores data locally in JSON format and features a session-managed security lock alongside native subtask rendering.

https://roadmap.sh/projects/task-tracker


## Features

* **Secure Vault Mode:** Script-wide password protection locks down task visibility, creation, and modifications.
* **Smart Session Timeout:** Enter your password once; enjoy unrestricted terminal access for **15 minutes (900 seconds)** before the session automatically re-locks.
* **Hierarchical Subtasks:** Create clean parent-child relationships by nesting subtasks directly under parent IDs.
* **Perfect Dynamic Alignment:** Dynamically fits long task descriptions and structural indents into an auto-adjusting tree view using `column`.
* **Clean Sequential IDs:** Human-readable indexing ($1, 2, 3 \dots$) replaces long, messy timestamp strings.
* **Cascading Completions & Deletions:** Marking a parent task as complete or deleting it will automatically apply the action to all its nested subtasks.

---

## Installation

1. Save the final script code to a file named `tasky`.
2. Make it executable:
```bash
chmod +x tasky

```


3. Move it to your local environment PATH directory:
```bash
mkdir -p ~/.local/bin
mv tasky ~/.local/bin/tasky

```



---

## Usage

Upon running `tasky` for the first time, you will be prompted to set up a master password. Input characters are hidden silently during both setup and daily authentication.

### Basic Commands

* **Add a Main Task:** 
```bash
tasky add "Fix production server"

```


* **Add a Subtask:** Provide the parent task's ID as the second argument.
```bash
tasky add "Back up the database" 1

```


* **Interactive List Trees:**
```bash
tasky list           # Lists all tasks hierarchically
tasky list pending   # Filter only incomplete tasks
tasky list done      # Filter only completed tasks

```


* **Complete Tasks:** Marks a task (and all its subtasks) as complete.
```bash
tasky done 1

```


* **Delete Tasks:** Securely wipes a task and any nested children.
```bash
tasky del 1

```



### Example Terminal Interface Layout

```text
ID     STATUS  TASK
1      [ ]     Fix production server
  ↳ 2  [ ]     Back up the database
Total tasks: 2
Summary:     2 pending, 0 completed

```

---

## Storage Layout

Tasky securely isolates your data, state logs, and credentials inside your user profile directory:

* **Tasks Database:** `$HOME/.local/share/tasky/tasks.json`
* **Encrypted Master Credentials:** `$HOME/.local/share/tasky/password`
* **Temporary Session Token:** `/tmp/tasky_session_$USER`

> [!NOTE]
> The credential engine automatically hashes the user password against a secure local salt (`DartMole`) via SHA-256 before saving or verifying sessions.

---

## System Dependencies

Ensure you have `jq` and `util-linux` (which provides the `column` tool) installed on your system:

* **Debian/Ubuntu:** `sudo apt install jq`
* **Fedora/RHEL:** `sudo dnf install jq`
* **Arch Linux:** `sudo pacman -S jq`

---

## Contributing

1. Fork this repository.
2. Create a feature branch: `git checkout -b feature/my-new-upgrade`.
3. Commit changes: `git commit -m "Add feature details"`.
4. Push to your fork: `git push origin feature/my-new-upgrade`.
5. Open a pull request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.