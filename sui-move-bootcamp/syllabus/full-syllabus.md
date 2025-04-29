### 15 Nights of Sui Move Bootcamp — Full Syllabus

---

## 📘 Phase 1: Foundations of Sui & Move (Nights 1–5)

### **Night 1: Introduction to Sui & Move**
**Learning Objectives:**
- Gain an overview of blockchain technology and Sui's place in the ecosystem
- Understand how Sui differs from EVM chains (parallel execution, object-centric)
- Learn about Move's origin (from Libra by Meta) and why Sui adopted it
- Explore real-world Sui use cases (games, marketplaces, NFTs, etc.)

**Mini Activity:**
- Install the Sui Wallet extension
- Claim test SUI tokens from the faucet
- Explore your wallet interface

---

### **Night 2: Understanding Sui's Architecture**
**Learning Objectives:**
- Understand Sui's execution model and how object ownership replaces global state
- Learn the difference between owned and shared objects
- Visualize how validators handle transactions using object IDs and causal relationships

**Mini Activity:**
- Draw the lifecycle of an object (creation, update, deletion)
- Follow a transaction flow involving object versioning

---

### **Night 3: Introduction to the Move Language (Part 1)**
**Learning Objectives:**
- Learn Move syntax: keywords, modules, structs, entry functions
- Understand how Move ensures memory and resource safety
- Write and compile your first Move module

**Mini Activity:**
- Write a Move function that returns a string: "Hello, Sui!"
- Compile it using the Sui CLI and deploy it locally

---

### **Night 4: Move Language (Part 2) — Storage, Objects & Ownership**
**Learning Objectives:**
- Understand the role of UID and the object system in Sui
- Learn about & (immutable reference) and &mut (mutable reference)
- Explore how access control is done via ownership

**Mini Activity:**
- Build a simple counter module that only the creator can increment
- Use `assert!` to enforce access control

---

### **Night 5: Object Interactions & In-Person Coding Night**
**Learning Objectives:**
- Explore how objects can be passed between modules
- Learn about Sui's ability to mutate objects safely via references
- Learn error handling: using `abort`, `assert`, and custom error codes

**Mini Project:**
- Build a basic NFT module that stores a name and metadata URL
- Add minting logic that assigns ownership based on sender address

---

## 🔧 Phase 2: Smart Contract Development (Nights 6–10)

### **Night 6: Advanced Move Programming**
**Learning Objectives:**
- Explore capabilities: tokens that grant permission to mutate other objects
- Create and consume resources dynamically
- Reuse code via helper functions and modular patterns

**Mini Activity:**
- Create an admin-only update function using capabilities
- Write helper modules for common validation logic

---

### **Night 7: Gas & Transaction Optimization**
**Learning Objectives:**
- Understand how gas is measured and charged in Sui
- Learn strategies to write gas-efficient contracts
- Understand object size and complexity impact on gas

**Mini Activity:**
- Compare gas usage of different struct layouts
- Benchmark two different transaction flows with `sui move test` output

---

### **Night 8: Testing & Debugging Move Contracts**
**Learning Objectives:**
- Write unit tests using the Move testing framework
- Use `sui move test` to write assert-based tests
- Trace and debug failed transactions or assertions

**Mini Activity:**
- Test and debug a contract where a user can transfer tokens conditionally
- Simulate errors and practice fixing them

---

### **Night 9: Sui Framework & External Libraries**
**Learning Objectives:**
- Import and use system modules (e.g., `coin::Coin`, `transfer::Transfer`)
- Explore common patterns (minting, transferring, burning)
- Reuse library code and structure your own libraries

**Mini Activity:**
- Create a custom fungible token using Sui's `coin` framework
- Add mint, burn, and transfer logic with role-based controls

---

### **Night 10: Cross-Contract Communication & In-Person Coding Night**
**Learning Objectives:**
- Use shared objects to build multi-user applications
- Learn how different modules call into one another
- Understand the importance of clean module design for reusability

**Mini Project:**
- Build a simple on-chain marketplace: users list and buy NFTs
- Use shared objects for the global listing store

---

## 🌐 Phase 3: Full dApp Development (Nights 11–15)

### **Night 11: Building a Frontend for Sui dApps**
**Learning Objectives:**
- Understand the architecture of a Sui dApp (smart contract + frontend)
- Set up a frontend using React or plain JavaScript
- Use Tailwind or other UI libraries to build user interfaces

**Mini Activity:**
- Scaffold a React app with `create-react-app`
- Add a simple page and connect it to the Sui Wallet

---

### **Night 12: Querying & Sending Transactions from Frontend**
**Learning Objectives:**
- Use `@mysten/sui.js` to fetch on-chain data
- Build and sign transactions from the browser
- Handle transaction receipts and feedback to users

**Mini Activity:**
- Create a frontend that lets users increment a counter on-chain
- Display the counter value live

---

### **Night 13: User Authentication & Wallet Integration**
**Learning Objectives:**
- Connect to Sui Wallet and access the user’s address
- Restrict features based on authentication
- Handle basic session logic in React

**Mini Activity:**
- Build a "My NFTs" dashboard
- Show only the NFTs owned by the logged-in wallet

---

### **Night 14: Full-Stack dApp Development**
**Learning Objectives:**
- Combine Move backend with Sui.js-powered frontend
- Explore full dApp architecture and best practices
- Learn how to structure codebases for maintainability

**Mini Project:**
- Build a functional NFT auction app with frontend + backend
- Include bidding logic, display metadata, and event logs

---

### **Night 15: Deployment, Scaling & Final Hackathon**
**Learning Objectives:**
- Deploy contracts to Sui testnet or mainnet
- Explore Sui Explorer and Dev Inspect tools
- Present final projects and receive live feedback

**Final Activity:**
- Run a live Hackathon!
- Learners demo their full-stack dApps

---

### 🎓 Graduation & Showcase
- Celebrate learner achievements
- Invite community judges or mentors to give feedback
- Highlight top projects on GitHub or social media