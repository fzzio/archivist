
# Archivist: Advanced File Concatenation Script

This Bash script processes and concatenates text files from specified directories or individual files into a single Markdown-formatted output. It's useful for developers who need to compile multiple source files into a single document, while respecting `.gitignore` rules and handling various file types.

## Features

- Recursively processes files in a given directory or individual files.
- Respects `.gitignore` and other ignore files.
- Custom ignore patterns using `--ignore` or forced inclusion using `--force`.
- Handles binary files by listing only their paths (with optional binary types).
- Supports output to a file or directly to the clipboard.
- Formats output in Markdown for easy readability.
- Works across Linux, macOS, and Windows (with appropriate clipboard handling).
- Supports symbolic links for easy execution without `.sh` extension.

## Usage

```bash
archivist [directories/files...] [options]
```

### Options

- `--help`: Show the help message and exit.
- `--clipboard`: Copy the result to the clipboard instead of creating a file.
- `--output <file>`: Specify a custom output file (default: `files.txt`).
- `--supported-binary-files <types>`: Specify additional supported binary file types (e.g., `'CSV|JSON'`).
- `--ignore <paths>`: Specify additional paths to ignore (space-separated).
- `--force <paths>`: Force inclusion of specified paths (even if ignored).
- `--auto-confirm-git-init`: Automatically initialize Git repositories if a `.gitignore` is found in a directory without an initialized Git repository.
- `--auto-continue-processing`: Automatically continue processing files without user confirmation for warnings.

### Examples

Process the current directory and save the output to the default file:

```bash
archivist .
```

Process a specific directory and copy the output to the clipboard:

```bash
archivist /path/to/project --clipboard
```

Ignore specific directories during processing:

```bash
archivist /path/to/project --ignore 'assets docs'
```

Forcefully include specific directories even if they are ignored:

```bash
archivist /path/to/project --ignore 'node_modules dist' --force 'node_modules dist'
```

## Installation

To install the script globally and make it accessible from any directory, follow these steps based on your operating system.

### Step 1: Clone the repository

```bash
git clone https://github.com/yourusername/archivist.git
```

### Step 2: Create a symbolic link

You can create a symbolic link directly to the script in the repository, so that any updates made by `git pull` are immediately reflected:

#### For Linux and macOS:

1. Navigate to the directory where you cloned the repository:

   ```bash
   cd /path/to/archivist
   ```

2. Create the symbolic link in `/usr/local/bin` (or any directory in your `PATH`):

   ```bash
   ln -s $(pwd)/archivist.sh /usr/local/bin/archivist
   ```

3. Now you can run the script as `archivist` from anywhere.

#### For Windows (Git Bash or Cygwin):

1. Navigate to the directory where you cloned the repository:

   ```bash
   cd /path/to/archivist
   ```

2. Create an alias by adding this to your `.bash_profile` or `.bashrc`:

   ```bash
   alias archivist='bash /path/to/archivist/archivist.sh'
   ```

3. Reload the shell configuration:

   ```bash
   source ~/.bash_profile  # Or ~/.bashrc
   ```

4. Now you can run the script as `archivist` from anywhere.

### Step 3: Verify Installation

You can verify that the script is now accessible globally by running:

```bash
archivist --help
```

This should display the help menu.

## Updating the Script

To update the script, follow these steps:

### Step 1: Navigate to the repository folder

```bash
cd archivist
```

### Step 2: Pull the latest changes

```bash
git pull
```

Since the symbolic link is already in place, the updates will be immediately available.

### Step 3: Verify the update

Run the script again to ensure the update was successful:

```bash
archivist --help
```

## License

This project is licensed under the [MIT License](https://choosealicense.com/licenses/mit/).

## Acknowledgements

To my family, to my friends and special thanks to the open source community for the feedback and contributions.

---

Created with ❤️ by [Fabricio Orrala](https://www.linkedin.com/in/fzzio/)

[![Buy me a coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FDDC5C?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/fzzio)

