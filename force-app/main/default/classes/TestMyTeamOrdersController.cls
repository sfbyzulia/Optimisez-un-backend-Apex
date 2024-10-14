@isTest
public class TestMyTeamOrdersController {
        @isTest static void testSumOrders() {
        // Get the sales manager user (previously created)
        User salesManagerUser = [SELECT Id, UserRoleId FROM User WHERE Username = 'testuser@fasha.com'];

        Test.startTest();
        System.runAs(salesManagerUser) {
            // Create test data
            Account acc = TestDataFactory.createTestAccount();
            Product2 prod = TestDataFactory.createTestProduct();
            PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);
            Contract con = TestDataFactory.createContract(acc);
            Order ord = TestDataFactory.createOrder(acc, con, pbe);
            
            // Insert the order to get the Id
            insert ord;
            
            // Using OrderItemFactory to add products in the order
            List<OrderItem> orderItems = OrderItemFactory.createOrderItems(ord, pbe);
            insert orderItems;
            
            // Update the order owner to the sales manager user
            ord.OwnerId = salesManagerUser.Id;
            update ord;
            
            // Call the controller method
            MyTeamOrdersController controller = new MyTeamOrdersController();
            Decimal totalOrders = controller.SumOrders;

            System.assert(totalOrders > 0, 'The total order amount should be greater than 0.');
        }
        
        // End test block
        Test.stopTest();
    }

    // Test when no orders exist
    @isTest static void testSumOrdersNoOrders() {
        User salesManagerUser = [SELECT Id, UserRoleId FROM User WHERE Username = 'testuser@fasha.com'];

        Test.startTest();

        System.runAs(salesManagerUser) {
            // Create test data (Account, Product, etc.) without creating any orders
            Account acc = TestDataFactory.createTestAccount();
            Product2 prod = TestDataFactory.createTestProduct();
            PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);
            Contract con = TestDataFactory.createContract(acc);
            
            // Call the controller method
            MyTeamOrdersController controller = new MyTeamOrdersController();
            Decimal totalOrders = controller.SumOrders;

            System.assertEquals(0, totalOrders, 'The total order amount should be 0 when there are no orders.');
        }
        
        Test.stopTest();
    }
}
