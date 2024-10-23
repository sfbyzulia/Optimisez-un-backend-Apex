@isTest
public class UpdateAccountCATest {

    @testSetup
    static void setupTestData() {
        // Create test data using the TestDataFactory
        Map<String, Object> testData = TestDataFactory.createFullOrderData();
        Order ord = (Order)testData.get('order');
        
        // Initially set the status to 'Draft' and update the order
        ord.Status = 'Draft';
        update ord;
    }

    @isTest
    static void testUpdateAccountRevenueWithManyOrders() {
        // Retrieve the account for validation
        Account acc = [SELECT Id, Chiffre_d_affaire__c FROM Account LIMIT 1];
        
        // Fetch all orders for this account
        List<Order> orders = [SELECT Id, Status FROM Order WHERE AccountId = :acc.Id];
        
        // Simulate updating the orders' status to 'Activated'
        Test.startTest();
        
        for (Order ord : orders) {
            ord.Status = 'Activated';
        }
        update orders;
        
        Test.stopTest();

        // Query the account after the order status changes
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];

        // Expected revenue from all 100 orders
        Decimal expectedRevenue = 21500 * 100; // Each order contributes 21,500

        // Assert that the revenue has been updated correctly
        System.assertEquals(expectedRevenue, updatedAccount.Chiffre_d_affaire__c, 
            'The account revenue should be updated based on the orders.');
    }
}
