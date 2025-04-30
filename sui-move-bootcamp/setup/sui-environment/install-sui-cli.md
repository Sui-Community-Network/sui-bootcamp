# Sui CLI setup

Before we can install Sui to our local machine, we first need to ensure that certain prerequisites have been installed on our machine. Sui supports the following operating systems:

- Linux - Ubuntu version 20.04 (Jammy Jellfish)
- macOS - macOS Monterey
- Microsoft Windows - Windows 10,11

**Diclaimer:** Installing SUI process is a long process which can take up to 2 hours depending on your internet speed and reliability . Please be patient and follow the instructions carefully. Also ensure you have atleast **6GB** of storage free on your machine. 

If you find the process is too much you can go ahead and set it up on a virtual environment like Github Codespaces or Gitpod here [codespaces and gitpod guide](#Virtual-environments-setup). This will just act as a bandaid solution as you will require to reinstall the sui binaries on every instance which is not sustainable long term. However it is a viable option if you struggle too much installing sui cli locally, especially if you are on a low-end machine, on windows or just have no space to spare.

Jump to the step based on the OS that your machine is running. 

Click below to go directly to the setup guide for your operating system:

- [Linux Setup Guide](#linux-setup)
- [Mac Setup Guide](#macos-setup)
- [Windows Setup Guide](#windows-setup)


After you’re done downloading the required prerequisites for your OS, continue to Step 5, where we’ll download the Sui binaries (i.e. actually installing Sui on our machine).

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

## windows-setup
On windows the process for installing Sui cli is quite tricky and there are various approaches to doing it. Some will require you to install the following prerequisites some will not. There are 3 methods for installing Sui CLI according to your preference and also expertise:
- WSL method
- Chocolatey method(covered [here](#chocolatey-method))
- Manual method(watch video [here](#https://youtu.be/f8J_MfUtI7U?si=O-tUlo_zj9HmIdv2))

**NOTE** :We recommend using the **WSL (Windows Subsystem for Linux)** method because it provides the most complete, developer-friendly environment for building, testing, and deploying Sui smart contracts. It closely mirrors the official Sui documentation, supports all necessary development tools, and gives you full control to use advanced commands like sui move test, run local validators, and work with open-source code — making it ideal for long-term learning and serious development. Might sound a like a lot at the moment but you will get it all in time :) 

However if you face challenges using that method you can use the **Chocolatey method** or the **Manual method**
Here is a breakdown of each method with their pros and cons;

#### Installation Methods Breakdown

| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| **WSL (Windows Subsystem for Linux)** | Developers building & testing smart contracts | ✅ Matches Sui docs<br>✅ Full testing support<br>✅ Linux tools & flexibility | ❌ Takes more time<br>❌ Requires Ubuntu setup |
| **Chocolatey** | Beginners who just want to try the CLI quickly | ✅ Fast install<br>✅ Easy updates<br>✅ No coding knowledge needed | ❌ Not dev-friendly<br>❌ Less control |
| **Manual Download** | Power users who want a quick setup without package managers | ✅ Simple<br>✅ No build process<br>✅ Works offline after setup | ❌ No auto-updates<br>❌ No testing tools<br>❌ Easy to misconfigure |

#### Prerequisites Breakdown by Installation Method

| Tool               | WSL (Recommended) | Chocolatey | Manual Download |
|--------------------|-------------------|------------|-----------------|
| **Rust & Cargo**    | ✅ Required        | ❌ Not needed | ❌ Not needed     |
| **Git CLI**         | ✅ Required        | ❌ Not needed | ❌ Not needed     |
| **CMake**           | ✅ Required        | ❌ Not needed | ❌ Not needed     |
| **C++ Build Tools** | ✅ Required (`build-essential`) | ❌ Not needed | ❌ Not needed     |
| **cURL**            | ✅ Required        | ✅ Used to install tools | ⚠️ Optional (only for Rust install if needed) |

> 📝 **Note:** The WSL method builds Sui from source, so it needs all development tools.  
> Chocolatey and Manual Download methods use prebuilt binaries — so Rust, Git, and compilers are not required.



If you decide to use the WSL method you can go ahead and proceed installing the following prerequisites:

- Rust + Cargo	    - Rust is the programming language Sui is written in. Cargo is Rust’s tool for building and running the code. You need both to install and work with Sui CLI.
- cURL	            - A tool that lets your computer download files from the internet using the command line — it's used to fetch the Rust and Sui installers.
- Git CLI	        - Lets you download (clone) the Sui code from GitHub and track changes to your code.
- CMake	            - A helper tool that puts all the parts of the Sui program together during the build process.
- C++ Build Tools	- A set of compilers and libraries from Microsoft needed to compile Rust and C++ code.      Installed via Visual Studio Build Tools.


There are two resources you can use to install these prerequisites on Windows:
- [Video Guide](https://youtu.be/gA1HYUnOvcQ)

Text guide below:

### 1. Rust and Cargo
The first thing we’ll be installing is Rust. To do so, check out the information about using the Rust [Rust installer](https://www.rust-lang.org/tools/install) on the Rust website. The installer checks for C++ build tools and prompts you to install them if necessary. Select the option that best defines your environment and follow the instructions in the install wizard.

Sui uses the latest version of Cargo to build and manage dependencies. Use the following command to update Rust with rustup a tool you should have installed as part of the Rust installer.
```bash
rustup update stable
```
### 2. cURL
Windows 11 ships with a Microsoft version of cURL already installed. If you are on windows 10 or want to use the curl project version instead, download and install it [here](https://curl.se/windows/).

### 3. CMake
Download and install [CMake](https://cmake.org/download/) from the CMake website.

---

### Chocolatey Method
Chocolatey is a package manager for Windows that makes it easy to install and update software. It's a great option for beginners who want a quick and easy way to install Sui.

To install it on Windows, you run powershell as an administator and use the following command:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
To read more about Chocolatey, check out the [official documentation](https://docs.chocolatey.org/en-us/choco/setup/).

After installing Chocolatey, you can use the following command to install Sui:
```powershell
choco install sui   
```
After that to check whether sui is installed correctly, open a new terminal and run the following command:
```bash
sui --version
``` 

If you did it correctly you should see a similar output displaying the version of Sui you installed.
![Expected output](.\assets\screenshots\sui-verison-output-screenshot.png)


## Virtual-environments-setup
Here we will explain just how to setup the virtual instances. After that you can just refer to [this](#linux-setup) to install the prerequisites and [this](#installing-sui-binaries) to install the binaries since these virtual instances run on linux so it will just be like working with a linux machine.

### GitHub Codespaces


## INSTALLING SUI BINARIES

### Linux and macOS

 


