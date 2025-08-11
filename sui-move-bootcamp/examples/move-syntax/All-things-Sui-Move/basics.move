/// Complete Sui Move Basics Tutorial
/// This module covers all fundamental concepts needed to get started with Sui Move
module All-things-Sui_Move::basics {
    // ===== MODULE IMPORTS =====
    // Import necessary modules for our examples
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::address;
    use std::string::{Self, String};
    use std::vector;
    use std::option::{Self, Option};

    // =========================
    // VARIABLES AND MUTABILITY
    // =========================
    
    /// Demonstrates variable declaration and mutability
    public fun variable_basics() {
        // IMMUTABLE VARIABLES (default behavior)
        let x: u8 = 10;              // Cannot be changed after declaration
        let name = b"Alice";         // Type inference - compiler knows it's vector<u8>
        
        // MUTABLE VARIABLES (use 'mut' keyword)
        let mut y: u16 = 20;         // Can be modified
        let mut counter = 0u64;      // Type suffix notation
        
        // Modifying mutable variables
        y = y + 5;                   // Now y = 25
        counter = counter + 1;       // Now counter = 1
        
        // SHADOWING - Creating new variable with same name
        let x = 100u64;              // This is a new variable, different type
        let x = x + 50;              // Another new variable, x = 150
        
        // Variables must be used or prefixed with underscore
        let _unused = 42;            // Won't cause compiler warning
    }

    // =========================
    // PRIMITIVE TYPES
    // =========================

    /// Comprehensive demonstration of all primitive types
    public fun primitive_types_demo() {
        // === UNSIGNED INTEGERS ===
        // Move supports various unsigned integer sizes
        let small: u8 = 255;         // 0 to 255 (1 byte)
        let medium: u16 = 65535;     // 0 to 65,535 (2 bytes)
        let standard: u32 = 1000;    // 0 to ~4.3 billion (4 bytes)
        let large: u64 = 1_000_000;  // 0 to ~18 quintillion (8 bytes)
        let huge: u128 = 1000;       // 0 to ~340 undecillion (16 bytes)
        let massive: u256 = 1000;    // 0 to 2^256 - 1 (32 bytes)
        
        // Type casting between integers
        let casted = (small as u64); // Cast u8 to u64
        
        // === BOOLEAN ===
        let is_active: bool = true;
        let is_complete: bool = false;
        let result = is_active && !is_complete; // Boolean operations
        
        // === ADDRESS ===
        // Addresses are 32-byte values representing accounts/objects
        let account_addr: address = @0x1;
        let contract_addr: address = @0x2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b;
        
        // Address operations
        let addr_as_u256: u256 = address::to_u256(account_addr);
        let addr_from_u256: address = address::from_u256(12345);
        
        // Special addresses
        let zero_addr = @0x0;        // Zero address
    }

    // =========================
    // VECTOR OPERATIONS
    // =========================

    /// Comprehensive vector operations and patterns
    public fun vector_operations_demo() {
        // === VECTOR CREATION ===
        let empty_vector: vector<u64> = vector::empty<u64>(); // Empty vector
        let numbers = vector[1, 2, 3, 4, 5];                  // Vector literal
        let mixed_types = vector[                              // Nested vectors
            vector[1, 2],
            vector[3, 4],
            vector[5, 6]
        ];
        
        // === VECTOR OPERATIONS ===
        let mut mutable_vec = vector[10, 20, 30];
        
        // Adding elements
        vector::push_back(&mut mutable_vec, 40);              // Add to end
        vector::insert(&mut mutable_vec, 0, 5);               // Insert at index 0
        
        // Accessing elements
        let first = *vector::borrow(&mutable_vec, 0);         // Read element
        let first_mut = vector::borrow_mut(&mut mutable_vec, 0); // Mutable reference
        *first_mut = 100;                                     // Modify element
        
        // Removing elements
        let last = vector::pop_back(&mut mutable_vec);        // Remove from end
        let removed = vector::remove(&mut mutable_vec, 1);    // Remove at index
        
        // Vector properties
        let length = vector::length(&mutable_vec);
        let is_empty = vector::is_empty(&mutable_vec);
        
        // Searching
        let (found, index) = vector::index_of(&mutable_vec, &30);
        let contains = vector::contains(&mutable_vec, &20);
        
        // Vector iteration (basic pattern)
        let sum = calculate_sum(&mutable_vec);
    }
    
