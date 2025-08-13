// =========================================
// SUI MOVE DYNAMIC OBJECT FIELDS - DEEP DIVE
// =========================================

module example::dynamic_object_fields_demo {
    use sui::object::{Self, UID, ID};
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string::{Self, String};

    // =========================================
    // WHAT ARE DYNAMIC OBJECT FIELDS?
    // =========================================
    /*
    Dynamic Object Fields store complete Sui objects (with key ability) as fields.
    Unlike regular dynamic fields, these objects:
    - Retain their own object ID
    - Can be transferred independently 
    - Can be discovered and queried as separate objects
    - Must have 'key' + 'store' abilities
    - Are more expensive in gas but offer more flexibility
    */

    // =========================================
    // OBJECT DEFINITIONS
    // =========================================

    // Parent container object
    struct Inventory has key {
        id: UID,
        owner: address,
        name: String,
    }

    // Objects that can be stored in dynamic object fields
    struct Weapon has key, store {
        id: UID,
        name: String,
        damage: u64,
        durability: u64,
        rarity: u8, // 1=common, 5=legendary
    }

    struct Armor has key, store {
        id: UID,
        name: String,
        defense: u64,
        weight: u64,
        slot: String, // "helmet", "chest", "boots"
    }

    struct Potion has key, store {
        id: UID,
        effect: String,
        potency: u64,
        uses_remaining: u64,
    }

    // Nested container - objects can contain other objects!
    struct Backpack has key, store {
        id: UID,
        capacity: u64,
        items_count: u64,
    }

    // =========================================
    // CREATING OBJECTS
    // =========================================

    public fun create_inventory(owner: address, name: String, ctx: &mut TxContext): Inventory {
        Inventory {
            id: object::new(ctx),
            owner,
            name,
        }
    }

    public fun create_weapon(
        name: String,
        damage: u64,
        durability: u64,
        rarity: u8,
        ctx: &mut TxContext
    ): Weapon {
        Weapon {
            id: object::new(ctx),
            name,
            damage,
            durability,
            rarity,
        }
    }

    public fun create_armor(
        name: String,
        defense: u64,
        weight: u64,
        slot: String,
        ctx: &mut TxContext
    ): Armor {
        Armor {
            id: object::new(ctx),
            name,
            defense,
            weight,
            slot,
        }
    }

    public fun create_potion(
        effect: String,
        potency: u64,
        uses: u64,
        ctx: &mut TxContext
    ): Potion {
        Potion {
            id: object::new(ctx),
            effect,
            potency,
            uses_remaining: uses,
        }
    }

    // =========================================
    // ADDING DYNAMIC OBJECT FIELDS
    // =========================================

    // Add weapon to inventory
    public fun equip_weapon(
        inventory: &mut Inventory,
        weapon: Weapon,
    ) {
        dof::add(&mut inventory.id, b"primary_weapon", weapon);
    }

    // Add armor piece
    public fun equip_armor(
        inventory: &mut Inventory,
        slot: String,
        armor: Armor,
    ) {
        // Use slot name as key for easy lookup
        dof::add(&mut inventory.id, slot, armor);
    }

    // Add potion with unique ID as key
    public fun add_potion(
        inventory: &mut Inventory,
        potion: Potion,
    ) {
        let potion_id = object::id(&potion);
        dof::add(&mut inventory.id, potion_id, potion);
    }

    // Add nested container
    public fun add_backpack(
        inventory: &mut Inventory,
        backpack: Backpack,
    ) {
        dof::add(&mut inventory.id, b"backpack", backpack);
    }

    // =========================================
    // ACCESSING DYNAMIC OBJECT FIELDS
    // =========================================

    // Check if object exists
    public fun has_weapon(inventory: &Inventory): bool {
        dof::exists_(&inventory.id, b"primary_weapon")
    }

    public fun has_armor_slot(inventory: &Inventory, slot: String): bool {
        dof::exists_(&inventory.id, slot)
    }

    // Get immutable reference to object
    public fun get_weapon(inventory: &Inventory): &Weapon {
        dof::borrow(&inventory.id, b"primary_weapon")
    }

    public fun get_armor(inventory: &Inventory, slot: String): &Armor {
        dof::borrow(&inventory.id, slot)
    }

    // Get mutable reference for modifications
    public fun get_weapon_mut(inventory: &mut Inventory): &mut Weapon {
        dof::borrow_mut(&mut inventory.id, b"primary_weapon")
    }

    public fun get_potion_mut(inventory: &mut Inventory, potion_id: ID): &mut Potion {
        dof::borrow_mut(&mut inventory.id, potion_id)
    }

