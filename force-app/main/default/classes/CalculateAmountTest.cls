@isTest
private class CalculateAmountTest {

    @isTest 
    static void testNetAmountCalculation() {
        // Start test execution
        Test.startTest();

        // Use TestDataFactory to create test data with Order and OrderItems
        Map<String, Object> dataMap = TestDataFactory.createFullOrderData();
        Order ord = (Order)dataMap.get('order');

        ord.Status = 'Activated';
        update ord;

        // Query the order after creation to verify that the NetAmount is calculated correctly
        Order ordAfter = [SELECT Net_Amount__c, TotalAmount, ShipmentCost__c FROM Order WHERE Id = :ord.Id];

        // Calculate expected NetAmount
        Decimal expectedNetAmount = (ordAfter.TotalAmount != null ? ordAfter.TotalAmount : 0) - (ordAfter.ShipmentCost__c != null ? ordAfter.ShipmentCost__c : 0);

        // Assert that NetAmount is correctly calculated
        Assert.areEqual(expectedNetAmount, ordAfter.Net_Amount__c, 
            'NetAmount should be correctly calculated as TotalAmount - ShipmentCost on insert');

        // End test execution
        Test.stopTest();
    }
}
