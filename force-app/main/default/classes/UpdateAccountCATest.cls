@isTest
public class UpdateAccountCATest {

    // Test setup method using the TestDataFactory
    @testSetup
    static void setupTestData() {
        // Create test data using the TestDataFactory's createFullOrderData method
        Map<String, Object> testData = TestDataFactory.createFullOrderData();

        // Get the order from the created test data
        Order ord = (Order)testData.get('order');
        
        // Initially set the status to 'Draft' and update the order
        ord.Status = 'Draft';
        update ord;
    }

    @isTest
    static void testUpdateAccountRevenueOnOrderActivated() {
        // Retrieve the account and order for validation
        Account acc = [SELECT Id, Chiffre_d_affaire__c FROM Account LIMIT 1];
        Order ord = [SELECT Id, Status, TotalAmount FROM Order WHERE AccountId = :acc.Id LIMIT 1];
        
        Test.startTest();
        
        // Activate the order by setting the status to 'Activated'
        ord.Status = 'Activated';
        update ord;

        Test.stopTest();

        // Re-query the account after the order status change
        Account updatedAcc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];

        // Validate that the account revenue was updated correctly
        Decimal expectedRevenue = ord.TotalAmount;
        System.assertEquals(expectedRevenue, updatedAcc.Chiffre_d_affaire__c, 
            'The account revenue should be updated when the order status changes to "Activated".');
    }
}
