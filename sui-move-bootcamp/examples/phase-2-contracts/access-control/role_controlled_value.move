// This module demonstrates a simple role-based access control pattern in Sui Move.
// - There is a stored value (e.g., a number) in a struct.
// - Only addresses with a specific role (e.g., "admin") can update this value.
// - The admin role is set at initialization and can be changed by the current admin.
// - Anyone can read the value, but only the admin can update it.
//
// Key concepts used:
// - Structs with the `key` ability to store state on-chain.
// - Address comparison for access control.
// - Public and private functions for enforcing permissions.




module example::role_controlled_value {
    // Import the address type for storing and comparing addresses.
    use sui::tx_context::TxContext;
    use sui::object;

    // This struct stores the value and the admin address.
    public struct ControlledValue has key {
        id: object::UID,      // Unique object ID for Sui object storage.
        value: u64,           // The value that can be updated.
        admin: address,       // The address with permission to update the value.
    }

    // Public function to initialize the ControlledValue object with an admin.
    public fun init(admin: address, ctx: &mut TxContext): ControlledValue {
        // Create a new ControlledValue object with the given admin and value 0.
        ControlledValue {
            id: object::new(ctx), // Generate a unique ID for the object.
            value: 0,             // Initialize value to 0.
            admin,                // Set the admin address.
        }
    }

    // Public function to read the value.
    public fun get_value(obj: &ControlledValue): u64 {
        // Return the stored value.
        obj.value
    }

    // Public function to update the value, only allowed for the admin.
    public fun update_value(obj: &mut ControlledValue, new_value: u64, ctx: &TxContext) {
        // Ensure the caller is the admin.
        assert!(ctx.sender() == obj.admin, 0);

        // Update the value.
        obj.value = new_value;
    }

    // Public function to change the admin, only allowed for the current admin.
    public fun change_admin(obj: &mut ControlledValue, new_admin: address, ctx: &TxContext) {
        // Ensure the caller is the current admin.
        assert!(ctx.sender() == obj.admin, 1);

        // Update the admin address.
        obj.admin = new_admin;
    }
}
