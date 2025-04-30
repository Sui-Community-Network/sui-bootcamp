# Sui CLI setup

Before we can install Sui to our local machine, we first need to ensure that certain prerequisites have been installed on our machine. Sui supports the following operating systems:

- Linux - Ubuntu version 20.04 (Jammy Jellfish)
- macOS - macOS Monterey
- Microsoft Windows - Windows 10,11

**Diclaimer:** Installing SUI process is a long process which can take up to 2 hours depending on your internet speed and reliability . Please be patient and follow the instructions carefully. Also ensure you have atleast **6GB** of storage free on your machine. 
If you find the process is too much you can go ahead and set it up on a virtual environment like Github Codespaces or Gitpod here [codespaces and gitpod guide](#Virtual-environments-setup)

Jump to the step based on the OS that your machine is running. 

Click below to go directly to the setup guide for your operating system:

- [Windows Setup Guide](#windows-setup)
- [Mac Setup Guide](#macos-setup)
- [Linux Setup Guide](#linux-setup)

After you’re done downloading the required prerequisites for your OS, continue to Step 5, where we’ll download the Sui binaries (i.e. actually installing Sui on our machine).

---

## windows-setup

---

---

## macOS-setup
The macOS requires the following prerequisites:

- Brew
- Rust and Cargo
- cURL
- CMake
- Git CLI

For a video guide watch here [Watch on YouTube](https://youtu.be/ONFX9tGuMt8) for a text guide lets proceed

### 1. Brew
Open up a terminal. macOS includes a version of cURL you can use to install Brew. We’ll be using Brew to install other tools, including a newer version of cURL. Use the following command to install Brew:

```bash 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
### 2. Rust and Cargo
Run the following command in your terminal to install Rust and Cargo. If the terminal prompts with you installation options, choose the default option.
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
After installing Rust, you might need to close and reopen your terminal. Sui uses the latest version of Cargo to build and manage dependencies. Use the following command to update Rust with rustup:
```bash
rustup update stable
```
### 3. cURL
```bash
brew install curl
```
### 4. CMake
Use the following command to install CMake:
```bash
brew install cmake
```

### 5. Git CLI
Use the following command to install Git: 
```bash
brew install git
```

Proceed to **[INSTALLING-SUI-BINARIES](#INSTALLING-SUI-BINARIES)**

---

## linux-setup
The Linux OS requires the following prerequisites:

- curl	             - Used to download the Sui and Rust installers from the internet.
- rust + cargo	     - Rust is the programming language Sui is built with, and Cargo helps build the project.
- git	             - Lets you download the Sui code from GitHub.
- cmake	             - Helps put the different parts of the code together when building.
- gcc	             - A basic tool that helps turn source code into programs.
- libssl-dev	     - Helps the CLI work securely over the internet (SSL/TLS support).
- libclang-dev	     - Needed by some parts of the code that work with C or C++ libraries.
- libpq-dev	Lets     - Sui talk to PostgreSQL databases (used in some setups).
- build-essential	 - A bundle of tools (like make and compilers) needed to build most software.

If you would like a video guide on how to install these prerequisites on Ubuntu, you can watch this video:
[Watch on YouTube](https://youtu.be/3-AqE-IlpGM). 

### 1. cURL

First, open up a terminal. We’ll be using cURL to install most of the prerequisites. To check if you have cURL installed, run the command curl in your terminal. If you have cURL installed, the system will print curl: try 'curl --help' or 'curl --manual' for more information . Otherwise, you will see something like curl command not found. If you don’t have cURL installed on your device, run the command below to install it:
```bash
sudo apt install curl
```
### 2. Rust and cargo
Sui requires Rust and Cargo (Rust's package manager). The suggested method to install Rust is with rustup using cURL. Run the following command in your terminal to install Rust and Cargo. If the terminal prompts with you installation options, choose the default option.
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

After installing Rust, you might need to close and reopen your terminal. Sui uses the latest version of Cargo to build and manage dependencies. Use the following command to update Rust with rustup:
```bash
rustup update   
```

### 3. Updating apt-get
We use the APT package manager, so let’s go ahead and make sure it’s updated:
```bash
sudo apt-get update
```

### 4. Git
Run the following command to install Git, including the Git CLI:
```bash
sudo apt-get install git-all
```

### 5. CMake
Use the following command to install CMake:
```bash
sudo apt-get install cmake
```

### 6. gcc
Use the following command to install the GNU Compiler Collection, gcc:
```bash
sudo apt-get install gcc
```

### 7. libssl-dev
Use the following command to install libssl-dev. If the version of Linux you use doesn't support libssl-dev, find an equivalent package for it on the ROS Index.
```bash
sudo apt-get install libssl-dev
```
Also, if you have OpenSSL you might need to also install pkg-config:
```bash
sudo apt-get install pkg-config
```

### 8. libclang-dev
Use the following command to install libclang-dev. If the version of Linux you use doesn't support libclang-dev, find an equivalent package for it on the ROS Index
```bash
sudo apt-get install libclang-dev
```

### 9. build-essential
Use the following command to install build-essential:
```bash
sudo apt-get install build-essential
```
Proceed to **[INSTALLING-SUI-BINARIES](#INSTALLING-SUI-BINARIES)**

---

## Virtual-environments-setup

### GitHub Codespaces

### Gitpod

## INSTALLING SUI BINARIES