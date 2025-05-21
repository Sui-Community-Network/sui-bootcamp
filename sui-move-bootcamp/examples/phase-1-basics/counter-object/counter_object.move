module counter::counter-object {
    // Define the Counter struct. It will be stored on-chain.
    public struct Counter has key {
        id: UID,           // Unique ID for the object, required by Sui for all objects.
        owner: address,    // The address of the owner who can increment the counter.
        value: u64         // The current value of the counter.
    }

    // Function to create a new Counter object.
    public fun create(ctx: &mut TxContext) {
        // Create a new Counter object with the sender as the owner and value set to 0.
        transfer::share_object(Counter {
            id: object::new(ctx),     // Generate a new unique ID for the Counter.
            owner: ctx.sender(),      // Set the owner to the address that sent the transaction.
            value: 0                  // Initialize the counter value to 0.
        })
    }

    // Function to increment the counter. Only the owner can call this.
    public fun increment(counter: &mut Counter, ctx: &TxContext) {
        // Check that the sender is the owner of the counter.
        assert!(counter.owner == ctx.sender(), 0);
        // If the check passes, increment the value by 1.
        counter.value = counter.value + 1;
    }
}
