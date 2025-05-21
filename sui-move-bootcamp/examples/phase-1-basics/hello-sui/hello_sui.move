module hello_sui::hello_sui {
    // Import the String type from the standard library.
    use std::string::String;

    // Public function that returns the string "Hello.sui".
    public fun hello_sui(): String {
        // Convert the byte string to a String and return it.
        b"Hello.sui".to_string()
    }
}
