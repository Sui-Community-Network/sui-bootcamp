module game_collections::collections_demo {
    use sui::object::{Self, UID};
    use sui::bag::{Self, Bag};
    use sui::object_bag::{Self, ObjectBag};
    use sui::table::{Self, Table};
    use sui::object_table::{Self, ObjectTable};
    use sui::linked_table::{Self, LinkedTable};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string::{Self, String};

    // ===== BAG EXAMPLE =====
    // Bag: Heterogeneous collection (different types) with dynamic key types
    // - Can store ANY type with ANY key type
    // - Perfect for game character features with different data types
    // - Operations: add, remove, borrow, borrow_mut, contains, length

    public struct GameCharacter has key, store {
        id: UID,
        name: String,
        features: Bag, // Can store health(u64), weapons(vector), skills(bool), etc.
    }

    public struct Weapon has store {
        name: String,
        damage: u64,
    }

    public fun create_character(name: String, ctx: &mut TxContext) {
        let mut character = GameCharacter {
            id: object::new(ctx),
            name,
            features: bag::new(ctx),
        };
        
        // Add different types of features to the bag
        bag::add(&mut character.features, b"health", 100u64);
        bag::add(&mut character.features, b"level", 1u8);
        bag::add(&mut character.features, b"is_premium", false);
        
        transfer::share_object(character);
    }

    public fun add_weapon_to_character(character: &mut GameCharacter, weapon: Weapon) {
        // Bags can store any type - here we add a custom Weapon struct
        bag::add(&mut character.features, b"primary_weapon", weapon);
    }

    // ===== OBJECT BAG EXAMPLE =====
    // ObjectBag: Like Bag but stores objects (things with key ability)
    // - Stores objects that can be transferred independently
    // - Good for inventories where items can be traded/transferred
    // - Operations: add, remove, borrow, borrow_mut, contains, length

    public struct TradableItem has key, store {
        id: UID,
        name: String,
        rarity: u8,
    }

    public struct PlayerInventory has key {
        id: UID,
        items: ObjectBag, // Stores transferable game items
    }

    public fun create_inventory(ctx: &mut TxContext) {
        let playerInv = PlayerInventory {
            id: object::new(ctx),
            items: object_bag::new(ctx),
        };
        transfer::share_object(playerInv);
    }

    public fun add_item_to_inventory(
        inventory: &mut PlayerInventory, 
        item_id: String, 
        item: TradableItem
    ) {
        // ObjectBag stores objects that can be transferred later
        object_bag::add(&mut inventory.items, item_id, item);
    }

    public fun trade_item(
        from_inventory: &mut PlayerInventory,
        to_inventory: &mut PlayerInventory,
        item_id: String,
    ) {
        // Remove from one inventory and add to another
        let item = object_bag::remove(&mut from_inventory.items, item_id);
        object_bag::add(&mut to_inventory.items, item_id, item);
    }

    // ===== TABLE EXAMPLE =====
    // Table: Homogeneous collection (same value type) with efficient storage
    // - All values must be the same type
    // - More gas-efficient than Bag for uniform data
    // - Perfect for leaderboards, scores, or uniform mappings
    // - Operations: add, remove, borrow, borrow_mut, contains, length

    public struct Leaderboard has key {
        id: UID,
        scores: Table<String, u64>, // Player name -> Score (all u64)
    }

    public fun create_leaderboard(ctx: &mut TxContext) {
        let leaderboard = Leaderboard {
            id: object::new(ctx),
            scores: table::new(ctx),
        };
        transfer::share_object(leaderboard);
    }

    public fun update_score(leaderboard: &mut Leaderboard, player: String, score: u64) {
        if (table::contains(&leaderboard.scores, player)) {
            // Update existing score if higher
            let current_score = table::borrow_mut(&mut leaderboard.scores, player);
            if (score > *current_score) {
                *current_score = score;
            };
        } else {
            // Add new player score
            table::add(&mut leaderboard.scores, player, score);
        };
    }

    // ===== OBJECT TABLE EXAMPLE =====
    // ObjectTable: Like Table but stores objects (things with key ability)
    // - All values must be objects of the same type
    // - More efficient than ObjectBag for uniform object storage
    // - Great for guild systems, where all members are same object type
    // - Operations: add, remove, borrow, borrow_mut, contains, length

    public struct GuildMember has key, store {
        id: UID,
        name: String,
        rank: u8,
        contribution: u64,
    }

    public struct Guild has key {
        id: UID,
        name: String,
        members: ObjectTable<String, GuildMember>, // Username -> GuildMember object
    }

    public fun create_guild(name: String, ctx: &mut TxContext) {
        let guild = Guild {
            id: object::new(ctx),
            name,
            members: object_table::new(ctx),
        };
        transfer::share_object(guild);
    }

    public fun join_guild(
        guild: &mut Guild, 
        username: String, 
        member: GuildMember
    ) {
        // All stored objects are the same type (GuildMember)
        object_table::add(&mut guild.members, username, member);
    }

    // ===== LINKED TABLE EXAMPLE =====
    // LinkedTable: Ordered collection with next/prev navigation
    // - Maintains insertion order or custom ordering
    // - Can iterate through elements in order
    // - Perfect for quest chains, storylines, or ordered sequences
    // - Operations: push_front, push_back, pop_front, pop_back, next, prev

    public struct QuestChain has key {
        id: UID,
        quests: LinkedTable<u64, String>, // Quest ID -> Quest Description (ordered)
    }

    public fun create_quest_chain(ctx: &mut TxContext) {
        let questChain = QuestChain {
            id: object::new(ctx),
            quests: linked_table::new(ctx),
        };
        transfer::share_object(questChain);
    }

    public fun add_quest_to_chain(
        quest_chain: &mut QuestChain, 
        quest_id: u64, 
        description: String
    ) {
        // LinkedTable maintains order - perfect for sequential quests
        linked_table::push_back(&mut quest_chain.quests, quest_id, description);
    }

    public fun complete_first_quest(quest_chain: &mut QuestChain): Option<String> {
        if (linked_table::is_empty(&quest_chain.quests)) {
            option::none()
        } else {
            // Remove and return the first quest (FIFO for quest progression)
            let (_, description) = linked_table::pop_front(&mut quest_chain.quests);
            option::some(description)
        }
    }

    // ===== COMPARISON SUMMARY =====
    /*
    Collection Type Comparison:

    1. BAG:
       - Stores: Any type (heterogeneous)
       - Keys: Any type
       - Use: Mixed data like character stats, settings, metadata
       - Example: {health: 100u64, name: "Hero", is_alive: true}

    2. OBJECT BAG:
       - Stores: Objects only (things with 'key' ability)
       - Keys: Any type  
       - Use: Transferable items, NFTs, tradeable assets
       - Example: {sword: Weapon{}, shield: Armor{}, potion: Item{}}

    3. TABLE:
       - Stores: Same type only (homogeneous)
       - Keys: Copy + Drop + Store types
       - Use: Uniform data like scores, balances, counts
       - Example: {"player1": 1500u64, "player2": 2300u64}

    4. OBJECT TABLE:
       - Stores: Same object type only
       - Keys: Copy + Drop + Store types
       - Use: Uniform objects like user profiles, game pieces
       - Example: {"alice": User{}, "bob": User{}}

    5. LINKED TABLE:
       - Stores: Same type, maintains order
       - Keys: Copy + Drop + Store types
       - Use: Ordered sequences like quest chains, chat history
       - Example: Ordered quests, tournament brackets, storylines
    */

    // ===== PRACTICAL USAGE FUNCTIONS =====

    public fun demonstrate_bag_operations(character: &mut GameCharacter) {
        // Bag allows mixed types and operations
        let health = bag::borrow(&character.features, b"health");
        assert!(*health == 100u64, 0);
        
        // Modify existing value
        let health_mut = bag::borrow_mut(&mut character.features, b"health");
        *health_mut = 90u64;
        
        // Check if key exists
        assert!(bag::contains(&character.features, b"level"), 1);
        
        // Get size
        let _size = bag::length(&character.features);
    }

    public fun demonstrate_table_efficiency(leaderboard: &mut Leaderboard) {
        // Table operations are more gas-efficient for uniform data
        table::add(&mut leaderboard.scores, string::utf8(b"speedrunner"), 5000u64);
        table::add(&mut leaderboard.scores, string::utf8(b"casual_player"), 1200u64);
        
        // Efficient lookups and updates
        if (table::contains(&leaderboard.scores, string::utf8(b"speedrunner"))) {
            let score = table::borrow_mut(&mut leaderboard.scores, string::utf8(b"speedrunner"));
            *score = *score + 500; // Bonus points
        };
    }

    public fun demonstrate_linked_table_order(quest_chain: &mut QuestChain) {
        // LinkedTable maintains order for sequential operations
        linked_table::push_back(&mut quest_chain.quests, 1, string::utf8(b"Find the ancient sword"));
        linked_table::push_back(&mut quest_chain.quests, 2, string::utf8(b"Defeat the dragon"));
        linked_table::push_back(&mut quest_chain.quests, 3, string::utf8(b"Return to village"));
        
        // Process quests in order
        while (!linked_table::is_empty(&quest_chain.quests)) {
            let (quest_id, _description) = linked_table::pop_front(&mut quest_chain.quests);
            // Process quest_id in sequence...
            quest_id; // Use the quest_id
        };
    }

    // ===== CLEANUP FUNCTIONS =====

    public fun destroy_character(character: GameCharacter) {
        let GameCharacter { id, name: _, features } = character;
        object::delete(id);
        bag::destroy_empty(features);
    }

    public fun destroy_inventory(inventory: PlayerInventory) {
        let PlayerInventory { id, items } = inventory;
        object::delete(id);
        object_bag::destroy_empty(items);
    }

    public fun destroy_leaderboard(leaderboard: Leaderboard) {
        let Leaderboard { id, scores } = leaderboard;
        object::delete(id);
        table::destroy_empty(scores);
    }

    public fun destroy_guild(guild: Guild) {
        let Guild { id, name: _, members } = guild;
        object::delete(id);
        object_table::destroy_empty(members);
    }

    public fun destroy_quest_chain(quest_chain: QuestChain) {
        let QuestChain { id, quests } = quest_chain;
        object::delete(id);
        linked_table::destroy_empty(quests);
    }
}