    /// Helper function for vector iteration
    fun calculate_sum(numbers: &vector<u64>): u64 {
        let mut sum = 0;
        let mut i = 0;
        let len = vector::length(numbers);
        
        while (i < len) {
            sum = sum + *vector::borrow(numbers, i);
            i = i + 1;
        };
        sum
    }

    // =========================
    // STRING HANDLING
    // =========================

    /// Comprehensive string operations
    public fun string_operations_demo() {
        // === BYTE STRINGS ===
        let byte_string: vector<u8> = b"Hello, World!";       // Byte string literal
        let manual_bytes = vector[72, 101, 108, 108, 111];    // Manual byte vector (Hello)
        
        // === UTF-8 STRINGS ===
        let utf8_string: String = string::utf8(b"Hello");     // Create UTF-8 string
        let convenient = b"World".to_string();                // Convenient conversion
        
        // String operations
        let bytes = string::bytes(&utf8_string);              // Get underlying bytes
        let length = string::length(&utf8_string);            // String length
        let is_empty = string::is_empty(&utf8_string);        // Check if empty
        
        // String comparison
        let are_equal = utf8_string == convenient;            // String equality
        
        // Substring operations
        let sub = string::sub_string(&utf8_string, 0, 2);     // Extract substring
        
        // Concatenation (requires manual byte manipulation)
        let mut combined_bytes = *string::bytes(&utf8_string);
        vector::append(&mut combined_bytes, *string::bytes(&convenient));
        let combined = string::utf8(combined_bytes);
    }

    // =========================
    // STRUCT DEFINITIONS
    // =========================

    /// Basic struct without abilities
    struct BasicProfile {
        name: String,
        age: u8,
    }

    /// Struct with abilities for different use cases
    struct Player has copy, drop, store {
        name: String,
        level: u64,
        score: u64,
        is_active: bool,
    }

    /// Struct that can be a Sui object
    struct GameItem has key, store {
        id: UID,
        name: String,
        rarity: u8,
        owner: address,
    }

    /// Nested struct example
    struct Team has copy, drop, store {
        name: String,
        players: vector<Player>,
        formation: TeamFormation,
    }

    struct TeamFormation has copy, drop, store {
        style: u8,          // 0 = defensive, 1 = balanced, 2 = offensive
        player_positions: vector<u8>,
    }

    // =========================
    // ENUM DEFINITIONS
    // =========================

    /// Basic enum with different variant types
    public enum GameState has copy, drop {
        /// Game not started
        Waiting,
        /// Game in progress with current round
        Active(u64),
        /// Game paused with reason
        Paused { reason: String, resume_time: u64 },
        /// Game completed with final score
        Completed { winner: address, final_score: u64 },
    }

    /// Status enum for different object states
    public enum ItemStatus has copy, drop, store {
        Available,
        Reserved(address),      // Reserved by this address
        Sold { 
            buyer: address, 
            price: u64,
            timestamp: u64,
        },
        Damaged { severity: u8 },
    }

    // =========================
    // STRUCT OPERATIONS
    // =========================

    /// Demonstrate struct creation and manipulation
    public fun struct_operations_demo(ctx: &mut TxContext) {
        // === STRUCT CREATION ===
        let player = Player {
            name: string::utf8(b"Alice"),
            level: 10,
            score: 1500,
            is_active: true,
        };

        let formation = TeamFormation {
            style: 1, // balanced
            player_positions: vector[1, 2, 3, 4, 5],
        };

        let mut team = Team {
            name: string::utf8(b"Warriors"),
            players: vector[player],
            formation,
        };

        // === STRUCT ACCESS ===
        let team_name = team.name;                    // Access field
        let player_count = vector::length(&team.players);
        let first_player = vector::borrow(&team.players, 0);
        let first_player_level = first_player.level;

        // === STRUCT MODIFICATION ===
        // Modify mutable struct fields
        team.name = string::utf8(b"Super Warriors");
        
        // Modify nested fields
        let first_player_mut = vector::borrow_mut(&mut team.players, 0);
        first_player_mut.score = first_player_mut.score + 100;

        // Add new player to team
        let new_player = Player {
            name: string::utf8(b"Bob"),
            level: 8,
            score: 1200,
            is_active: true,
        };
        vector::push_back(&mut team.players, new_player);

        // === DESTRUCTURING ===
        let Team { name, players, formation } = team;
        // Now we have: name, players, formation as separate variables

        // Partial destructuring
        let Player { level, score, .. } = *vector::borrow(&players, 0);
        // Gets level and score, ignores other fields
    }

