# Archivist: Advanced File Concatenation Script

This Bash script is designed to process and concatenate text files from a given directory into a single Markdown-formatted output. It's particularly useful for developers who need to compile multiple source files into a single document, respecting `.gitignore` rules and handling various file types.

## Features

- Recursively processes files in a given directory
- Respects `.gitignore` and other ignore files
- Handles binary files by listing only their paths
- Supports custom ignore patterns and force-include options
- Can output to a file or directly to the clipboard
- Formats output in Markdown for easy readability
- Handles special characters and encoding issues

## Usage

```bash
./archivist.sh [directory] [options]
```

### Options

- `--help`: Show the help message and exit
- `--clipboard`: Copy the result to the clipboard instead of creating a file
- `--ignore <paths>`: Specify additional paths to ignore (space-separated)
- `--force <paths>`: Specify paths to forcibly include (space-separated)
- `--output <file>`: Specify a custom output file (default is "files.txt")

### Examples

Process the current directory and save to default output file:
```bash
./archivist.sh
```

Process a specific directory and copy to clipboard:
```bash
./archivist.sh /path/to/project --clipboard
```

Ignore additional directories and force include a file:
```bash
./archivist.sh --ignore node_modules build --force src/important.js
```

## Requirements

- Bash shell
- `git` command-line tool (for respecting `.gitignore` rules)
- `xclip` (on Linux) or `pbcopy` (on macOS) for clipboard functionality

## Installation

1. Clone this repository or download the script file.
2. Make the script executable:
   ```bash
   chmod +x archivist.sh
   ```
3. (Optional) Move the script to a directory in your PATH for easy access.

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check [issues page](https://github.com/fzzio/archivist/issues) if you want to contribute.

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Acknowledgements

Special thanks to the open-source community and all contributors who have helped shape and improve this script. Your feedback and suggestions are greatly appreciated.

---

Created with ❤️ by [Fabricio Orrala](https://www.linkedin.com/in/fzzio/)