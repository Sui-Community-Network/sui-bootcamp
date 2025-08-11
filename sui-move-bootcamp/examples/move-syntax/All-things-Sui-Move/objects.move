module tutorial::objects {
    // =============================================================================
    // IMPORTS - Essential modules for working with objects in Sui Move
    // =============================================================================
    
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use std::vector;
    use sui::table::{Self, Table};
    use sui::dynamic_object_field as dof;

    // =============================================================================
    // 1. OBJECT ANATOMY AND STRUCTURE
    // =============================================================================
    
    // Every object in Sui has the following core structure:
    // - id: UID (Unique identifier - REQUIRED for all objects with 'key' ability)
    // - version: u64 (Version number managed automatically by Sui)
    // - Additional fields specific to your object
    
    // Basic object structure - MUST have 'key' ability to be stored globally
    public struct MyObject has key {
        id: UID,           // Unique identifier - REQUIRED
        value: u64,        // Custom data field
        name: String,      // Another custom field
    }

    // Object with different abilities - abilities define what operations are allowed
    public struct SimpleObject has key {
        id: UID,
        data: u64,
    }

    // 'copy' ability allows the object to be copied (rarely used for objects)
    public struct CopyableObject has key, copy {
        id: UID,
        value: u64,
    }

    // 'drop' ability allows the object to be automatically destroyed
    public struct DroppableObject has key, drop {
        id: UID,
        content: vector<u8>,
    }

    // 'store' ability allows the object to be stored inside other objects
    public struct StoreableObject has key, store {
        id: UID,
        metadata: String,
    }

    // =============================================================================
    // 2. BASIC OBJECT CREATION
    // =============================================================================
    
    // Example: Book object for our tutorial
    public struct Book has key, store {  // 'store' allows it to be stored in other objects
        id: UID,
        title: String,
        author: String,
        pages: u64,
        is_published: bool,
    }

    // Function to create a new Book object
    // 'ctx: &mut TxContext' is REQUIRED for creating new objects
    public fun create_book(
        title: String,
        author: String,
        pages: u64,
        ctx: &mut TxContext
    ): Book {
        Book {
            id: object::new(ctx),  // Create new UID - THIS IS REQUIRED
            title,                 // Shorthand for title: title
            author,
            pages,
            is_published: false,   // Default value
        }
    }

    // Entry function - can be called directly from transactions
    // Creates a book and transfers it to the caller
    public entry fun mint_book(
        title: String,
        author: String,
        pages: u64,
        ctx: &mut TxContext
    ) {
        let book = create_book(title, author, pages, ctx);
        // Transfer to the transaction sender
        transfer::transfer(book, tx_context::sender(ctx));
    }

    // =============================================================================
    // 3. OBJECT OWNERSHIP MODELS
    // =============================================================================

    // Model 1: OWNED OBJECTS - Owned by a specific address
    // Only the owner can use this object in transactions
    public entry fun transfer_book(
        book: Book,                    // Takes ownership of the book
        recipient: address,            // New owner address
        _ctx: &mut TxContext          // Underscore means parameter is unused
    ) {
        transfer::transfer(book, recipient);  // Transfer ownership
    }

    // Model 2: SHARED OBJECTS - Can be accessed by anyone
    // Multiple transactions can access shared objects concurrently
    public struct Library has key {
        id: UID,
        books: vector<Book>,           // Vector of books stored in the library
        name: String,
        public_access: bool,
    }

    // Create a shared library that anyone can access
    public entry fun create_shared_library(
        name: String,
        ctx: &mut TxContext
    ) {
        let library = Library {
            id: object::new(ctx),
            books: vector::empty<Book>(),  // Create empty vector
            name,
            public_access: true,
        };
        // Make it shared - now anyone can read/modify it
        transfer::share_object(library);
    }

    // Function that works with shared objects
    // Takes '&mut Library' - mutable reference to shared object
    public entry fun add_book_to_library(
        library: &mut Library,         // Mutable reference to shared object
        book: Book,                    // Take ownership of book
        _ctx: &mut TxContext
    ) {
        vector::push_back(&mut library.books, book);  // Add book to library
    }

    // Model 3: IMMUTABLE OBJECTS - Cannot be modified after freezing
    public entry fun freeze_book(
        book: Book,                    // Take ownership
        _ctx: &mut TxContext
    ) {
        transfer::freeze_object(book); // Make it immutable forever
        // After freezing, the object can only be read, never modified
    }

    // =============================================================================
    // 4. READING OBJECT DATA
    // =============================================================================

    // Public accessor functions - use references to avoid taking ownership
    public fun get_book_title(book: &Book): &String {
        &book.title  // Return reference to avoid copying
    }

    public fun get_book_author(book: &Book): &String {
        &book.author
    }

    public fun get_book_pages(book: &Book): u64 {
        book.pages   // u64 implements Copy, so this is fine
    }

    // Get the unique ID of an object
    public fun get_book_id(book: &Book): ID {
        object::id(book)  // Returns the object's unique ID
    }

    // Function that reads multiple fields efficiently
    public fun get_book_info(book: &Book): (String, String, u64, bool) {
        (
            *&book.title,      // Dereference to copy the string
            *&book.author,     // Dereference to copy the string
            book.pages,        // Direct copy for primitive types
            book.is_published
        )
    }

    // =============================================================================
    // 5. MODIFYING OBJECT DATA
    // =============================================================================

    // Mutable reference (&mut) is REQUIRED for modifications
    public entry fun update_book_pages(
        book: &mut Book,               // Mutable reference - can modify
        new_pages: u64,
        _ctx: &mut TxContext
    ) {
        book.pages = new_pages;        // Direct field assignment
    }

    // Function to update multiple fields
    public entry fun update_book_info(
        book: &mut Book,
        new_title: String,
        new_author: String,
        new_pages: u64,
        published: bool,
        _ctx: &mut TxContext
    ) {
        book.title = new_title;
        book.author = new_author;
        book.pages = new_pages;
        book.is_published = published;
    }

    // Conditional modification with assertions
    public entry fun publish_book(
        book: &mut Book,
        publisher: address,
        ctx: &mut TxContext
    ) {
        // Assert that only certain addresses can publish
        assert!(tx_context::sender(ctx) == publisher, 0);
        // Assert book has enough pages
        assert!(book.pages >= 10, 1);
        
        book.is_published = true;
    }

    // =============================================================================
    // 6. COMPLEX OBJECT MANIPULATION WITH TABLES
    // =============================================================================

    // BookStore using Table for efficient key-value storage
    public struct BookStore has key {
        id: UID,
        books: Table<ID, Book>,        // Table mapping book ID to book
        owner: address,
        store_name: String,
    }

    // Create a new bookstore
    public entry fun create_bookstore(
        store_name: String,
        ctx: &mut TxContext
    ) {
        let store = BookStore {
            id: object::new(ctx),
            books: table::new<ID, Book>(ctx),  // Create new table
            owner: tx_context::sender(ctx),
            store_name,
        };
        transfer::transfer(store, tx_context::sender(ctx));
    }

    // Add book to store (book is consumed/moved into the table)
    public entry fun add_book_to_store(
        store: &mut BookStore,
        book: Book,
        ctx: &mut TxContext
    ) {
        // Only owner can add books
        assert!(store.owner == tx_context::sender(ctx), 2);
        
        let book_id = object::id(&book);       // Get book ID before moving
        table::add(&mut store.books, book_id, book);  // Add to table
    }

    // Remove book from store (returns the book to caller)
    public entry fun remove_book_from_store(
        store: &mut BookStore,
        book_id: ID,
        ctx: &mut TxContext
    ): Book {
        // Only owner can remove books
        assert!(store.owner == tx_context::sender(ctx), 2);
        // Check if book exists
        assert!(table::contains(&store.books, book_id), 3);
        
        table::remove(&mut store.books, book_id)  // Remove and return book
    }

    // Check if store contains a specific book
    public fun store_has_book(store: &BookStore, book_id: ID): bool {
        table::contains(&store.books, book_id)
    }

    // Borrow book from store (read-only access)
    public fun borrow_book_from_store(store: &BookStore, book_id: ID): &Book {
        table::borrow(&store.books, book_id)
    }

    // =============================================================================
    // 7. OBJECT COMPOSITION AND RELATIONSHIPS
    // =============================================================================

    // Author object that references books by ID
    public struct Author has key {
        id: UID,
        name: String,
        books_written: vector<ID>,     // Store references to book objects
        birth_year: u64,
    }

    // Create new author
    public entry fun create_author(
        name: String,
        birth_year: u64,
        ctx: &mut TxContext
    ) {
        let author = Author {
            id: object::new(ctx),
            name,
            books_written: vector::empty<ID>(),
            birth_year,
        };
        transfer::transfer(author, tx_context::sender(ctx));
    }

    // Link a book to an author (add book ID to author's list)
    public entry fun add_book_to_author(
        author: &mut Author,
        book_id: ID,
        _ctx: &mut TxContext
    ) {
        // Check if book is not already linked
        assert!(!vector::contains(&author.books_written, &book_id), 4);
        vector::push_back(&mut author.books_written, book_id);
    }

    // Get all books written by an author
    public fun get_author_books(author: &Author): &vector<ID> {
        &author.books_written
    }

    // =============================================================================
    // 8. DYNAMIC OBJECT FIELDS
    // =============================================================================

    // Container that can hold any type of object as dynamic fields
    public struct Container has key {
        id: UID,
        name: String,
    }

    // Create container
    public entry fun create_container(
        name: String,
        ctx: &mut TxContext
    ) {
        let container = Container {
            id: object::new(ctx),
            name,
        };
        transfer::transfer(container, tx_context::sender(ctx));
    }

    // Add object to container as dynamic field
    // T: key + store means T must be an object type that can be stored
    public entry fun add_object_to_container<T: key + store>(
        container: &mut Container,
        field_name: String,
        object: T,                     // Generic object type
    ) {
        dof::add(&mut container.id, field_name, object);
    }

    // Borrow object from container (read-only)
    public fun borrow_from_container<T: key + store>(
        container: &Container,
        field_name: String,
    ): &T {
        dof::borrow(&container.id, field_name)
    }

    // Borrow object mutably from container
    public fun borrow_mut_from_container<T: key + store>(
        container: &mut Container,
        field_name: String,
    ): &mut T {
        dof::borrow_mut(&mut container.id, field_name)
    }

    // Remove object from container
    public fun remove_from_container<T: key + store>(
        container: &mut Container,
        field_name: String,
    ): T {
        dof::remove(&mut container.id, field_name)
    }

    // Check if container has a specific field
    public fun container_has_field(
        container: &Container,
        field_name: String,
    ): bool {
        dof::exists_(&container.id, field_name)
    }

    // =============================================================================
    // 9. ADVANCED PATTERNS
    // =============================================================================

    // PATTERN 1: Object Wrapping
    // Wrapper that can contain any storable object
    public struct Wrapper<T: store> has key {
        id: UID,
        inner: T,                      // The wrapped object
        wrapper_data: String,          // Additional metadata
        wrap_time: u64,
    }

    // Wrap any storable object
    public fun wrap_object<T: store>(
        object: T,
        wrapper_data: String,
        wrap_time: u64,
        ctx: &mut TxContext
    ): Wrapper<T> {
        Wrapper {
            id: object::new(ctx),
            inner: object,
            wrapper_data,
            wrap_time,
        }
    }

    // Unwrap object (destroys wrapper, returns inner object)
    public fun unwrap_object<T: store>(
        wrapper: Wrapper<T>
    ): T {
        let Wrapper { id, inner, wrapper_data: _, wrap_time: _ } = wrapper;
        object::delete(id);            // Clean up wrapper's UID
        inner                          // Return the wrapped object
    }

    // PATTERN 2: Hot Potato Pattern
    // Receipt that MUST be consumed (no drop ability)
    public struct Receipt<phantom T> {
        id: ID,
        action_type: String,
    }

    // Start a process that returns a receipt
    public fun start_book_process<T: key>(
        object: &T,
        action_type: String,
    ): Receipt<T> {
        Receipt {
            id: object::id(object),
            action_type,
        }
    }

    // Complete process (consumes receipt - hot potato pattern)
    public fun complete_book_process<T: key>(
        _receipt: Receipt<T>,          // Receipt is consumed here
        _object: &mut T,               // Object being processed
    ) {
        // Process the object
        // Receipt is automatically dropped since function consumed it
        // This ensures the process is completed
    }

    // PATTERN 3: Capability Pattern for Access Control
    public struct AdminCap has key {
        id: UID,
        system_id: ID,                 // ID of system this cap controls
    }

    public struct System has key {
        id: UID,
        public_data: String,
        admin_only_data: String,
        settings: vector<String>,
    }

    // Create system with admin capability
    public entry fun create_system_with_admin(
        public_data: String,
        admin_only_data: String,
        ctx: &mut TxContext
    ) {
        let system = System {
            id: object::new(ctx),
            public_data,
            admin_only_data,
            settings: vector::empty(),
        };
        
        let system_id = object::id(&system);
        let admin_cap = AdminCap {
            id: object::new(ctx),
            system_id,
        };
        
        let sender = tx_context::sender(ctx);
        transfer::transfer(system, sender);    // Transfer system
        transfer::transfer(admin_cap, sender); // Transfer admin capability
    }

    // Only admin can call this function
    public entry fun admin_update_system(
        cap: &AdminCap,                // Proof of admin rights
        system: &mut System,
        new_admin_data: String,
        _ctx: &mut TxContext
    ) {
        // Verify the capability is for this system
        assert!(cap.system_id == object::id(system), 5);
        system.admin_only_data = new_admin_data;
    }

    // Anyone can call this function
    public entry fun update_public_data(
        system: &mut System,
        new_public_data: String,
        _ctx: &mut TxContext
    ) {
        system.public_data = new_public_data;
    }

    // =============================================================================
    // 10. OBJECT LIFECYCLE MANAGEMENT
    // =============================================================================

    // Safe object deletion - properly clean up resources
    public entry fun delete_book(
        book: Book,
        _ctx: &mut TxContext
    ) {
        // Destructure the object to access its UID
        let Book { 
            id, 
            title: _, 
            author: _, 
            pages: _, 
            is_published: _ 
        } = book;
        
        // Delete the UID to clean up
        object::delete(id);
    }

    // Delete container and all its dynamic fields
    public entry fun delete_container_safe(
        container: Container,
        field_names: vector<String>,   // List of all dynamic field names
        _ctx: &mut TxContext
    ) {
        let Container { id, name: _ } = container;
        
        // Remove all dynamic fields first
        let i = 0;
        while (i < vector::length(&field_names)) {
            let field_name = *vector::borrow(&field_names, i);
            if (dof::exists_<Book>(&id, field_name)) {
                let _book: Book = dof::remove(&mut id, field_name);
                // Book will be dropped automatically if it has drop ability
            };
            i = i + 1;
        };
        
        object::delete(id);
    }

    // =============================================================================
    // 11. ERROR HANDLING AND CONSTANTS
    // =============================================================================

    // Define clear error codes for different failure scenarios
    const E_NOT_AUTHORIZED: u64 = 0;          // Unauthorized access
    const E_INSUFFICIENT_PAGES: u64 = 1;      // Book doesn't have enough pages
    const E_NOT_OWNER: u64 = 2;               // Not the owner of object
    const E_BOOK_NOT_FOUND: u64 = 3;          // Book doesn't exist
    const E_BOOK_ALREADY_EXISTS: u64 = 4;     // Book already linked to author
    const E_WRONG_CAPABILITY: u64 = 5;        // Wrong admin capability

    // Function with comprehensive error handling
    public entry fun safe_book_operation(
        book: &mut Book,
        min_pages: u64,
        new_title: String,
        ctx: &mut TxContext
    ) {
        // Check authorization (example: only certain address can modify)
        let sender = tx_context::sender(ctx);
        // assert!(sender == @0x123..., E_NOT_AUTHORIZED);  // Uncomment with real address
        
        // Check book meets requirements
        assert!(book.pages >= min_pages, E_INSUFFICIENT_PAGES);
        
        // Perform the operation
        book.title = new_title;
    }

    // =============================================================================
    // 12. TESTING FUNCTIONS (for development/testing purposes)
    // =============================================================================

    #[test_only]
    use sui::test_scenario;

    #[test]
    public fun test_book_creation() {
        let admin = @0xABCD;
        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Test book creation
        test_scenario::next_tx(scenario, admin);
        {
            let ctx = test_scenario::ctx(scenario);
            mint_book(
                string::utf8(b"Test Book"),
                string::utf8(b"Test Author"),
                100,
                ctx
            );
        };
        
        // Verify book was created and transferred
        test_scenario::next_tx(scenario, admin);
        {
            assert!(test_scenario::has_most_recent_for_sender<Book>(scenario), 0);
            let book = test_scenario::take_from_sender<Book>(scenario);
            
            assert!(*get_book_title(&book) == string::utf8(b"Test Book"), 1);
            assert!(*get_book_author(&book) == string::utf8(b"Test Author"), 2);
            assert!(get_book_pages(&book) == 100, 3);
            
            test_scenario::return_to_sender(scenario, book);
        };
        
        test_scenario::end(scenario_val);
    }

    // =============================================================================
    // 13. BEST PRACTICES EXAMPLES
    // =============================================================================

    // GOOD: Efficient function that uses references
    public fun efficient_book_comparison(book1: &Book, book2: &Book): bool {
        book1.pages == book2.pages && book1.author == book2.author
    }

    // AVOID: Function that takes ownership unnecessarily
    // public fun inefficient_comparison(book1: Book, book2: Book): bool {
    //     book1.pages == book2.pages  // Books are consumed and lost!
    // }

    // GOOD: Function with proper access control
    public entry fun authorized_book_update(
        book: &mut Book,
        new_pages: u64,
        owner_address: address,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == owner_address, E_NOT_AUTHORIZED);
        assert!(new_pages > 0, E_INSUFFICIENT_PAGES);
        book.pages = new_pages;
    }

    // GOOD: Batch operations for efficiency
    public entry fun batch_update_books(
        books: vector<Book>,
        new_pages: vector<u64>,
        ctx: &mut TxContext
    ) {
        assert!(vector::length(&books) == vector::length(&new_pages), 0);
        
        let i = 0;
        let len = vector::length(&books);
        while (i < len) {
            let book = vector::pop_back(&mut books);
            let pages = vector::pop_back(&mut new_pages);
            
            // Update book
            let Book { id, title, author, pages: _, is_published } = book;
            let updated_book = Book { id, title, author, pages, is_published };
            
            // Transfer back to sender
            transfer::transfer(updated_book, tx_context::sender(ctx));
            i = i + 1;
        };
        
        // Clean up empty vectors
        vector::destroy_empty(books);
        vector::destroy_empty(new_pages);
    }

    // =============================================================================
    // SUMMARY OF KEY CONCEPTS:
    // =============================================================================
    
    // 1. All objects MUST have 'key' ability and a UID field
    // 2. Use 'store' ability for objects that will be stored in other objects
    // 3. Ownership models: Owned, Shared, Immutable
    // 4. Use references (&) for reading, mutable references (&mut) for modifying
    // 5. Dynamic fields allow flexible object composition
    // 6. Hot potato pattern ensures function sequences are completed
    // 7. Capability pattern provides fine-grained access control
    // 8. Always clean up UIDs when destroying objects
    // 9. Use clear error codes and assertions for safety
    // 10. Test your functions thoroughly
    // =============================================================================
}