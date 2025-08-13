// =========================================
// SUI MOVE DYNAMIC FIELDS - COMPLETE GUIDE
// =========================================

module example::dynamic_fields_demo {
    use sui::object::{Self, UID};
    use sui::dynamic_field as df;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use std::string::String;

    // =========================================
    // WHAT ARE DYNAMIC FIELDS?
    // =========================================
    /*
    Dynamic fields allow you to add arbitrary key-value pairs to any object
    with a UID at runtime. Think of them as a HashMap attached to an object.
    
    Key benefits:
    - Add fields without modifying the original struct
    - Store heterogeneous data types
    - Efficient storage (only pay for what you use)
    - Can be queried and iterated over
    */

    // =========================================
    // BASIC STRUCT WITH UID
    // =========================================
    struct Container has key {
        id: UID,
        name: String,
    }

    // Objects that can be stored as dynamic object fields
    struct Item has key, store {
        id: UID,
        value: u64,
        description: String,
    }

    // =========================================
    // DYNAMIC FIELD TYPES
    // =========================================
    /*
    1. dynamic_field: Stores values directly (copy/drop types)
    2. dynamic_object_field: Stores objects with key+store abilities
    */

    // =========================================
    // CREATING A CONTAINER
    // =========================================
    public fun create_container(name: String, ctx: &mut TxContext): Container {
        Container {
            id: object::new(ctx),
            name,
        }
    }

    // =========================================
    // ADDING DYNAMIC FIELDS
    // =========================================
    
    // Add a simple value (u64, bool, String, etc.)
    public fun add_number_field(
        container: &mut Container, 
        key: String, 
        value: u64
    ) {
        df::add(&mut container.id, key, value);
    }

    // Add a vector of values
    public fun add_vector_field(
        container: &mut Container,
        key: String,
        values: vector<u64>
    ) {
        df::add(&mut container.id, key, values);
    }

    // Add a custom struct (must have copy + drop + store)
    struct Metadata has copy, drop, store {
        created_at: u64,
        tags: vector<String>,
    }

    public fun add_metadata_field(
        container: &mut Container,
        key: String,
        metadata: Metadata
    ) {
        df::add(&mut container.id, key, metadata);
    }

    // =========================================
    // ADDING DYNAMIC OBJECT FIELDS
    // =========================================
    
    public fun create_item(
        value: u64, 
        description: String, 
        ctx: &mut TxContext
    ): Item {
        Item {
            id: object::new(ctx),
            value,
            description,
        }
    }

    // Add an object as a dynamic field
    public fun add_item_to_container(
        container: &mut Container,
        key: String,
        item: Item
    ) {
        dof::add(&mut container.id, key, item);
    }

    // =========================================
    // READING DYNAMIC FIELDS
    // =========================================

    // Check if a field exists
    public fun has_field(container: &Container, key: String): bool {
        df::exists_(&container.id, key)
    }

    // Read a value field (immutable reference)
    public fun get_number_field(container: &Container, key: String): &u64 {
        df::borrow(&container.id, key)
    }

    // Read a mutable reference to a field
    public fun get_number_field_mut(container: &mut Container, key: String): &mut u64 {
        df::borrow_mut(&mut container.id, key)
    }

    // Read an object field
    public fun get_item(container: &Container, key: String): &Item {
        dof::borrow(&container.id, key)
    }

    // Read a mutable object field
    public fun get_item_mut(container: &mut Container, key: String): &mut Item {
        dof::borrow_mut(&mut container.id, key)
    }

    // =========================================
    // UPDATING DYNAMIC FIELDS
    // =========================================

    // Update a value field directly
    public fun update_number_field(
        container: &mut Container,
        key: String,
        new_value: u64
    ) {
        let field_ref = df::borrow_mut(&mut container.id, key);
        *field_ref = new_value;
    }

    // Update an object field
    public fun update_item_value(
        container: &mut Container,
        key: String,
        new_value: u64
    ) {
        let item = dof::borrow_mut(&mut container.id, key);
        item.value = new_value;
    }

    // =========================================
    // REMOVING DYNAMIC FIELDS
    // =========================================

    // Remove and return a value field
    public fun remove_number_field(
        container: &mut Container,
        key: String
    ): u64 {
        df::remove(&mut container.id, key)
    }

