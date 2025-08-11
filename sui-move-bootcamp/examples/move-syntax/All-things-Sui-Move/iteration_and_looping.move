module iteration_tutorial::sui_iteration_demo {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::vector;
    use std::string::{Self, String};
    use sui::table::{Self, Table};
    use sui::bag::{Self, Bag};

    // ===== VECTOR ITERATION =====
    // Vectors are the most common data structure for iteration in Move
    
    struct Player has copy, drop, store {
        name: String,
        level: u64,
        score: u64,
    }
    
    struct GameStats has store {
        total_players: u64,
        average_score: u64,
        highest_score: u64,
        top_players: vector<Player>,
    }
    
    // ===== BASIC VECTOR ITERATION WITH WHILE LOOPS =====
    
    /// Calculate total score using while loop iteration
    public fun calculate_total_score_while(players: &vector<Player>): u64 {
        let total = 0;
        let i = 0;
        let len = vector::length(players);
        
        while (i < len) {
            let player = vector::borrow(players, i);
            total = total + player.score;
            i = i + 1;
        };
        
        total
    }
    
    /// Find highest scoring player using while loop
    public fun find_highest_scorer_while(players: &vector<Player>): Player {
        assert!(vector::length(players) > 0, 0);
        
        let highest_score = 0;
        let highest_index = 0;
        let i = 0;
        let len = vector::length(players);
        
        while (i < len) {
            let player = vector::borrow(players, i);
            if (player.score > highest_score) {
                highest_score = player.score;
                highest_index = i;
            };
            i = i + 1;
        };
        
        *vector::borrow(players, highest_index)
    }
    
    // ===== VECTOR ITERATION WITH FOR-EACH PATTERNS =====
    // Move doesn't have built-in for-each, but we can simulate it
    
    /// Process each player (simulate for-each with function parameters)
    public fun process_all_players(
        players: &mut vector<Player>,
        level_bonus: u64
    ) {
        let i = 0;
        let len = vector::length(players);
        
        while (i < len) {
            let player = vector::borrow_mut(players, i);
            // Apply level bonus to score
            player.score = player.score + (player.level * level_bonus);
            i = i + 1;
        };
    }
    
    /// Filter players by minimum level
    public fun filter_players_by_level(
        players: &vector<Player>,
        min_level: u64
    ): vector<Player> {
        let filtered = vector::empty<Player>();
        let i = 0;
        let len = vector::length(players);
        
        while (i < len) {
            let player = vector::borrow(players, i);
            if (player.level >= min_level) {
                vector::push_back(&mut filtered, *player);
            };
            i = i + 1;
        };
        
        filtered
    }
    
    // ===== REVERSE ITERATION =====
    
    /// Process players in reverse order (useful for removal operations)
    public fun process_players_reverse(players: &mut vector<Player>) {
        let len = vector::length(players);
        if (len == 0) return;
        
        let i = len - 1;
        loop {
            let player = vector::borrow_mut(players, i);
            // Double the score of each player (processing in reverse)
            player.score = player.score * 2;
            
            if (i == 0) break;
            i = i - 1;
        };
    }
    
    /// Remove players with score below threshold (reverse iteration prevents index issues)
    public fun remove_low_scorers(
        players: &mut vector<Player>,
        min_score: u64
    ) {
        let len = vector::length(players);
        if (len == 0) return;
        
        let i = len - 1;
        loop {
            let player = vector::borrow(players, i);
            if (player.score < min_score) {
                vector::remove(players, i);
            };
            
            if (i == 0) break;
            i = i - 1;
        };
    }
    
    // ===== NESTED ITERATION =====
    
    struct Tournament has store {
        name: String,
        rounds: vector<vector<Player>>, // Each round has multiple players
    }
    
    /// Calculate tournament statistics with nested loops
    public fun calculate_tournament_stats(tournament: &Tournament): (u64, u64) {
        let total_players = 0;
        let total_score = 0;
        let round_index = 0;
        let round_count = vector::length(&tournament.rounds);
        
        // Outer loop: iterate through rounds
        while (round_index < round_count) {
            let round = vector::borrow(&tournament.rounds, round_index);
            let player_index = 0;
            let player_count = vector::length(round);
            
            // Inner loop: iterate through players in each round
            while (player_index < player_count) {
                let player = vector::borrow(round, player_index);
                total_players = total_players + 1;
                total_score = total_score + player.score;
                player_index = player_index + 1;
            };
            
            round_index = round_index + 1;
        };
        
        (total_players, total_score)
    }
    
    // ===== BREAKING AND CONTINUING PATTERNS =====
    
    /// Find first player with specific name (early termination)
    public fun find_player_by_name(
        players: &vector<Player>,
        target_name: String
    ): (bool, u64) {
        let i = 0;
        let len = vector::length(players);
        
        while (i < len) {
            let player = vector::borrow(players, i);
            if (player.name == target_name) {
                return (true, i) // Early return (break equivalent)
            };
            i = i + 1;
        };
        
        (false, 0) // Not found
    }
    
    /// Process only players above certain level (continue pattern)
    public fun boost_high_level_players(
        players: &mut vector<Player>,
        min_level: u64,
        boost_amount: u64
    ) {
        let i = 0;
        let len = vector::length(players);
        
        while (i < len) {
            let player = vector::borrow_mut(players, i);
            
            // Skip players below minimum level (continue equivalent)
            if (player.level < min_level) {
                i = i + 1;
                continue
            };
            
            // Process high-level players
            player.score = player.score + boost_amount;
            i = i + 1;
        };
    }
    
    // ===== TABLE ITERATION =====
    // Tables require different iteration patterns since they're key-value stores
    
    struct PlayerDatabase has key {
        id: UID,
        players: Table<u64, Player>, // player_id -> Player
        next_id: u64,
    }
    
    /// Create a new player database
    public fun create_player_database(ctx: &mut TxContext) {
        let database = PlayerDatabase {
            id: object::new(ctx),
            players: table::new(ctx),
            next_id: 1,
        };
        
        transfer::share_object(database);
    }
    
    /// Add player to database
    public fun add_player_to_database(
        database: &mut PlayerDatabase,
        name: vector<u8>,
        level: u64,
        score: u64
    ) {
        let player = Player {
            name: string::utf8(name),
            level,
            score,
        };
        
        table::add(&mut database.players, database.next_id, player);
        database.next_id = database.next_id + 1;
    }
    
    // Note: Direct table iteration isn't supported in Move
    // Instead, we maintain separate vectors of keys for iteration
    
    struct PlayerDatabaseWithKeys has key {
        id: UID,
        players: Table<u64, Player>,
        player_ids: vector<u64>, // Maintain keys for iteration
        next_id: u64,
    }
    
    /// Create database that supports iteration
    public fun create_iterable_database(ctx: &mut TxContext) {
        let database = PlayerDatabaseWithKeys {
            id: object::new(ctx),
            players: table::new(ctx),
            player_ids: vector::empty(),
            next_id: 1,
        };
        
        transfer::share_object(database);
    }
    
    /// Add player and maintain key list
    public fun add_player_iterable(
        database: &mut PlayerDatabaseWithKeys,
        name: vector<u8>,
        level: u64,
        score: u64
    ) {
        let player = Player {
            name: string::utf8(name),
            level,
            score,
        };
        
        table::add(&mut database.players, database.next_id, player);
        vector::push_back(&mut database.player_ids, database.next_id);
        database.next_id = database.next_id + 1;
    }
    
    /// Iterate through all players in table using key vector
    public fun calculate_database_stats(database: &PlayerDatabaseWithKeys): (u64, u64) {
        let total_score = 0;
        let player_count = vector::length(&database.player_ids);
        let i = 0;
        
        while (i < player_count) {
            let player_id = *vector::borrow(&database.player_ids, i);
            let player = table::borrow(&database.players, player_id);
            total_score = total_score + player.score;
            i = i + 1;
        };
        
        (player_count, total_score)
    }
    
    // ===== BAG ITERATION =====
    // Similar to tables, bags need key tracking for iteration
    
    struct ItemInventory has key {
        id: UID,
        items: Bag,
        item_names: vector<String>, // Track keys for iteration
    }
    
    /// Create new inventory
    public fun create_inventory(ctx: &mut TxContext) {
        let inventory = ItemInventory {
            id: object::new(ctx),
            items: bag::new(ctx),
            item_names: vector::empty(),
        };
        
        transfer::transfer(inventory, tx_context::sender(ctx));
    }
    
    /// Add item to inventory
    public fun add_item(
        inventory: &mut ItemInventory,
        item_name: vector<u8>,
        quantity: u64
    ) {
        let name = string::utf8(item_name);
        
        if (bag::contains(&inventory.items, name)) {
            let current_qty = bag::borrow_mut<String, u64>(&mut inventory.items, name);
            *current_qty = *current_qty + quantity;
        } else {
            bag::add(&mut inventory.items, name, quantity);
            vector::push_back(&mut inventory.item_names, name);
        };
    }
    
    /// Count total items using iteration
    public fun count_total_items(inventory: &ItemInventory): u64 {
        let total = 0;
        let i = 0;
        let name_count = vector::length(&inventory.item_names);
        
        while (i < name_count) {
            let item_name = vector::borrow(&inventory.item_names, i);
            let quantity = bag::borrow<String, u64>(&inventory.items, *item_name);
            total = total + *quantity;
            i = i + 1;
        };
        
        total
    }
    
    // ===== PERFORMANCE CONSIDERATIONS =====
    
    /// Efficient batch processing with early termination
    public fun process_players_efficiently(
        players: &mut vector<Player>,
        max_operations: u64
    ): u64 {
        let operations_performed = 0;
        let i = 0;
        let len = vector::length(players);
        
        while (i < len && operations_performed < max_operations) {
            let player = vector::borrow_mut(players, i);
            
            // Only process if player needs update
            if (player.score < 1000) {
                player.score = player.score + 100;
                operations_performed = operations_performed + 1;
            };
            
            i = i + 1;
        };
        
        operations_performed
    }
    
    /// Chunked processing for large datasets
    public fun process_players_in_chunks(
        players: &mut vector<Player>,
        chunk_size: u64,
        start_index: u64
    ): u64 {
        let len = vector::length(players);
        let end_index = if (start_index + chunk_size < len) {
            start_index + chunk_size
        } else {
            len
        };
        
        let i = start_index;
        while (i < end_index) {
            let player = vector::borrow_mut(players, i);
            player.level = player.level + 1; // Level up each player
            i = i + 1;
        };
        
        end_index // Return next start index
    }
    
    // ===== REAL-WORLD EXAMPLE: GAME LEADERBOARD =====
    
    struct Leaderboard has key {
        id: UID,
        players: vector<Player>,
        last_updated: u64,
    }
    
    /// Create leaderboard
    public fun create_leaderboard(ctx: &mut TxContext) {
        let leaderboard = Leaderboard {
            id: object::new(ctx),
            players: vector::empty(),
            last_updated: 0,
        };
        
        transfer::share_object(leaderboard);
    }
    
    /// Add player to leaderboard (maintaining sort order)
    public fun add_to_leaderboard(
        leaderboard: &mut Leaderboard,
        new_player: Player
    ) {
        let players = &mut leaderboard.players;
        let len = vector::length(players);
        let insert_index = len; // Default to end
        
        // Find correct position (reverse iteration for descending order)
        let i = 0;
        while (i < len) {
            let existing_player = vector::borrow(players, i);
            if (new_player.score > existing_player.score) {
                insert_index = i;
                break
            };
            i = i + 1;
        };
        
        // Insert at correct position
        if (insert_index == len) {
            vector::push_back(players, new_player);
        } else {
            vector::insert(players, new_player, insert_index);
        };
        
        // Keep only top 10 players
        while (vector::length(players) > 10) {
            vector::pop_back(players);
        };
    }
    
    /// Update all player levels based on their ranking
    public fun update_leaderboard_levels(leaderboard: &mut Leaderboard) {
        let players = &mut leaderboard.players;
        let len = vector::length(players);
        let i = 0;
        
        while (i < len) {
            let player = vector::borrow_mut(players, i);
            // Higher ranking = higher level bonus
            let rank_bonus = len - i;
            player.level = player.level + rank_bonus;
            i = i + 1;
        };
    }
    
    /// Get top N players
    public fun get_top_players(
        leaderboard: &Leaderboard,
        count: u64
    ): vector<Player> {
        let result = vector::empty<Player>();
        let len = vector::length(&leaderboard.players);
        let max_count = if (count < len) count else len;
        let i = 0;
        
        while (i < max_count) {
            let player = vector::borrow(&leaderboard.players, i);
            vector::push_back(&mut result, *player);
            i = i + 1;
        };
        
        result
    }
    
    // ===== UTILITY FUNCTIONS FOR TESTING =====
    
    /// Create sample players for testing
    public fun create_sample_players(): vector<Player> {
        let players = vector::empty<Player>();
        
        vector::push_back(&mut players, Player {
            name: string::utf8(b"Alice"),
            level: 10,
            score: 1500,
        });
        
        vector::push_back(&mut players, Player {
            name: string::utf8(b"Bob"),
            level: 8,
            score: 1200,
        });
        
        vector::push_back(&mut players, Player {
            name: string::utf8(b"Charlie"),
            level: 12,
            score: 1800,
        });
        
        vector::push_back(&mut players, Player {
            name: string::utf8(b"Diana"),
            level: 9,
            score: 1350,
        });
        
        players
    }
}

