// =========================================
// SUI MOVE DYNAMIC FIELDS - STEP BY STEP TUTORIAL
// =========================================

module game::character_system {
    use sui::object::{Self, UID};
    use sui::dynamic_field as df;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string::String;

    // =========================================
    // STEP 1: WHAT IS A DYNAMIC FIELD?
    // =========================================
    /*
    🎯 IMAGINE: You have a game character, but you don't know in advance 
    what stats, skills, or items they'll have. Dynamic fields let you 
    add ANY data to objects at runtime!

    It's like having a magic backpack that can hold anything:
    - Numbers (health, mana, level)
    - Text (skills, achievements)
    - Other objects (weapons, armor)
    */

    // Start with a simple game character
    struct GameCharacter has key {
        id: UID,           // Required for dynamic fields
        name: String,      // Fixed data we know upfront
    }

    // Create a basic character
    public fun create_character(name: String, ctx: &mut TxContext) {
        let character = GameCharacter {
            id: object::new(ctx),
            name,
        };
        transfer::transfer(character, tx_context::sender(ctx));
    }

    // =========================================
    // STEP 2: ADDING YOUR FIRST DYNAMIC FIELD
    // =========================================
    /*
    🔧 THE BASIC OPERATION: df::add(object_id, key, value)
    
    Think of it like: character["health"] = 100
    */

    // Add a single stat to our character
    public fun add_health(character: &mut GameCharacter, health_points: u64) {
        // The magic happens here! Add health as a dynamic field
        df::add(&mut character.id, b"health".to_string(), health_points);
        //      ^object          ^key              ^value
    }

    // Add more stats one by one
    public fun add_strength(character: &mut GameCharacter, strength: u64) {
        df::add(&mut character.id, b"strength".to_string(), strength);
    }

    public fun add_mana(character: &mut GameCharacter, mana: u64) {
        df::add(&mut character.id, b"mana".to_string(), mana);
    }

    // =========================================
    // STEP 3: READING DYNAMIC FIELDS
    // =========================================
    /*
    🔍 READING DATA: df::borrow(object_id, key)
    
    Like asking: "What's the character's health?"
    */

    // Check if a field exists first (important!)
    public fun has_health(character: &GameCharacter): bool {
        df::exists_(&character.id, b"health".to_string())
    }

    // Read the health value
    public fun get_health(character: &GameCharacter): u64 {
        // Always check if it exists first!
        assert!(df::exists_(&character.id, b"health".to_string()), 0);
        
        *df::borrow(&character.id, b"health".to_string())
    }

    // Better: Read with a default value if it doesn't exist
    public fun get_health_safe(character: &GameCharacter): u64 {
        if (df::exists_(&character.id, b"health".to_string())) {
            *df::borrow(&character.id, b"health".to_string())
        } else {
            100  // Default health
        }
    }

    // =========================================
    // STEP 4: UPDATING DYNAMIC FIELDS
    // =========================================
    /*
    ✏️ CHANGING VALUES: df::borrow_mut(object_id, key)
    
    Like: "Increase the character's health by 50"
    */

    // Heal the character
    public fun heal_character(character: &mut GameCharacter, healing: u64) {
        if (df::exists_(&character.id, b"health".to_string())) {
            let health_ref = df::borrow_mut(&mut character.id, b"health".to_string());
            *health_ref = *health_ref + healing;
        }
    }

    // Take damage
    public fun take_damage(character: &mut GameCharacter, damage: u64) {
        if (df::exists_(&character.id, b"health".to_string())) {
            let health_ref = df::borrow_mut(&mut character.id, b"health".to_string());
            if (*health_ref > damage) {
                *health_ref = *health_ref - damage;
            } else {
                *health_ref = 0;  // Character dies
            }
        }
    }

    // =========================================
    // STEP 5: REMOVING DYNAMIC FIELDS
    // =========================================
    /*
    REMOVING DATA: df::remove(object_id, key)
    
    Sometimes you want to remove temporary effects or reset stats
    */

    // Remove a temporary buff
    public fun remove_strength_buff(character: &mut GameCharacter) {
        if (df::exists_(&character.id, b"temp_strength_buff".to_string())) {
            let _removed_buff: u64 = df::remove(&mut character.id, b"temp_strength_buff".to_string());
            // The value is returned and dropped (discarded with _)
        }
    }

