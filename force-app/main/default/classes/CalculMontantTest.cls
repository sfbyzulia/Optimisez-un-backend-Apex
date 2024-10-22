@isTest
private class CalculMontantTest {
    @isTest static void testNetAmountCalculation() {
        Test.startTest();  // Start test block

        // Use parent method to create test data
        Map<String, Object> dataMap = TestDataFactory.createFullOrderData();
        Order ord = (Order)dataMap.get('order');
        List<OrderItem> orderItems = (List<OrderItem>)dataMap.get('orderItems');

        // Query the order after creation to verify that the NetAmount is calculated correctly
        Order ordAfter = [SELECT NetAmount__c, TotalAmount, ShipmentCost__c FROM Order WHERE Id = :ord.Id];

        // Expected NetAmount = TotalAmount - ShipmentCost
        Decimal expectedNetAmount = ordAfter.TotalAmount - ordAfter.ShipmentCost__c;

        // Assert that NetAmount is correctly calculated as per the formula field
        System.assertEquals(expectedNetAmount, ordAfter.NetAmount__c, 'NetAmount should be correctly calculated as TotalAmount - ShipmentCost');

        Test.stopTest();
    }
}