/*
ITERATION PATTERNS SUMMARY:

1. BASIC WHILE LOOPS:
   - Most common iteration pattern in Move
   - Use index variable and length check
   - Increment index manually

2. REVERSE ITERATION:
   - Start from length-1, decrement to 0
   - Useful for removal operations to avoid index shifting
   - Use loop with break when reaching 0

3. EARLY TERMINATION:
   - Use return statements for early exit
   - Check conditions before processing
   - Combine with boolean flags for complex logic

4. NESTED ITERATION:
   - Outer loop for primary structure
   - Inner loop for nested data
   - Track multiple index variables

5. TABLE/BAG ITERATION:
   - Maintain separate key vectors for iteration
   - Cannot directly iterate over table/bag contents
   - Use key vector to access table/bag values

6. PERFORMANCE PATTERNS:
   - Batch processing with operation limits
   - Chunked processing for large datasets
   - Early termination based on conditions

BEST PRACTICES:
- Always check vector length before iteration
- Use reverse iteration when removing elements
- Maintain key vectors for table/bag iteration
- Consider gas costs for large iterations
- Use early termination to optimize performance
- Batch operations when possible
- Handle empty collections gracefully

COMMON PITFALLS:
- Index out of bounds errors
- Modifying vector while iterating forward
- Forgetting to increment loop counters
- Not handling empty collections
- Inefficient nested loops on large datasets
*/