    // =========================================
    // STEP 6: STORING COMPLEX DATA (STRUCTS)
    // =========================================
    /*
    📦 BEYOND NUMBERS: You can store custom structs too!
    
    Requirements: The struct needs copy + drop + store abilities
    */

    // A more complex piece of data
    struct PlayerStats has copy, drop, store {
        health: u64,
        mana: u64,
        strength: u64,
        intelligence: u64,
        level: u64,
    }

    // Add all stats at once using a struct
    public fun set_all_stats(
        character: &mut GameCharacter,
        health: u64,
        mana: u64,
        strength: u64,
        intelligence: u64,
        level: u64
    ) {
        let stats = PlayerStats {
            health,
            mana,
            strength,
            intelligence,
            level,
        };
        
        df::add(&mut character.id, b"stats".to_string(), stats);
    }

    // Read the entire stats struct
    public fun get_all_stats(character: &GameCharacter): (u64, u64, u64, u64, u64) {
        if (df::exists_(&character.id, b"stats".to_string())) {
            let stats = df::borrow(&character.id, b"stats".to_string());
            (stats.health, stats.mana, stats.strength, stats.intelligence, stats.level)
        } else {
            (100, 50, 10, 10, 1)  // Default values
        }
    }

    // =========================================
    // STEP 7: STORING LISTS (VECTORS)
    // =========================================
    /*
    📝 LISTS OF DATA: Perfect for skills, inventory, etc.
    
    Characters can learn multiple skills over time!
    */

    // Learn a new skill
    public fun learn_skill(character: &mut GameCharacter, skill_name: String) {
        let skills_key = b"skills".to_string();
        
        if (df::exists_(&character.id, skills_key)) {
            // Add to existing skills
            let skills = df::borrow_mut(&mut character.id, skills_key);
            vector::push_back(skills, skill_name);
        } else {
            // Create new skills list
            let new_skills = vector::empty<String>();
            vector::push_back(&mut new_skills, skill_name);
            df::add(&mut character.id, skills_key, new_skills);
        }
    }

    // Check if character knows a skill
    public fun knows_skill(character: &GameCharacter, skill_name: String): bool {
        let skills_key = b"skills".to_string();
        if (!df::exists_(&character.id, skills_key)) return false;
        
        let skills = df::borrow(&character.id, skills_key);
        vector::contains(skills, &skill_name)
    }

    // Get all skills
    public fun get_skills(character: &GameCharacter): vector<String> {
        let skills_key = b"skills".to_string();
        if (df::exists_(&character.id, skills_key)) {
            *df::borrow(&character.id, skills_key)
        } else {
            vector::empty<String>()
        }
    }

    // =========================================
    // STEP 8: DYNAMIC OBJECT FIELDS (ADVANCED)
    // =========================================
    /*
    🗡️ STORING OBJECTS: For things that are objects themselves
    
    Weapons and armor are objects that can exist independently
    Use dof:: instead of df:: for objects with key+store abilities
    */

    struct Weapon has key, store {
        id: UID,
        name: String,
        damage: u64,
    }

    // Create a weapon
    public fun create_weapon(name: String, damage: u64, ctx: &mut TxContext) {
        let weapon = Weapon {
            id: object::new(ctx),
            name,
            damage,
        };
        transfer::transfer(weapon, tx_context::sender(ctx));
    }

    // Equip a weapon (attach it to character as a dynamic object field)
    public fun equip_weapon(character: &mut GameCharacter, weapon: Weapon) {
        dof::add(&mut character.id, b"weapon".to_string(), weapon);
        //  ^use dof for objects     ^key            ^object value
    }

    // Check weapon stats
    public fun get_weapon_damage(character: &GameCharacter): u64 {
        if (dof::exists_(&character.id, b"weapon".to_string())) {
            let weapon = dof::borrow(&character.id, b"weapon".to_string());
            weapon.damage
        } else {
            5  // Bare hands damage
        }
    }

    // Unequip weapon (returns the weapon object)
    public fun unequip_weapon(character: &mut GameCharacter): Weapon {
        assert!(dof::exists_(&character.id, b"weapon".to_string()), 1);
        dof::remove(&mut character.id, b"weapon".to_string())
    }

