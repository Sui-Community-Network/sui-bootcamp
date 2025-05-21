module examples::my_coin {
    // Import the Coin module and TreasuryCap type from Sui framework.
    use sui::coin::{Self, TreasuryCap};
    // Import transaction context for creating objects.
    use sui::tx_context::TxContext;
    // Import transfer module for transferring objects.
    use sui::transfer;

    // Define a new struct called SUI_KENYA to represent our token type.
    public struct SUI_KENYA has drop {}

    // The init function is called once when the module is published.
    // It creates the new coin type and sets up its metadata.
    public fun init(witness: SUI_KENYA, ctx: &mut TxContext) {
        // Create the coin, set decimals to 6, symbol to "SUI_KENYA", and leave other metadata empty.
        let (treasury, metadata) = coin::create_currency(
            witness,         // The one-time witness for this coin type.
            6,               // Number of decimals for the token.
            b"SUI_KENYA",    // Symbol for the token.
            b"",             // Name (left empty here, you can fill in).
            b"",             // Description (left empty here).
            option::none(),  // Icon URL (optional, left empty).
            ctx              // Transaction context.
        );
        // Make the metadata object immutable.
        transfer::public_freeze_object(metadata);
        // Transfer the treasury capability to the publisher (so they can mint tokens).
        transfer::public_transfer(treasury, ctx.sender())
    }

    // Mint function: allows the treasury holder to mint new tokens to a recipient.
    public fun mint(
        treasury_cap: &mut TreasuryCap<SUI_KENYA>, // The authority to mint tokens.
        amount: u64,                               // Amount of tokens to mint.
        recipient: address,                        // Address to receive the tokens.
        ctx: &mut TxContext                        // Transaction context.
    ) {
        // Mint the tokens.
        let coin = coin::mint(treasury_cap, amount, ctx);
        // Transfer the minted tokens to the recipient.
        transfer::public_transfer(coin, recipient)
    }
}
