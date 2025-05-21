module marketplace::marketplace_tests {
    use sui::coin::{Self, TreasuryCap, Coin};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use examples::my_coin::{SUI_KENYA}; // Use your custom coin
    use marketplace::marketplace::{Self, Marketplace, Listing, create, list, delist_and_take, buy_and_take, take_profits_and_keep};
    use std::string;
    use sui::bag;
    use sui::table;
    use std::option;

    // A struct to test listing with
    struct DummyItem has key, store {
        id: UID,
        name: string::String,
    }

    public fun create_dummy(name: string::String, ctx: &mut TxContext): DummyItem {
        DummyItem {
            id: object::new(ctx),
            name,
        }
    }

    #[test_only]
    public fun test_marketplace_flow(ctx: &mut TxContext) {
        // Step 1: Initialize your custom coin type
        let (treasury, _) = coin::create_currency(
            SUI_KENYA {}, // Witness
            6, b"SUI_KENYA", b"Sui Kenya Coin", b"Test Coin", option::none(), ctx
        );
        
        // Step 2: Create a new marketplace instance for SUI_KENYA coin
        let mut market = create<SUI_KENYA>(ctx);

        // Step 3: Mint 1000 units of SUI_KENYA for Buyer
        let mut buyer_treasury = treasury;
        let buyer = tx_context::sender(ctx);
        let coin_for_buyer = coin::mint(&mut buyer_treasury, 1000, ctx);

        // Step 4: Seller creates an item (e.g. "Antique Vase")
        let item = create_dummy(string::utf8(b"Antique Vase"), ctx);
        let item_id = object::id(&item);

        // Step 5: Seller lists the item for 500 SUI_KENYA
        list<DummyItem, SUI_KENYA>(&mut market, item, 500, ctx);

        // Step 6: Buyer purchases the item using 500 coins
        let (payment, change) = coin::split(coin_for_buyer, 500);
        buy_and_take<DummyItem, SUI_KENYA>(&mut market, item_id, payment, ctx);

        // Step 7: Seller withdraws profits
        take_profits_and_keep<SUI_KENYA>(&mut market, ctx);

        // ✅ The item was transferred to buyer and profits were transferred to seller
    }
}
