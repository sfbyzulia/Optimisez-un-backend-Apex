@isTest
public class UpdateAccountsTest {

    @testSetup
    static void setupData() {
        // Create basic test data
        Account acc = TestDataFactory.createTestAccount();
        Product2 prod = TestDataFactory.createTestProduct();
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);
        Contract con = TestDataFactory.createContract(acc);

        // Create a list of 100 orders using the factory
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 100; i++) {
            // Ensure that no Id is assigned or used during order creation
            Order ord = TestDataFactory.createOrder(acc, con, pbe);
            orders.add(ord);
        }

        // Insert all 100 orders in bulk
        insert orders;

        // Create and add order items for each order
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order ord : orders) {
            // Ensure that no Id is assigned or used during OrderItem creation
            orderItems.addAll(TestDataFactory.createOrderItems(ord, pbe));
        }

        // Insert all order items in bulk
        insert orderItems;

        // Update the status of all orders to 'Activated'
        for (Order ord : orders) {
            ord.Status = 'Activated';
        }
        update orders;  // Bulk update all orders
    }

    @isTest
    static void testBatchExecution() {
        // Start test block
        Test.startTest();

        // Instantiate the batch class and execute it
        UpdateAccounts batch = new UpdateAccounts();
        Database.executeBatch(batch, 200);  // 200 is the batch size

        // End test block
        Test.stopTest();

        // Validate that the account's revenue has been updated
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account LIMIT 1];

        // Calculate expected revenue based on the order items
        Decimal expectedRevenue = 100 * (10 * 150 + 20 * 1000);  // Based on 10 and 20 items per order
        System.assertEquals(expectedRevenue, updatedAccount.Chiffre_d_affaire__c, 'Account revenue should be updated based on order item amounts.');
    }
}
