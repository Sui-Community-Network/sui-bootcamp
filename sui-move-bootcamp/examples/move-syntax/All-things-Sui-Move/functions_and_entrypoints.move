// =========================
// FUNCTIONS IN SUI MOVE
// =========================

// =========================
// FUNCTION EXPLANATION
// =========================

    /*
    Anatomy of a function declaration in Sui Move:

    [visibility] fun [function_name]([parameters]): [return_type] {
        // function body
    }

    - visibility: 'public' (accessible outside the module), 'public(package)' (accessible within the package), or omitted (private)
    - fun: keyword to declare a function
    - function_name: name of the function (snake_case recommended)
    - parameters: list of parameters with their types, separated by commas
    - return_type: type of value returned (can be omitted if the function returns nothing)
    - function body: code to execute when the function is called
    */

// 1. Basic function declaration
    // 'public' - makes the function accessible from other modules
    // 'fun' - keyword to declare a function
    // 'add' - function name (snake_case is recommended)
    // '(a: u8, b: u8)' - parameters with their types
    // ': u8' - return type
    // '{ ... }' - function body

public fun add(a: u8, b: u8): u8 {
        a + b // The last line (without a semicolon) is the return value
}

// 2. Function with no return value (returns the unit type `()`)

public fun print_sum(a: u8, b: u8) {
        let sum = a + b;
        // No return value, so the function returns ()
}

// 3. Function with multiple return values (returns a tuple)

public fun split_number(n: u8): (u8, u8) {
        let half = n / 2;
        let rem = n % 2;
        (half, rem) // Return a tuple (half, remainder)
}

// 4. Private function (default, no 'public' keyword)

    fun multiply(a: u8, b: u8): u8 {
        a * b
}

// 5. Function with mutable reference parameter

    public fun increment(mut x: u8): u8 {
        x = x + 1;
        
}

// 6. Function with no parameters and no return value
    public fun do_nothing() {
        // Does nothing
}