    /// Create a Sui object (struct with key ability)
    public fun create_game_item(
        name: vector<u8>,
        rarity: u8,
        ctx: &mut TxContext
    ) {
        let item = GameItem {
            id: object::new(ctx),
            name: string::utf8(name),
            rarity,
            owner: tx_context::sender(ctx),
        };

        transfer::transfer(item, tx_context::sender(ctx));
    }

    // =========================
    // ENUM OPERATIONS
    // =========================

    /// Demonstrate enum usage and pattern matching
    public fun enum_operations_demo() {
        // === ENUM CREATION ===
        let waiting_state = GameState::Waiting;
        let active_state = GameState::Active(5); // Round 5
        let paused_state = GameState::Paused { 
            reason: string::utf8(b"Server maintenance"),
            resume_time: 1234567890,
        };

        // === PATTERN MATCHING ===
        let status_message = match (&active_state) {
            GameState::Waiting => string::utf8(b"Game starting soon..."),
            GameState::Active(round) => {
                if (*round < 3) {
                    string::utf8(b"Early game")
                } else {
                    string::utf8(b"Late game")
                }
            },
            GameState::Paused { reason, .. } => *reason,
            GameState::Completed { winner: _, final_score } => {
                if (*final_score > 1000) {
                    string::utf8(b"High score game!")
                } else {
                    string::utf8(b"Game completed")
                }
            },
        };

        // === ENUM MODIFICATION ===
        let mut item_status = ItemStatus::Available;
        
        // Change status based on conditions
        item_status = ItemStatus::Reserved(@0x123);
        
        // Later, mark as sold
        item_status = ItemStatus::Sold {
            buyer: @0x123,
            price: 1000,
            timestamp: 1234567890,
        };
    }

    /// Helper function to check if game can start
    public fun can_start_game(state: &GameState): bool {
        match (state) {
            GameState::Waiting => true,
            GameState::Active(_) => false,
            GameState::Paused { .. } => true,
            GameState::Completed { .. } => true,
        }
    }

    // =========================
    // ARITHMETIC OPERATIONS
    // =========================

    /// Comprehensive arithmetic operations
    public fun arithmetic_operations_demo() {
        let x: u64 = 100;
        let y: u64 = 30;

        // === BASIC ARITHMETIC ===
        let sum = x + y;        // Addition: 130
        let diff = x - y;       // Subtraction: 70
        let product = x * y;    // Multiplication: 3000
        let quotient = x / y;   // Integer division: 3
        let remainder = x % y;  // Modulus: 10

        // === COMPARISON OPERATIONS ===
        let is_equal = x == y;      // false
        let not_equal = x != y;     // true
        let greater = x > y;        // true
        let less = x < y;           // false
        let greater_eq = x >= y;    // true
        let less_eq = x <= y;       // false

        // === LOGICAL OPERATIONS ===
        let both_positive = (x > 0) && (y > 0);     // true
        let either_zero = (x == 0) || (y == 0);    // false
        let not_equal_alt = !(x == y);             // true

        // === BITWISE OPERATIONS ===
        let bitwise_and = x & y;    // Bitwise AND
        let bitwise_or = x | y;     // Bitwise OR
        let bitwise_xor = x ^ y;    // Bitwise XOR
        let left_shift = x << 2;    // Left shift by 2 bits
        let right_shift = x >> 2;   // Right shift by 2 bits

        // === COMPOUND ASSIGNMENTS (with mutable variables) ===
        let mut counter = 10u64;
        counter = counter + 5;      // counter += 5 equivalent
        counter = counter * 2;      // counter *= 2 equivalent
        counter = counter / 3;      // counter /= 3 equivalent
    }

