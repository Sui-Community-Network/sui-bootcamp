// Sui Move Resources: Comprehensive Guide
// This module demonstrates all key concepts for handling resources in Sui Move

module All-things-Sui_Move::resource_patterns {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string::{Self, String};

    // ========================================================================================
    // PHANTOM TYPES SECTION
    // ========================================================================================
    
    /// Phantom types are generic type parameters that don't appear in struct fields
    /// They're used for type safety without runtime overhead
    /// Here we create different "currencies" using phantom types
    
    // Phantom type markers - these exist only at compile time
    struct USD {}
    struct EUR {}
    struct BTC {}
    
    /// Generic Coin struct using phantom type T
    /// The phantom type T ensures type safety between different currency types
    /// You can't accidentally mix USD coins with EUR coins
    struct Coin<phantom T> has key, store {
        id: UID,
        value: u64,
        // Notice: T doesn't appear in any field - that's what makes it "phantom"
    }
    
    // ========================================================================================
    // WITNESS PATTERN SECTION
    // ========================================================================================
    
    /// Witness Pattern: A witness is a temporary object that proves authorization
    /// It's like showing an ID card - once verified, the ID is no longer needed
    /// Witnesses are typically consumed (destroyed) after use
    
    /// This witness proves you have permission to mint coins
    struct MintAuthority<phantom T> {
        // Empty struct - its mere existence is the "proof"
        // The witness doesn't need to store data, just exist
    }
    
    /// Function that requires a witness to operate
    /// The witness parameter proves the caller has authorization
    public fun mint_coin<T>(
        _witness: MintAuthority<T>,  // Witness consumed here (notice the _)
        amount: u64,
        ctx: &mut TxContext
    ): Coin<T> {
        // The witness proves authorization, so we can safely mint
        Coin {
            id: object::new(ctx),
            value: amount,
        }
    }
    
    // ========================================================================================
    // ONE-TIME WITNESS (OTW) SECTION
    // ========================================================================================
    
    /// One-Time Witness: A special witness that can only be created ONCE per module
    /// Perfect for initialization tasks that should only happen once
    /// Must follow specific naming: same as module name but UPPERCASE
    
    struct RESOURCE_PATTERNS has drop {
        // OTW struct must:
        // 1. Have same name as module (RESOURCE_PATTERNS)
        // 2. Have only the 'drop' ability
        // 3. Have no fields
    }
    
    /// Module initializer - automatically called once when module is published
    /// The OTW is automatically created and passed to this function
    fun init(witness: RESOURCE_PATTERNS, ctx: &mut TxContext) {
        // This runs exactly once when the module is deployed
        // Use the OTW to create singleton objects or admin capabilities
        
        let admin_cap = AdminCapability {
            id: object::new(ctx),
            module_witness: witness,  // Store the OTW to prove authenticity
        };
        
        // Transfer admin capability to the publisher
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }
    
    /// Admin capability that uses the OTW as proof of authenticity
    struct AdminCapability has key {
        id: UID,
        module_witness: RESOURCE_PATTERNS,  // Proves this came from module init
    }
    
    // ========================================================================================
    // TEMPLATE LITERALS AND DYNAMIC TYPES SECTION
    // ========================================================================================
    
    /// Template-like pattern for creating different resource types
    /// This demonstrates how to use generic parameters for flexible resource creation
    
    /// Generic Resource struct that can represent different types of assets
    struct GenericResource<phantom AssetType, phantom Permission> has key, store {
        id: UID,
        name: String,
        metadata: vector<u8>,  // Flexible data storage
        authority_level: u8,   // Different permission levels
    }
    
    // Type markers for different asset types (template-like usage)
    struct NFT {}
    struct GameItem {}
    struct Certificate {}
    
    // Permission level markers
    struct PublicAccess {}
    struct PrivateAccess {}
    struct AdminAccess {}
    
    /// Factory function that creates resources based on template parameters
    /// This is similar to template literals - the type parameters act like templates
    public fun create_resource<AssetType, Permission>(
        name: vector<u8>,
        metadata: vector<u8>,
        authority_level: u8,
        _authority: &AdminCapability,  // Witness for authorization
        ctx: &mut TxContext
    ): GenericResource<AssetType, Permission> {
        GenericResource {
            id: object::new(ctx),
            name: string::utf8(name),
            metadata,
            authority_level,
        }
    }
    
    // ========================================================================================
    // WITNESS HIERARCHIES AND ADVANCED PATTERNS
    // ========================================================================================
    
