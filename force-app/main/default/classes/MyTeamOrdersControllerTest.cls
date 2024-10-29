@isTest
public class MyTeamOrdersControllerTest {
        @isTest static void testSumOrders() {
        // Get the sales manager user (previously created)
        User salesManagerUser = [SELECT Id, UserRoleId FROM User WHERE Username = 'testuser@fasha.com'];

        Test.startTest();
        System.runAs(salesManagerUser) {
            // Use parent method to create test data
            Map<String, Object> dataMap = TestDataFactory.createFullOrderData();
            Order ord = (Order)dataMap.get('order');
            List<OrderItem> orderItems = (List<OrderItem>)dataMap.get('orderItems');
            
            // Update the order owner to the sales manager user
            ord.OwnerId = salesManagerUser.Id;
            update ord;
            
            // Call the controller method
            MyTeamOrdersController controller = new MyTeamOrdersController();
            Decimal totalOrders = controller.SumOrders;

            Assert.areEqual(totalOrders > 0, 'The total order amount should be greater than 0.');
        }
        
        // End test block
        Test.stopTest();
    }

    // Test when no orders exist
    @isTest static void testSumOrdersNoOrders() {
        User salesManagerUser = [SELECT Id, UserRoleId FROM User WHERE Username = 'testuser@fasha.com'];

        Test.startTest();

        System.runAs(salesManagerUser) {
           // Use the TestDataFactory but skip order creation
           Map<String, Object> dataMap = TestDataFactory.createBasicDataWithoutOrder();
            
            // Call the controller method
            MyTeamOrdersController controller = new MyTeamOrdersController();
            Decimal totalOrders = controller.SumOrders;

            Assert.areEqual(0, totalOrders, 'The total order amount should be 0 when there are no orders.');
        }
        
        Test.stopTest();
    }
}