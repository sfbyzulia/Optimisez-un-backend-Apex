@isTest
public class MyTeamOrdersControllerTest {

    @testSetup
    static void setupTestData() {
        // Run as commercial user to create data
        User commercialUser = [SELECT Id FROM User WHERE Username = 'testuser@fasha.com'];
        System.runAs(commercialUser) {
            // Create test data using TestDataFactory
            Map<String, Object> dataMap = TestDataFactory.createFullOrderData();
            Order ord = (Order) dataMap.get('order');
        }
    }

    @isTest
    static void testTeamOrdersVisibilityForCommercial() {
        // Get the second commercial user
        User secCommercialUser = [SELECT Id FROM User WHERE Username = 'zulfiyyar27@empathetic-goat-mm22b7.com'];

        Test.startTest();
        System.runAs(secCommercialUser) {
            // Instantiate the controller as the commercial user
            MyTeamOrdersController controller = new MyTeamOrdersController();
            List<Order> teamOrders = controller.getTeamOrders();

            // Assert that the commercial user can see the orders created by the sys admin
            Assert.isTrue(!teamOrders.isEmpty(), 'The commercial should be able to see the team orders.');
        }
        Test.stopTest();
    }
}