    /// Hierarchical witness pattern - witnesses can have relationships
    /// This creates a chain of authorization
    
    struct SuperAdmin {}
    struct RegularAdmin { super_witness: SuperAdmin }
    struct User { admin_witness: RegularAdmin }
    
    /// Function showing witness hierarchy in action
    public fun privileged_operation(
        user_witness: User,
        ctx: &mut TxContext
    ): GenericResource<Certificate, AdminAccess> {
        // User witness contains admin witness, which contains super witness
        // This creates a verifiable chain of authorization
        let User { admin_witness } = user_witness;
        let RegularAdmin { super_witness: _ } = admin_witness;
        
        // Chain verified, proceed with operation
        GenericResource {
            id: object::new(ctx),
            name: string::utf8(b"Privilege Certificate"),
            metadata: b"Issued through witness hierarchy",
            authority_level: 100,
        }
    }
    
    // ========================================================================================
    // RESOURCE LIFECYCLE MANAGEMENT
    // ========================================================================================
    
    /// Demonstrates complete resource lifecycle with proper witness usage
    
    /// Capability that allows resource destruction
    struct DestroyCapability<phantom T> {
        // Phantom type ensures capability matches resource type
    }
    
    /// Create a resource with its corresponding destroy capability
    public fun create_with_destroy_cap<T>(
        value: u64,
        ctx: &mut TxContext
    ): (Coin<T>, DestroyCapability<T>) {
        let coin = Coin {
            id: object::new(ctx),
            value,
        };
        
        let destroy_cap = DestroyCapability<T> {};
        
        (coin, destroy_cap)
    }
    
    /// Safely destroy a resource using its capability (witness pattern)
    public fun destroy_coin<T>(
        coin: Coin<T>,
        _capability: DestroyCapability<T>  // Witness proves authorization
    ): u64 {
        let Coin { id, value } = coin;
        object::delete(id);
        value  // Return extracted value
    }
    
    // ========================================================================================
    // PRACTICAL EXAMPLES AND USAGE PATTERNS
    // ========================================================================================
    
    /// Example: Creating type-safe currency exchange
    public fun exchange_usd_to_eur(
        usd_coin: Coin<USD>,
        exchange_rate: u64,  // Rate * 1000 (e.g., 850 = 0.85 EUR per USD)
        ctx: &mut TxContext
    ): Coin<EUR> {
        // Extract value from USD coin
        let Coin { id, value } = usd_coin;
        object::delete(id);
        
        // Calculate EUR amount
        let eur_amount = (value * exchange_rate) / 1000;
        
        // Create new EUR coin
        Coin {
            id: object::new(ctx),
            value: eur_amount,
        }
    }
    
    /// Example: Batch operations with witness verification
    public fun batch_mint<T>(
        witness: MintAuthority<T>,
        amounts: vector<u64>,
        ctx: &mut TxContext
    ): vector<Coin<T>> {
        let coins = vector::empty<Coin<T>>();
        let i = 0;
        
        while (i < vector::length(&amounts)) {
            let amount = *vector::borrow(&amounts, i);
            let coin = Coin<T> {
                id: object::new(ctx),
                value: amount,
            };
            vector::push_back(&mut coins, coin);
            i = i + 1;
        };
        
        // Witness is automatically consumed when function ends
        coins
    }
    
    // ========================================================================================
    // KEY TAKEAWAYS AND BEST PRACTICES
    // ========================================================================================
    
    /*
    PHANTOM TYPES:
    - Use for compile-time type safety without runtime cost
    - Perfect for differentiating similar structures (currencies, permissions)
    - The phantom type never appears in struct fields
    
    WITNESS PATTERN:
    - Temporary objects that prove authorization
    - Consumed after use (like showing an ID then putting it away)
    - Enables secure operations without storing permanent permissions
    
    ONE-TIME WITNESS:
    - Special witness created only once per module
    - Used in init() function for one-time setup
    - Must follow naming convention and have only 'drop' ability
    
    TEMPLATE-LIKE PATTERNS:
    - Use generic parameters to create flexible, reusable code
    - Combine with phantom types for maximum type safety
    - Enable factory patterns and dynamic resource creation
    
    BEST PRACTICES:
    1. Always consume witnesses after verification
    2. Use phantom types for type safety
    3. Implement proper resource lifecycle management
    4. Create witness hierarchies for complex authorization
    5. Combine patterns for maximum flexibility and safety
    */
}