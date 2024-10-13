@isTest
public class TestMyTeamOrdersController {
    @isTest static void testSumOrders() {
        // Get the sales manager user (previously created)
        User salesManagerUser = [SELECT Id, UserRoleId FROM User WHERE Username = 'testuser@fasha.com'];

        // Start test block
        Test.startTest();
        
        // Run the test as the Sales Manager
        System.runAs(salesManagerUser) {
            // Create test data
            Account acc = TestDataFactory.createTestAccount();
            Product2 prod = TestDataFactory.createTestProduct();
            PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);
            Contract con = TestDataFactory.createContract(acc);
            Order ord = TestDataFactory.createOrder(acc, con, pbe);
            
            // Insert the order to get the Id
            insert ord;

            // Update the order owner to the sales manager user
            ord.OwnerId = salesManagerUser.Id;
            update ord;
            
            // Call the controller method
            MyTeamOrdersController controller = new MyTeamOrdersController();
            Decimal totalOrders = controller.SumOrders;

            // Assert that the total orders amount is calculated correctly
            System.assert(totalOrders > 0, 'The total order amount should be greater than 0.');
        }
        
        // End test block
        Test.stopTest();
    }
}
