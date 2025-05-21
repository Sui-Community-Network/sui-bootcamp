module example::role_controlled_value {
    // Import the TxContext type to get information about the transaction (like the sender).
    use sui::tx_context::TxContext;

    // Import object utilities like UID to create and store Sui objects.
    use sui::object;

    // Define a public struct called ControlledValue that can be stored on-chain.
    public struct ControlledValue has key {
        id: object::UID,      // Unique ID for this on-chain object (needed for storage in Sui).
        value: u64,           // A number that this object holds (can be changed).
        admin: address,       // The address (account) that is allowed to change the value.
    }

    // Function to create a new ControlledValue object with an admin address.
    public fun init(admin: address, ctx: &mut TxContext): ControlledValue {
        // Return a new ControlledValue with:
        // - A unique ID
        // - An initial value of 0
        // - The given admin address
        ControlledValue {
            id: object::new(ctx), // Generate a new unique ID using the context.
            value: 0,             // Start with the value set to 0.
            admin,                // Set the given address as the admin.
        }
    }

    // Function to get (read) the current value stored in the object.
    public fun get_value(obj: &ControlledValue): u64 {
        // Return the value field from the object.
        obj.value
    }

    // Function to update the value — only the admin is allowed to do this.
    public fun update_value(obj: &mut ControlledValue, new_value: u64, ctx: &TxContext) {
        // Check if the person trying to update is the admin.
        // If not, the transaction will fail with error code 0.
        assert!(ctx.sender() == obj.admin, 0);

        // If the check passed, update the value to the new value.
        obj.value = new_value;
    }

    // Function to change the admin address — only current admin can do this.
    public fun change_admin(obj: &mut ControlledValue, new_admin: address, ctx: &TxContext) {
        // Check if the sender is the current admin.
        // If not, the transaction fails with error code 1.
        assert!(ctx.sender() == obj.admin, 1);

        // If the sender is the admin, change the admin to the new address.
        obj.admin = new_admin;
    }
}