    // =========================================
    // MODIFYING OBJECTS IN PLACE
    // =========================================

    // Damage weapon (reduces durability)
    public fun damage_weapon(inventory: &mut Inventory, damage: u64) {
        if (dof::exists_(&inventory.id, b"primary_weapon")) {
            let weapon = dof::borrow_mut(&mut inventory.id, b"primary_weapon");
            if (weapon.durability > damage) {
                weapon.durability = weapon.durability - damage;
            } else {
                weapon.durability = 0;
            };
        }
    }

    // Use potion (reduces uses_remaining)
    public fun use_potion(inventory: &mut Inventory, potion_id: ID): bool {
        if (dof::exists_(&inventory.id, potion_id)) {
            let potion = dof::borrow_mut(&mut inventory.id, potion_id);
            if (potion.uses_remaining > 0) {
                potion.uses_remaining = potion.uses_remaining - 1;
                true
            } else {
                false
            }
        } else {
            false
        }
    }

    // =========================================
    // REMOVING AND TRANSFERRING OBJECTS
    // =========================================

    // Remove and return object (unequip weapon)
    public fun unequip_weapon(inventory: &mut Inventory): Weapon {
        dof::remove(&mut inventory.id, b"primary_weapon")
    }

    // Remove armor piece
    public fun unequip_armor(inventory: &mut Inventory, slot: String): Armor {
        dof::remove(&mut inventory.id, slot)
    }

    // Remove and transfer object directly to another address
    public fun gift_weapon(
        inventory: &mut Inventory,
        recipient: address,
    ) {
        let weapon = dof::remove(&mut inventory.id, b"primary_weapon");
        transfer::public_transfer(weapon, recipient);
    }

    // Remove potion and delete if empty
    public fun consume_potion(inventory: &mut Inventory, potion_id: ID) {
        let potion = dof::remove(&mut inventory.id, potion_id);
        if (potion.uses_remaining == 0) {
            // Delete the object
            let Potion { id, effect: _, potency: _, uses_remaining: _ } = potion;
            object::delete(id);
        } else {
            // Put it back if still has uses
            dof::add(&mut inventory.id, potion_id, potion);
        }
    }

    // =========================================
    // NESTED DYNAMIC OBJECT FIELDS
    // =========================================

    // Add items to backpack that's inside inventory
    public fun add_item_to_backpack(
        inventory: &mut Inventory,
        item_key: String,
        item: Weapon, // Could be any object with key+store
    ) {
        // Get mutable reference to backpack
        let backpack = dof::borrow_mut(&mut inventory.id, b"backpack");
        
        // Add item to backpack's dynamic object fields
        dof::add(&mut backpack.id, item_key, item);
        backpack.items_count = backpack.items_count + 1;
    }

    // Get item from nested backpack
    public fun get_item_from_backpack(
        inventory: &Inventory,
        item_key: String,
    ): &Weapon {
        let backpack = dof::borrow(&inventory.id, b"backpack");
        dof::borrow(&backpack.id, item_key)
    }

    // =========================================
    // BATCH OPERATIONS
    // =========================================

    // Equip complete armor set
    public fun equip_armor_set(
        inventory: &mut Inventory,
        helmet: Armor,
        chest: Armor,
        boots: Armor,
    ) {
        dof::add(&mut inventory.id, string::utf8(b"helmet"), helmet);
        dof::add(&mut inventory.id, string::utf8(b"chest"), chest);
        dof::add(&mut inventory.id, string::utf8(b"boots"), boots);
    }

    // Unequip all armor
    public fun unequip_all_armor(inventory: &mut Inventory): (Armor, Armor, Armor) {
        let helmet = dof::remove(&mut inventory.id, string::utf8(b"helmet"));
        let chest = dof::remove(&mut inventory.id, string::utf8(b"chest"));
        let boots = dof::remove(&mut inventory.id, string::utf8(b"boots"));
        (helmet, chest, boots)
    }

    // =========================================
    // OBJECT FIELD QUERIES AND UTILITIES
    // =========================================

    // Get total defense from all equipped armor
    public fun calculate_total_defense(inventory: &Inventory): u64 {
        let mut total_defense = 0;
        
        if (dof::exists_(&inventory.id, string::utf8(b"helmet"))) {
            let helmet = dof::borrow(&inventory.id, string::utf8(b"helmet"));
            total_defense = total_defense + helmet.defense;
        };
        
        if (dof::exists_(&inventory.id, string::utf8(b"chest"))) {
            let chest = dof::borrow(&inventory.id, string::utf8(b"chest"));
            total_defense = total_defense + chest.defense;
        };
        
        if (dof::exists_(&inventory.id, string::utf8(b"boots"))) {
            let boots = dof::borrow(&inventory.id, string::utf8(b"boots"));
            total_defense = total_defense + boots.defense;
        };
        
        total_defense
    }

