// This contract implements a basic on-chain marketplace using shared objects.
// - Anyone can create a Marketplace that accepts a specific Coin type.
// - Sellers can list arbitrary items for sale, specifying a price.
// - Buyers can purchase items, paying in the specified Coin type.
// - Sellers can withdraw their earnings from the marketplace.
// The contract uses Sui's Bag and Table collections to manage listings and payments.

module marketplace::marketplace {
    // Import UID for unique object IDs.
    use sui::object::{Self, UID};
    // Import Bag for heterogeneous collections (to store listings).
    use sui::bag;
    // Import Table for mapping addresses to Coin balances.
    use sui::table::{Self, Table};
    // Import Coin type and functions.
    use sui::coin::{Self, Coin};
    // Import transfer functions.
    use sui::transfer;
    // Import transaction context.
    use sui::tx_context::{Self, TxContext};
    // Import tx_context for sender address.
    use sui::tx_context;

    // Define the Marketplace shared object, parameterized by the Coin type.
    public struct Marketplace<phantom COIN> has key {
        // Unique ID for this Marketplace object.
        id: UID,
        // Bag to store all item listings (heterogeneous).
        items: Bag,
        // Table mapping seller addresses to their Coin balances (homogeneous).
        payments: Table<address, Coin<COIN>>
    }

    // Define a Listing struct to represent an item for sale.
    public struct Listing has key, store {
        // Unique ID for this Listing object.
        id: UID,
        // Price (in Coin<COIN>) for the item.
        ask: u64,
        // Address of the seller.
        owner: address,
    }

    // Create a new Marketplace shared object for a specific Coin type.
    puentry fun create<COIN>(ctx: &mut TxContext): Marketplace<COIN> {
        // Create a new UID for the Marketplace.
        let id = object::new(ctx);
        // Create an empty Bag for listings.
        let items = bag::new(ctx);
        // Create an empty Table for payments.
        let payments = table::new(ctx);
        // Return the new Marketplace object.
        Marketplace { id, items, payments }
    }

    // List an item for sale in the Marketplace.
    public entry fun list<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>, // The Marketplace shared object.
        item: T,                             // The item to list.
        ask: u64,                            // The price for the item.
        ctx: &mut TxContext                  // Transaction context.
    ) {
        // Get the object's unique ID.
        let item_id = object::id(&item);
        // Create a new Listing object.
        let listing = Listing {
            ask,
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
        };
        // Attach the item as a dynamic field to the Listing.
        ofield::add(&mut listing.id, true, item);
        // Add the Listing to the Marketplace's Bag of items.
        bag::add(&mut marketplace.items, item_id, listing)
    }

    // Remove a listing and return the item to the seller.
    fun delist<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>, // The Marketplace shared object.
        item_id: ID,                        // The ID of the item to delist.
        ctx: &mut TxContext                 // Transaction context.
    ): T {
        // Remove the Listing from the Bag.
        let Listing { id, owner, ask: _ } = bag::remove(&mut marketplace.items, item_id);
        // Ensure only the owner can delist.
        assert!(tx_context::sender(ctx) == owner, ENotOwner);
        // Remove the item from the Listing's dynamic field.
        let item = ofield::remove(&mut id, true);
        // Delete the Listing object.
        object::delete(id);
        // Return the item to the seller.
        item
    }

    // Public function to delist and transfer the item to the sender.
    public entry fun delist_and_take<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>, // The Marketplace shared object.
        item_id: ID,                        // The ID of the item to delist.
        ctx: &mut TxContext                 // Transaction context.
    ) {
        // Call delist and transfer the item to the sender.
        let item = delist<T, COIN>(marketplace, item_id, ctx);
        transfer::public_transfer(item, tx_context::sender(ctx));
    }

    // Internal function to buy an item and handle payment.
    fun buy<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>, // The Marketplace shared object.
        item_id: ID,                        // The ID of the item to buy.
        paid: Coin<COIN>,                   // The Coin object used for payment.
    ): T {
        // Remove the Listing from the Bag.
        let Listing { id, ask, owner } = bag::remove(&mut marketplace.items, item_id);
        // Ensure the payment matches the asking price.
        assert!(ask == coin::value(&paid), EAmountIncorrect);
        // If the seller already has a payment entry, merge the coins.
        if (table::contains<address, Coin<COIN>>(&marketplace.payments, owner)) {
            coin::join(
                table::borrow_mut<address, Coin<COIN>>(&mut marketplace.payments, owner),
                paid
            )
        } else {
            // Otherwise, add a new payment entry for the seller.
            table::add(&mut marketplace.payments, owner, paid)
        };
        // Remove the item from the Listing's dynamic field.
        let item = ofield::remove(&mut id, true);
        // Delete the Listing object.
        object::delete(id);
        // Return the purchased item.
        item
    }

    // Public function to buy and transfer the item to the buyer.
    public entry fun buy_and_take<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>, // The Marketplace shared object.
        item_id: ID,                        // The ID of the item to buy.
        paid: Coin<COIN>,                   // The Coin object used for payment.
        ctx: &mut TxContext                 // Transaction context.
    ) {
        // Call buy and transfer the item to the buyer.
        transfer::transfer(
            buy<T, COIN>(marketplace, item_id, paid),
            tx_context::sender(ctx)
        )
    }

    // Internal function for sellers to withdraw their earnings.
    fun take_profits<COIN>(
        marketplace: &mut Marketplace<COIN>, // The Marketplace shared object.
        ctx: &mut TxContext                  // Transaction context.
    ): Coin<COIN> {
        // Remove the seller's Coin balance from the payments Table.
        table::remove<address, Coin<COIN>>(&mut marketplace.payments, tx_context::sender(ctx))
    }

    // Public function to withdraw earnings and transfer to the seller.
    public entry fun take_profits_and_keep<COIN>(
        marketplace: &mut Marketplace<COIN>, // The Marketplace shared object.
        ctx: &mut TxContext                  // Transaction context.
    ) {
        // Call take_profits and transfer the Coin to the seller.
        transfer::transfer(
            take_profits(marketplace, ctx),
            tx_context::sender(ctx)
        )
    }
}
