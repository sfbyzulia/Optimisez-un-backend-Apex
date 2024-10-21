@isTest
private class CalculMontantTest {
    @isTest static void testNetAmountCalculation() {
        Test.startTest();  // Start test block

        // Use parent method to create test data
        Map<String, Object> dataMap = TestDataFactory.createFullOrderData();
        Order ord = (Order)dataMap.get('order');
        List<OrderItem> orderItems = (List<OrderItem>)dataMap.get('orderItems');

        // Verify that the NetAmount is calculated correctly
        Order ordAfter = [SELECT NetAmount__c FROM Order WHERE Id = :order.Id];
        Decimal expectedNetAmount = (1 * 1000 + 20 * 1000) - 100;  // TotalAmount - ShipmentCost
        System.assertEquals(expectedNetAmount, ordAfter.NetAmount__c, 'NetAmount should be correctly calculated as TotalAmount - ShipmentCost');

        Test.stopTest();
    }
}