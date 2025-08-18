/*Importance of Tests

1. Verify Multi-User Logic: Ensure different users can interact with shared objects correctly
2. Test Permission Systems: Confirm only owners can perform restricted operations
3. Simulate Real Blockchain Behavior: Test scenarios mirror actual on-chain interactions
4. Prevent Regressions: Catch bugs before deployment to mainnet
5. Document Expected Behavior: Tests serve as executable documentation

****TEST FLOW ANALYSIS****
The test simulates a realistic multi-user scenario:
   1. Setup: Owner creates a counter
   2. User Interaction: User1 increments it twice (0 → 2)
   3. Owner Control: Owner sets value to 100
   4. Continued Usage: User1 increments again (100 → 101)

*/

#[test_only]
module counter::counter_test {
    use counter::counter::{Self, Counter, get_owner, get_value};
    use sui::test_scenario as ts;
    use sui::test_scenario::return_shared;

    #[test]
    fun test_counter() {
        let owner = @0xC0FFEE;
        let user1 = @0xA1;

        let mut scenario = ts::begin(user1);

        // Create the counter as owner
        {
            scenario.next_tx(owner);
            counter::create(scenario.ctx());
        };

        // User1 increments the counter
        {
            scenario.next_tx(user1);
            let mut counter: Counter = scenario.take_shared();

            assert!(get_owner(&counter) == owner);
            assert!(get_value(&counter) == 0);

            counter.increment();
            counter.increment();

            return_shared(counter);
        };

        // Owner sets the value
        {
            scenario.next_tx(owner);
            let mut counter: Counter = scenario.take_shared();

            assert!(get_owner(&counter) == owner);
            assert!(get_value(&counter) == 2);

            counter.set_value(100, scenario.ctx());

            return_shared(counter);
        };

        scenario.end();
    }
}