# Installing Node.js using NVM

This guide explains how to install Node.js using NVM (Node Version Manager) on Windows, macOS, and Linux. NVM makes it easy to install and switch between multiple versions of Node.js.
NVM allows you to install different versions of Node, and switch between these versions depending on the project that you're working on via the command line.

---

## Prerequisites

- Basic terminal/command line usage
- Git installed on your machine. 

---

## 1. Installing NVM on macOS and Linux

### Step 1: Download and install NVM

Run the following script in your terminal:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh

```

Or using wget:

```bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh

```

This installs NVM into ~/.nvm and adds the necessary lines to your shell configuration file (.bashrc, .zshrc, etc.).


### Step 2: Activate NVM

Close and reopen your terminal to activate NVM.

### Step 3: Verify NVM installation

```bash
nvm --version

```

## 2. Installing NVM on Windows

NVM is mostly supported on Linux and Mac. It doesn't have support for Windows. But there's a similar tool created by coreybutler to provide an nvm experience in Windows called nvm-windows.

nvm-windows provides a management utility for managing Node.js versions in Windows. Here's how to install it: 

### Step 1: Download and install NVM
Go to [nvm-windows repository readme](https://github.com/coreybutler/nvm-windows#readme)
In the nvm-windows repository Readme, click on "Download Now!":

![nvm-windows](/sui-move-bootcamp/assets/screenshots/nvm-download-image.png)

### Step 2: Install the .exe file of the latest release

Click on the nvm-setup.exe asset which is the installation file for the tool:

![nvm-windows](/sui-move-bootcamp/assets/screenshots/nvm-setup-exe2.png)

### Step 3: Complete and confirm installation
Open the file that you have downloaded, and complete the installation wizard.

When done, you can confirm that nvm has been installed by running:

```bash
nvm -v

```


With nvm installed, you can now install, uninstall, and switch between different Node versions in your Windows, Linux, or Mac device.

You can install Node versions like this:

```bash
nvm install latest

```
This will install the latest version of Node.js.

```bash
nvm install vX.Y.Z

```

This will install the X.Y.Z Node version.