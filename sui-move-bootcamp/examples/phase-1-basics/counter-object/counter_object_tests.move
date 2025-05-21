module counter::counter_object_tests {
    use sui::tx_context::{TxContext, new_tx_context};
    use sui::object;
    use counter::counter::{Counter, create, increment};

    //Always remember when writing tests you start use the following thought process: Arrange, Act, Assert

    // Test function to check that only the owner can increment.
    #[test]
    public fun test_owner_can_increment() {
        let mut ctx = new_tx_context(@0x1); // Simulate a transaction from address 0x1
        create(&mut ctx); // Create a new Counter object

        // Fetch the created counter object
        let counter_id = object::last_created_object_id(&ctx);
        let mut counter = object::borrow_mut<Counter>(counter_id);

        // Owner (0x1) tries to increment
        increment(&mut counter, &ctx);

        // Check that the value is now 1
        assert!(counter.value == 1, 100);
    }

    // Test function to check that non-owner cannot increment.
    #[test]
    public fun test_non_owner_cannot_increment() {
        let mut ctx = new_tx_context(@0x1); // Simulate a transaction from address 0x1
        create(&mut ctx); // Create a new Counter object

        // Fetch the created counter object
        let counter_id = object::last_created_object_id(&ctx);
        let mut counter = object::borrow_mut<Counter>(counter_id);

        // Simulate a transaction from a different address (0x2)
        let ctx2 = new_tx_context(@0x2);

        // Non-owner (0x2) tries to increment - should fail
        // This should abort due to the assert in increment
        increment(&mut counter, &ctx2);
    }
}
