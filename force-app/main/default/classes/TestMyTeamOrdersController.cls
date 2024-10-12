@isTest
public class TestMyTeamOrdersController {

    @isTest static void testSumOrders() {
        // Start test block
        Test.startTest();
        
        // Create test data
        Account acc = TestDataFactory.createTestAccount();
        Product2 prod = TestDataFactory.createTestProduct();
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);
        Contract con = TestDataFactory.createContract(acc);
        Order ord = TestDataFactory.createOrder(acc, con, pbe);

        // Set current user's role
        User testUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        
        // Call the controller method
        MyTeamOrdersController controller = new MyTeamOrdersController();
        Decimal totalOrders = controller.SumOrders;

        // Assert that the total orders amount is calculated correctly
        System.assert(totalOrders > 0, 'The total order amount should be greater than 0.');
        
        // End test block
        Test.stopTest();
    }
}