    // =========================
    // OPTION TYPE USAGE
    // =========================

    /// Demonstrate Option type for handling nullable values
    public fun option_operations_demo() {
        // === OPTION CREATION ===
        let some_value: Option<u64> = option::some(42);
        let no_value: Option<u64> = option::none();

        // === OPTION CHECKING ===
        let has_value = option::is_some(&some_value);      // true
        let is_empty = option::is_none(&no_value);         // true

        // === EXTRACTING VALUES ===
        if (option::is_some(&some_value)) {
            let value = option::extract(&mut some_value);   // Gets 42
            // some_value is now none
        };

        // === SAFE ACCESS ===
        let default_value = option::get_with_default(&some_value, 0);

        // === OPTION WITH CUSTOM TYPES ===
        let player_opt: Option<Player> = option::some(Player {
            name: string::utf8(b"Charlie"),
            level: 15,
            score: 2000,
            is_active: true,
        });

        // Pattern matching with options
        let level = if (option::is_some(&player_opt)) {
            let player = option::borrow(&player_opt);
            player.level
        } else {
            1 // default level
        };
    }

    // =========================
    // PRACTICAL EXAMPLES
    // =========================

    /// Real-world example: Simple banking operations
    struct BankAccount has store {
        balance: u64,
        owner: address,
        is_frozen: bool,
    }

    struct Bank has key {
        id: UID,
        accounts: vector<BankAccount>,
        total_deposits: u64,
    }

    /// Create a new bank
    public fun create_bank(ctx: &mut TxContext) {
        let bank = Bank {
            id: object::new(ctx),
            accounts: vector::empty(),
            total_deposits: 0,
        };

        transfer::share_object(bank);
    }

    /// Create a new account
    public fun create_account(
        bank: &mut Bank,
        initial_deposit: u64,
        ctx: &mut TxContext
    ) {
        let account = BankAccount {
            balance: initial_deposit,
            owner: tx_context::sender(ctx),
            is_frozen: false,
        };

        vector::push_back(&mut bank.accounts, account);
        bank.total_deposits = bank.total_deposits + initial_deposit;
    }

    /// Find account by owner
    public fun find_account_index(bank: &Bank, owner: address): Option<u64> {
        let mut i = 0;
        let len = vector::length(&bank.accounts);

        while (i < len) {
            let account = vector::borrow(&bank.accounts, i);
            if (account.owner == owner) {
                return option::some(i)
            };
            i = i + 1;
        };

        option::none()
    }

    /// Deposit money
    public fun deposit(
        bank: &mut Bank,
        amount: u64,
        ctx: &mut TxContext
    ) {
        let owner = tx_context::sender(ctx);
        let account_index_opt = find_account_index(bank, owner);

        assert!(option::is_some(&account_index_opt), 0); // Account must exist

        let account_index = option::extract(&mut account_index_opt);
        let account = vector::borrow_mut(&mut bank.accounts, account_index);

        assert!(!account.is_frozen, 1); // Account must not be frozen

        account.balance = account.balance + amount;
        bank.total_deposits = bank.total_deposits + amount;
    }

    /// Withdraw money
    public fun withdraw(
        bank: &mut Bank,
        amount: u64,
        ctx: &mut TxContext
    ) {
        let owner = tx_context::sender(ctx);
        let account_index_opt = find_account_index(bank, owner);

        assert!(option::is_some(&account_index_opt), 0); // Account must exist

        let account_index = option::extract(&mut account_index_opt);
        let account = vector::borrow_mut(&mut bank.accounts, account_index);

        assert!(!account.is_frozen, 1);           // Account must not be frozen
        assert!(account.balance >= amount, 2);   // Sufficient balance

        account.balance = account.balance - amount;
        bank.total_deposits = bank.total_deposits - amount;
    }

