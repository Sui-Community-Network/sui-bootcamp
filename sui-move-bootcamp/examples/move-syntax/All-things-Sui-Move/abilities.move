module All-things-Sui_Move::abilities {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string::{Self, String};

    // ===== COPY ABILITY =====
    // Values with 'copy' can be duplicated/cloned
    // Useful for: Configuration data, constants, simple values that need duplication
    
    /// Simple configuration struct that can be copied
    struct GameConfig has copy, drop {
        max_players: u64,
        game_duration: u64,
        entry_fee: u64,
    }
    
    /// Player stats that can be copied for leaderboards
    struct PlayerStats has copy, drop, store {
        wins: u64,
        losses: u64,
        points: u64,
    }
    
    // Function demonstrating copy ability
    public fun demonstrate_copy_ability(): (GameConfig, GameConfig) {
        let config = GameConfig {
            max_players: 10,
            game_duration: 3600, // 1 hour in seconds
            entry_fee: 1000,
        };
        
        // Because GameConfig has 'copy', we can duplicate it
        let config_copy = config; // This creates a copy
        let another_copy = config; // Original is still usable
        
        (config_copy, another_copy)
    }
    
    // ===== DROP ABILITY =====
    // Values with 'drop' can be discarded when they go out of scope
    // Without 'drop', you must explicitly handle the value (transfer, store, etc.)
    
    /// Temporary calculation result that can be dropped
    struct CalculationResult has drop {
        result: u64,
        timestamp: u64,
    }
    
    /// Resource without drop - must be explicitly handled
    struct PreciousResource {
        value: u64,
        id: UID,
    }
    
    // Function demonstrating drop ability
    public fun demonstrate_drop_ability(ctx: &mut TxContext) {
        let temp_result = CalculationResult {
            result: 42,
            timestamp: 1234567890,
        };
        // temp_result will be automatically dropped at end of scope
        
        let precious = PreciousResource {
            value: 1000,
            id: object::new(ctx),
        };
        // precious CANNOT be dropped - we must transfer it
        transfer::transfer(precious, tx_context::sender(ctx));
    }
    
    // ===== STORE ABILITY =====
    // Values with 'store' can be stored inside structs that are kept in global storage
    // Essential for: Data that needs to persist in blockchain state
    
    /// User profile that can be stored
    struct UserProfile has store {
        username: String,
        level: u64,
        stats: PlayerStats, // PlayerStats also has 'store'
    }
    
    /// Main game object that holds storable data
    struct GameState has key {
        id: UID,
        players: vector<UserProfile>, // Can store UserProfile because it has 'store'
        config: GameConfig, // Can store GameConfig (though it also has copy/drop)
    }
    
    // Function demonstrating store ability
    public fun create_game_with_stored_data(ctx: &mut TxContext) {
        let player_profile = UserProfile {
            username: string::utf8(b"Alice"),
            level: 5,
            stats: PlayerStats {
                wins: 10,
                losses: 3,
                points: 1500,
            },
        };
        
        let game_config = GameConfig {
            max_players: 8,
            game_duration: 1800,
            entry_fee: 500,
        };
        
        let game_state = GameState {
            id: object::new(ctx),
            players: vector[player_profile], // Stored inside the game state
            config: game_config,
        };
        
        // Transfer to make it a shared object or owned by sender
        transfer::share_object(game_state);
    }
    
    // ===== KEY ABILITY =====
    // Values with 'key' can be used as keys for global storage operations
    // They become Sui objects that can be owned, shared, or transferred
    // Must always have an 'id: UID' field as the first field
    
    /// NFT that can be owned and transferred
    struct GameNFT has key, store {
        id: UID,
        name: String,
        rarity: u8,
        power: u64,
    }
    
    /// Shared game room that multiple players can access
    struct GameRoom has key {
        id: UID,
        room_name: String,
        current_players: u64,
        max_players: u64,
        is_active: bool,
    }
    
    /// Player inventory that owns other objects
    struct PlayerInventory has key {
        id: UID,
        owner: address,
        nfts: vector<GameNFT>, // Can store NFTs because they have 'store'
    }
    
    // Functions demonstrating key ability
    
    /// Create an NFT (becomes an owned object)
    public fun mint_game_nft(
        name: vector<u8>,
        rarity: u8,
        power: u64,
        ctx: &mut TxContext
    ) {
        let nft = GameNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            rarity,
            power,
        };
        
        // Transfer to sender - now they own this object
        transfer::transfer(nft, tx_context::sender(ctx));
    }
    
    /// Create a shared game room
    public fun create_game_room(
        room_name: vector<u8>,
        max_players: u64,
        ctx: &mut TxContext
    ) {
        let room = GameRoom {
            id: object::new(ctx),
            room_name: string::utf8(room_name),
            current_players: 0,
            max_players,
            is_active: true,
        };
        
        // Share the object - anyone can access it
        transfer::share_object(room);
    }
    
    /// Create player inventory
    public fun create_inventory(ctx: &mut TxContext) {
        let inventory = PlayerInventory {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            nfts: vector::empty(),
        };
        
        transfer::transfer(inventory, tx_context::sender(ctx));
    }
    
    // ===== COMBINING ABILITIES =====
    // Real-world example: A marketplace item that needs multiple abilities
    
    /// Marketplace listing that can be copied for display, stored in marketplace,
    /// and dropped when expired
    struct MarketplaceListing has copy, drop, store {
        item_id: u64,
        seller: address,
        price: u64,
        expiry_time: u64,
    }
    
    /// The actual marketplace that stores listings
    struct Marketplace has key {
        id: UID,
        listings: vector<MarketplaceListing>, // 'store' allows this
        total_sales: u64,
    }
    
    /// Demonstrate marketplace operations
    public fun create_marketplace(ctx: &mut TxContext) {
        let marketplace = Marketplace {
            id: object::new(ctx),
            listings: vector::empty(),
            total_sales: 0,
        };
        
        transfer::share_object(marketplace);
    }
    
    public fun add_listing(
        marketplace: &mut Marketplace,
        item_id: u64,
        price: u64,
        expiry_time: u64,
        ctx: &mut TxContext
    ) {
        let listing = MarketplaceListing {
            item_id,
            seller: tx_context::sender(ctx),
            price,
            expiry_time,
        };
        
        // Can push because MarketplaceListing has 'store'
        vector::push_back(&mut marketplace.listings, listing);
    }
    
    public fun get_listing_copy(
        marketplace: &Marketplace,
        index: u64
    ): MarketplaceListing {
        // Can return a copy because MarketplaceListing has 'copy'
        *vector::borrow(&marketplace.listings, index)
    }
    
    // ===== ABILITY CONSTRAINTS EXAMPLES =====
    
    /// This struct CANNOT be stored in global storage because it lacks 'store'
    struct TemporaryData has copy, drop {
        temp_value: u64,
    }
    
    /// This would cause a compilation error:
    /// struct BadContainer has key {
    ///     id: UID,
    ///     temp_data: TemporaryData, // Error! TemporaryData lacks 'store'
    /// }
    
    /// This struct cannot be copied because it lacks 'copy'
    struct UniqueResource has drop, store {
        unique_id: u64,
        data: String,
    }
    
    public fun demonstrate_constraints() {
        let unique = UniqueResource {
            unique_id: 123,
            data: string::utf8(b"unique data"),
        };
        
        // This would cause a compilation error:
        // let copy = unique; // Error! UniqueResource cannot be copied
        
        // But we can move it:
        let moved = unique; // This transfers ownership
        
        // unique is no longer accessible here
        // moved will be dropped at end of scope (has 'drop' ability)
    }
}

/*
REAL-WORLD SCENARIOS SUMMARY:

1. COPY ABILITY:
   - Game configurations that need to be shared across functions
   - Player statistics for leaderboards
   - Constants and settings that multiple parts of code need access to
   - Mathematical results that need to be used in multiple calculations

2. DROP ABILITY:
   - Temporary computation results
   - Cache data that can be discarded
   - Event logs that don't need permanent storage
   - Intermediate processing data

3. STORE ABILITY:
   - User profiles and account data
   - Game state that persists between sessions
   - Transaction history
   - Any data that needs to be kept in blockchain storage

4. KEY ABILITY:
   - NFTs and digital collectibles
   - User accounts and profiles
   - Game rooms and lobbies
   - Smart contracts and DAOs
   - Any object that needs to be independently owned/shared

IMPORTANT NOTES:
- 'key' objects must have 'id: UID' as first field
- 'key' objects can be owned, shared, or frozen
- Objects without 'drop' must be explicitly handled (transfer/store)
- 'store' is required for putting data inside 'key' objects
- Abilities are checked at compile time for safety
*/