module examples::coin_module_tests {
    // Import the module we want to test
    use examples::my_coin;

    // Import the Coin module to check balances and coin types
    use sui::coin;

    // Import helper to create test transaction contexts
    use sui::test_scenario;

    // Import transaction context and address type
    use sui::tx_context::{TxContext, Self};

    // Import Coin type so we can specify what type of coin we're checking
    use sui::coin::Coin;

    #[test]
    public fun test_coin_creation_and_minting(ctx: &mut TxContext) {
        // 🧪 Step 1: Publish/init the coin and get TreasuryCap
        // ----------------------------------------------
        // Create a witness (just an empty struct used to prove we are initializing this coin type)
        let witness = my_coin::SUI_KENYA {};

        // Call the init function to create the token.
        // This sets up the coin type, metadata, and gives the sender (ctx.sender()) the TreasuryCap.
        my_coin::init(witness, ctx);

        // At this point, ctx.sender() owns the TreasuryCap<SUI_KENYA>
        // We need to retrieve it so we can use it in the minting step.

        // Use test_scenario to get the TreasuryCap from ctx.sender's owned objects
        let treasury = test_scenario::take_from_sender<TreasuryCap<my_coin::SUI_KENYA>>(ctx);

        // 🧪 Step 2: Mint 1,000,000 units of SUI_KENYA to another address
        // ----------------------------------------------
        let recipient_addr = @0xCAFE; // Fake address for the recipient

        // Mint 1,000,000 units of the token and send to recipient
        my_coin::mint(&mut treasury, 1_000_000, recipient_addr, ctx);

        // 🧪 Step 3: Retrieve recipient's coins and check balance
        // ----------------------------------------------
        // Get all the coins of type SUI_KENYA owned by recipient
        let coins = test_scenario::take_all::<Coin<my_coin::SUI_KENYA>>(ctx, recipient_addr);

        // There should be exactly 1 coin
        assert!(vector::length(&coins) == 1, 100);

        // Get the first (and only) coin
        let coin = *vector::borrow(&coins, 0);

        // Check the balance is 1,000,000
        let balance = coin::value(&coin);
        assert!(balance == 1_000_000, 101);
    }
}