    /// Get account balance
    public fun get_balance(bank: &Bank, owner: address): u64 {
        let account_index_opt = find_account_index(bank, owner);

        if (option::is_some(&account_index_opt)) {
            let account_index = option::extract(&mut account_index_opt);
            let account = vector::borrow(&bank.accounts, account_index);
            account.balance
        } else {
            0 // No account found
        }
    }

    // =========================
    // CONSTANTS AND ERRORS
    // =========================

    // Constants (compile-time values)
    const MAX_PLAYERS: u64 = 100;
    const MIN_LEVEL: u64 = 1;
    const DEFAULT_SCORE: u64 = 0;

    // Error constants
    const EAccountNotFound: u64 = 0;
    const EAccountFrozen: u64 = 1;
    const EInsufficientBalance: u64 = 2;
    const EInvalidLevel: u64 = 3;
    const ETooManyPlayers: u64 = 4;

    /// Demonstrate constant usage
    public fun create_default_player(name: vector<u8>): Player {
        Player {
            name: string::utf8(name),
            level: MIN_LEVEL,
            score: DEFAULT_SCORE,
            is_active: true,
        }
    }

    /// Validate player level
    public fun validate_player_level(level: u64) {
        assert!(level >= MIN_LEVEL, EInvalidLevel);
        assert!(level <= 100, EInvalidLevel); // Max level 100
    }

    // =========================
    // TESTING UTILITIES
    // =========================

    #[test_only]
    use sui::test_scenario;

    #[test]
    public fun test_basic_operations() {
        let mut scenario = test_scenario::begin(@0x1);
        
        // Test arithmetic
        let result = 10 + 5;
        assert!(result == 15, 0);
        
        // Test vector operations
        let mut numbers = vector[1, 2, 3];
        vector::push_back(&mut numbers, 4);
        assert!(vector::length(&numbers) == 4, 1);
        
        // Test string operations
        let text = string::utf8(b"Hello");
        assert!(string::length(&text) == 5, 2);
        
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_struct_operations() {
        let player = Player {
            name: string::utf8(b"Test Player"),
            level: 5,
            score: 100,
            is_active: true,
        };

        assert!(player.level == 5, 0);
        assert!(player.score == 100, 1);
        assert!(player.is_active == true, 2);
    }

    #[test]
    public fun test_enum_operations() {
        let state = GameState::Active(3);
        let can_start = can_start_game(&state);
        assert!(!can_start, 0); // Should not be able to start active game
        
        let waiting = GameState::Waiting;
        let can_start_waiting = can_start_game(&waiting);
        assert!(can_start_waiting, 1); // Should be able to start waiting game
    }
}

/*
====================
SUMMARY OF CONCEPTS
====================

1. VARIABLES:
   - Immutable by default (let x = value)
   - Mutable with 'mut' keyword (let mut x = value)
   - Shadowing allows reusing variable names
   - Type inference reduces verbosity

2. PRIMITIVE TYPES:
   - Integers: u8, u16, u32, u64, u128, u256
   - Boolean: true/false with logical operations
   - Address: 32-byte account/contract identifiers
   - Vector: Dynamic arrays with rich operations

3. STRINGS:
   - Byte strings: b"text" or vector<u8>
   - UTF-8 strings: String type from std::string
   - Conversion between byte and UTF-8 formats

4. STRUCTS:
   - Custom data types grouping related fields
   - Abilities control behavior (copy, drop, store, key)
   - Field access with dot notation
   - Destructuring for field extraction

5. ENUMS:
   - Sum types with multiple variants
   - Pattern matching for handling variants
   - Can carry data in variants
   - Useful for state machines

6. OPERATIONS:
   - Arithmetic: +, -, *, /, %
   - Comparison: ==, !=, <, >, <=, >=
   - Logical: &&, ||, !
   - Bitwise: &, |, ^, <<, >>

7. OPTIONS:
   - Handle nullable values safely
   - option::some(value) and option::none()
   - Pattern matching and safe extraction

8. BEST PRACTICES:
   - Use constants for magic numbers
   - Proper error handling with assertions
   - Meaningful variable and function names
   - Comprehensive testing

This tutorial provides a solid foundation for Sui Move development!
*/