    // Get weapon damage (0 if no weapon)
    public fun get_attack_damage(inventory: &Inventory): u64 {
        if (dof::exists_(&inventory.id, b"primary_weapon")) {
            let weapon = dof::borrow(&inventory.id, b"primary_weapon");
            if (weapon.durability > 0) {
                weapon.damage
            } else {
                0 // Broken weapon does no damage
            }
        } else {
            0 // No weapon equipped
        }
    }

    // =========================================
    // ADVANCED PATTERNS
    // =========================================

    // Pattern 1: Object swapping
    public fun swap_weapons(
        inventory: &mut Inventory,
        new_weapon: Weapon,
    ): Weapon {
        let old_weapon = dof::remove(&mut inventory.id, b"primary_weapon");
        dof::add(&mut inventory.id, b"primary_weapon", new_weapon);
        old_weapon
    }

    // Pattern 2: Conditional object operations
    public fun repair_weapon_if_exists(inventory: &mut Inventory, repair_amount: u64) {
        if (dof::exists_(&inventory.id, b"primary_weapon")) {
            let weapon = dof::borrow_mut(&mut inventory.id, b"primary_weapon");
            weapon.durability = weapon.durability + repair_amount;
            // Cap at maximum durability (assuming 100)
            if (weapon.durability > 100) {
                weapon.durability = 100;
            };
        }
    }

    // Pattern 3: Object migration/upgrade
    public fun upgrade_weapon(
        inventory: &mut Inventory,
        ctx: &mut TxContext,
    ) {
        if (dof::exists_(&inventory.id, b"primary_weapon")) {
            let old_weapon = dof::remove(&mut inventory.id, b"primary_weapon");
            
            // Create upgraded version
            let upgraded_weapon = Weapon {
                id: object::new(ctx),
                name: old_weapon.name,
                damage: old_weapon.damage + 10, // +10 damage
                durability: 100, // Full durability
                rarity: old_weapon.rarity + 1, // Increase rarity
            };
            
            // Delete old weapon
            let Weapon { id, name: _, damage: _, durability: _, rarity: _ } = old_weapon;
            object::delete(id);
            
            // Add upgraded weapon
            dof::add(&mut inventory.id, b"primary_weapon", upgraded_weapon);
        }
    }

    // =========================================
    // KEY DIFFERENCES FROM REGULAR DYNAMIC FIELDS
    // =========================================
    /*
    1. OBJECT IDENTITY:
       - Dynamic object fields maintain their own object ID
       - Can be queried independently via RPC
       - Show up in wallet as separate objects

    2. TRANSFERABILITY:
       - Objects can be removed and transferred to other addresses
       - Support direct transfers without removing from parent

    3. ABILITIES REQUIRED:
       - Must have 'key' ability (to be an object)
       - Must have 'store' ability (to be stored in fields)

    4. GAS COSTS:
       - More expensive than regular dynamic fields
       - Each object has storage costs
       - Deletion refunds gas

    5. QUERYING:
       - Objects can be discovered via parent object
       - Each has its own object ID for direct access
       - Support complex nested queries

    6. LIFECYCLE:
       - Objects exist independently
       - Can survive parent object deletion (if transferred out)
       - Support complex ownership patterns
    */

    // =========================================
    // ERROR HANDLING
    // =========================================

    const EObjectNotFound: u64 = 1;
    const EInvalidSlot: u64 = 2;
    const EWeaponBroken: u64 = 3;

    public fun get_weapon_damage_safe(inventory: &Inventory): u64 {
        assert!(dof::exists_(&inventory.id, b"primary_weapon"), EObjectNotFound);
        let weapon = dof::borrow(&inventory.id, b"primary_weapon");
        assert!(weapon.durability > 0, EWeaponBroken);
        weapon.damage
    }

    // =========================================
    // CLEANUP FUNCTIONS
    // =========================================

    // Delete inventory and all contained objects
    public fun delete_inventory(inventory: Inventory) {
        let Inventory { id, owner: _, name: _ } = inventory;
        
        // Note: In practice, you'd need to remove all dynamic object fields
        // before deleting the parent object, or transfer them out
        
        object::delete(id);
    }
}