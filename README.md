# Tasky - Command-Line Task Management Tool

## Description
Tasky is a simple, yet powerful command-line task management tool written in Bash. It allows you to create, manage, and track tasks from your terminal. 

## Features
* Create new tasks with descriptions
* List all tasks or filter by status (done/pending)
* Mark tasks as complete
* Delete tasks (with authentication)
* Password protection for sensitive operations
* Clean, interactive interface in the terminal
* Simple JSON-based storage

## Installation
1. Save the script to a file named `tasky.sh`
2. Make it executable: `chmod +x tasky.sh`
3. Move it to your PATH directory (e.g., `/usr/local/bin` or `$HOME/.local/bin`)

```bash
sudo mv tasky.sh /usr/local/bin/tasky
# Or if you prefer a user-specific installation:
mkdir -p ~/.local/bin
mv tasky.sh ~/.local/bin/tasky
```

## Usage
Once installed, you can access Tasky through your terminal using the `tasky` command.

### Basic Commands
* Add a new task: `tasky add "Buy groceries"`
* List all tasks: `tasky list`
* List only completed tasks: `tasky list done`
* Mark a task as complete (using its ID): `tasky done 1234567890`
* Delete a task (requires authentication): `tasky del 1234567890`
* Get help: `tasky help`

### Advanced Features
* Task IDs are generated automatically using timestamps
* The database is stored in JSON format at `./tasks.json`
* Password protection prevents unauthorized access to delete functionality

## Configuration
Tasky stores its data in the following location:
- Tasks: `./tasks.json`
- Password file: `./password` (encrypted)

You can modify these locations by editing the script, but be sure to maintain proper permissions for security reasons.

## Contributing
If you'd like to contribute to Tasky, feel free to submit pull requests with your improvements or new features!

1. Fork this repository
2. Create a branch: `git checkout -b my-new-feature`
3. Make your changes and commit them: `git commit -m "Add my awesome feature"`
4. Push to your fork: `git push origin my-new-feature`
5. Submit a pull request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.