    // =========================================
    // STEP 9: PRACTICAL PATTERNS
    // =========================================
    /*
    🎯 REAL WORLD USAGE: Common patterns you'll use
    */

    // Pattern 1: Batch operations (do multiple things at once)
    public fun initialize_new_character(
        character: &mut GameCharacter,
        starting_health: u64,
        starting_mana: u64,
        starting_class: String
    ) {
        // Set multiple fields efficiently
        df::add(&mut character.id, b"health".to_string(), starting_health);
        df::add(&mut character.id, b"mana".to_string(), starting_mana);
        df::add(&mut character.id, b"class".to_string(), starting_class);
        
        // Give starting skill
        let starting_skills = vector[b"Basic Attack".to_string()];
        df::add(&mut character.id, b"skills".to_string(), starting_skills);
    }

    // Pattern 2: Calculated values (combine multiple fields)
    public fun get_total_power(character: &GameCharacter): u64 {
        let base_strength = if (df::exists_(&character.id, b"strength".to_string())) {
            *df::borrow(&character.id, b"strength".to_string())
        } else { 10 };
        
        let weapon_damage = get_weapon_damage(character);
        
        base_strength + weapon_damage
    }

    // Pattern 3: Conditional updates (level up system)
    public fun try_level_up(character: &mut GameCharacter): bool {
        // Check if character has enough experience
        if (df::exists_(&character.id, b"experience".to_string()) && 
            df::exists_(&character.id, b"level".to_string())) {
            
            let exp = *df::borrow(&character.id, b"experience".to_string());
            let level = *df::borrow(&character.id, b"level".to_string());
            
            if (exp >= level * 100) { // Need 100 exp per level
                // Level up!
                let level_ref = df::borrow_mut(&mut character.id, b"level".to_string());
                *level_ref = *level_ref + 1;
                
                // Bonus health on level up
                if (df::exists_(&character.id, b"health".to_string())) {
                    let health_ref = df::borrow_mut(&mut character.id, b"health".to_string());
                    *health_ref = *health_ref + 20;
                }
                
                return true
            }
        };
        false
    }

    // =========================================
    // STEP 10: ERROR HANDLING & BEST PRACTICES
    // =========================================
    /*
    🛡️ BEING SAFE: Always handle missing data gracefully
    */

    // Custom error codes
    const EFieldNotFound: u64 = 1;
    const EInsufficientHealth: u64 = 2;
    const ENoWeaponEquipped: u64 = 3;

    // Safe operations with proper error handling
    public fun cast_spell(character: &mut GameCharacter, mana_cost: u64): bool {
        // Check if character has mana field
        if (!df::exists_(&character.id, b"mana".to_string())) {
            return false // Can't cast without mana system
        };
        
        let mana_ref = df::borrow_mut(&mut character.id, b"mana".to_string());
        if (*mana_ref >= mana_cost) {
            *mana_ref = *mana_ref - mana_cost;
            true // Spell cast successfully
        } else {
            false // Not enough mana
        }
    }

    // =========================================
    // KEY TAKEAWAYS FOR BEGINNERS
    // =========================================
    /*
    🎓 REMEMBER THESE CORE CONCEPTS:

    1. ADDING DATA: df::add(object_id, key, value)
       - Like character["health"] = 100

    2. READING DATA: df::borrow(object_id, key)  
       - Always check df::exists_() first!

    3. UPDATING DATA: df::borrow_mut(object_id, key)
       - Get a mutable reference and change it

    4. REMOVING DATA: df::remove(object_id, key)
       - Returns the value that was removed

    5. FOR OBJECTS: Use dof:: instead of df::
       - dof::add(), dof::borrow(), etc.

    🔑 BEST PRACTICES:
    Always check if fields exist before accessing
    Provide default values for missing data
    Use consistent key naming ("health", not "hp" sometimes)
    Group related operations together
    Handle errors gracefully

    🚀 START SIMPLE:
    - Begin with single values (numbers, strings)
    - Move to structs for grouped data
    - Add vectors for lists
    - Finally use object fields for complex items

    Dynamic fields are perfect for games because players do
    unpredictable things - they learn different skills, find
    different items, and progress in unique ways!
    */
}