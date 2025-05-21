# How to Install TypeScript on Windows, Linux, and Mac

TypeScript is a powerful superset of JavaScript that adds static typing, making your code more robust and maintainable. This guide provides a clear, step-by-step process for installing TypeScript on [**Windows**](#1 Installing TypeScript on Windows), [**Linux**](#2 Installing TypeScript on Linux), and [**Mac**](#3 Installing Typescript on Mac) systems.

---

## Prerequisites

- **Node.js**: TypeScript requires Node.js and npm (Node Package Manager).


---

## 1. Installing TypeScript on Windows

### Step 1: Install Node.js

Click [here](/sui-move-bootcamp/setup/frontend-setup/install-node-js.md) to go to our guide on installing Node.js using NVM.

### Step 2: Install TypeScript Globally

Open Command Prompt or PowerShell and run:

```bash
npm install -g typescript
```

This command installs TypeScript globally, making the tsc (TypeScript compiler) command available from any directory.

### Step 3: Verify the Installation
Check the installed TypeScript version:

```bash
tsc --version
```
You should see the version number displayed, confirming a successful installation.

---

## 2 Installing TypeScript on Linux

### Step 1: Install Node.js
Click [here](/sui-move-bootcamp/setup/frontend-setup/install-node-js.md) to go to our guide on installing Node.js using NVM

### Step 2: Install TypeScript Globally

```bash
npm install -g typescript
```
The -g flag ensures TypeScript is available system-wide.

### Step 3: Verify the Installation
```bash
tsc -v
```
You should see the version number, confirming the installation.

### Optional: Update TypeScript
To update TypeScript in the future:

```bash
npm update -g typescript
```
---

## 3 Installing Typescript on Mac

### Step 1: Install Node.js
Click [here](/sui-move-bootcamp/setup/frontend-setup/install-node-js.md) to go to our guide on installing Node.js using NVM

### Step 2: Install TypeScript Globally
Open Terminal and run:

```bash
npm install -g typescript
```
This makes the tsc command available globally.

### Step 3: Verify the Installation

```bash
tsc --version
```
If you see a version number, TypeScript is installed successfully.

---

## 4. Compiling Your First TypeScript File (All Platforms)
Create a new file named hello.ts with the following content:

```typescript
function greet(name: string) {
  return `Hello, ${name}!`;
}

console.log(greet("TypeScript"));

```
Compile the TypeScript file to JavaScript:

```bash
tsc hello.ts
```
This generates a hello.js file in the same directory.

Run the JavaScript file using Node.js:
```bash
node hello.js
```

This should output: "Hello, TypeScript!"

✅ You're now ready to write and run TypeScript code on your machine!

