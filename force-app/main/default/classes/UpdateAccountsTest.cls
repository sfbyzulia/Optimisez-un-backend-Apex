@isTest
public class UpdateAccountsTest {

    // Test setup method using the TestDataFactory
    @testSetup
    static void setupTestData() {
        // Create test data using the TestDataFactory's createFullOrderData method
        Map<String, Object> testData = TestDataFactory.createFullOrderData();

        // Get the order from the created test data
        Order ord = (Order)testData.get('order');
        
        // Updating the order status to 'Activated'
        ord.Status = 'Activated';
        update ord;
    }
    
    // Test method to verify that account revenue is updated correctly
    @isTest
    static void testAccountRevenueUpdate() {
        // Start the test context
        Test.startTest();
        
        // Run the batch job
        UpdateAccounts batchJob = new UpdateAccounts();
        Database.executeBatch(batchJob, 200);

        // End the test context
        Test.stopTest();

        // Query the account to check the updated revenue
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account LIMIT 1];

        // Expected revenue from the order items created by TestDataFactory
        Decimal expectedRevenue = 21500;

        // Assert that the revenue has been updated correctly
        Assert.areEqual(expectedRevenue, updatedAccount.Chiffre_d_affaire__c, 
            'The account revenue should be updated based on the orders.');
    }
}
