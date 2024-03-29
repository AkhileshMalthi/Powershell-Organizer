# PowerShell File Organizer

Welcome to the PowerShell File Organizer repository! This tool helps you organize files in a directory based on their extensions. It automatically categorizes files into folders for easy management and access.

## Features

- **Automatic Organization**: Organizes files in the current directory based on their file extensions.
- **Customizable Folder Names**: Provides customizable folder names for common file types.
- **Undo Functionality**: Allows users to undo the organization and restore files to their original locations.
- **Transcript Logging**: Logs the organization process for reference.

## How to Use

### Requirements

- PowerShell installed on your system.

### Installation

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/your-username/powershell-file-organizer.git
    ```

2. Navigate to the cloned directory:

    ```bash
    cd powershell-file-organizer
    ```

### Usage

1. Open PowerShell.

2. Navigate to the directory containing the files you want to organize.

3. Run the `organizer.ps1` script:

    ```powershell
    .\organizer.ps1
    ```

4. Follow the prompts to organize your files.

### Undo Operation

- If you want to undo the organization and restore files to their original locations, select "Y" when prompted after the organization process.

### Customization

- You can customize the folder names for specific file types by modifying the mappings in the `organizer.ps1` script.

## Built With

- **PowerShell**: The scripting language used for file organization.
- **GitHub**: Hosts the repository and project files.
- **Visual Studio Code**: Code editor used for script development.