    // Remove and return an object field
    public fun remove_item(
        container: &mut Container,
        key: String
    ): Item {
        dof::remove(&mut container.id, key)
    }

    // =========================================
    // COMPLEX EXAMPLE: USER PROFILE
    // =========================================

    struct UserProfile has key {
        id: UID,
        username: String,
    }

    struct Achievement has copy, drop, store {
        title: String,
        points: u64,
        unlocked_at: u64,
    }

    struct NFT has key, store {
        id: UID,
        name: String,
        rarity: u8,
    }

    public fun create_user_profile(username: String, ctx: &mut TxContext): UserProfile {
        UserProfile {
            id: object::new(ctx),
            username,
        }
    }

    // Add various types of data to user profile
    public fun setup_user_profile(
        profile: &mut UserProfile,
        level: u64,
        achievements: vector<Achievement>,
        nft: NFT,
        settings: vector<String>
    ) {
        // Add simple fields
        df::add(&mut profile.id, b"level".to_string(), level);
        df::add(&mut profile.id, b"settings".to_string(), settings);
        
        // Add complex struct
        df::add(&mut profile.id, b"achievements".to_string(), achievements);
        
        // Add object field
        dof::add(&mut profile.id, b"featured_nft".to_string(), nft);
    }

    // =========================================
    // PRACTICAL PATTERNS
    // =========================================

    // Pattern 1: Conditional field access with default values
    public fun get_level_or_default(profile: &UserProfile): u64 {
        if (df::exists_(&profile.id, b"level".to_string())) {
            *df::borrow(&profile.id, b"level".to_string())
        } else {
            1 // default level
        }
    }

    // Pattern 2: Batch operations
    public fun add_multiple_stats(
        profile: &mut UserProfile,
        health: u64,
        mana: u64,
        experience: u64
    ) {
        df::add(&mut profile.id, b"health".to_string(), health);
        df::add(&mut profile.id, b"mana".to_string(), mana);
        df::add(&mut profile.id, b"experience".to_string(), experience);
    }

    // Pattern 3: Field migration/upgrade
    public fun upgrade_user_stats(profile: &mut UserProfile) {
        // Check if old format exists
        if (df::exists_(&profile.id, b"old_stats".to_string())) {
            // Remove old format
            let _old_stats: u64 = df::remove(&mut profile.id, b"old_stats".to_string());
            
            // Add new format
            df::add(&mut profile.id, b"detailed_stats".to_string(), vector[100u64, 50u64, 200u64]);
        }
    }

    // =========================================
    // KEY CONSIDERATIONS & BEST PRACTICES
    // =========================================
    /*
    1. KEY TYPES:
       - Keys can be any type with copy + drop + store
       - Common: String, u64, address, vector<u8>
       - Use consistent key naming conventions

    2. GAS CONSIDERATIONS:
       - Adding fields costs gas proportional to key+value size
       - Reading is cheap, writing is more expensive
       - Removing fields refunds some gas

    3. STORAGE PATTERNS:
       - Use dynamic_field for simple values
       - Use dynamic_object_field for objects you want to transfer separately
       - Consider data locality - frequently accessed fields should be in main struct

    4. SECURITY:
       - Dynamic fields are publicly readable if the parent object is shared
       - Use capability patterns for access control
       - Validate keys before operations

    5. QUERYING:
       - Fields can be discovered via RPC calls
       - Plan your key structure for efficient querying
       - Consider using prefixes for categorization (e.g., "stat_", "config_")
    */

    // =========================================
    // ERROR HANDLING EXAMPLE
    // =========================================

    // Safe field access with proper error handling
    public fun safe_get_field(container: &Container, key: String): Option<u64> {
        if (df::exists_(&container.id, key)) {
            option::some(*df::borrow(&container.id, key))
        } else {
            option::none()
        }
    }

    // Custom error codes for better debugging
    const EFieldNotFound: u64 = 1;
    const EInvalidKey: u64 = 2;

    public fun get_required_field(container: &Container, key: String): u64 {
        assert!(df::exists_(&container.id, key), EFieldNotFound);
        *df::borrow(&container.id, key)
    }
}