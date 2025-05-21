#[test_only]
module hello_sui::hello_sui_tests {
    // Import the module and function we want to test.
    use hello_sui::hello_sui;

    // Mark this function as a test.
    #[test]
    fun test_hello_sui() {
        // Call the hello_sui function and check if it returns "Hello.sui".
        assert!(hello_sui::hello_sui() == b"Hello.sui".to_string(), 0);
    }
}
