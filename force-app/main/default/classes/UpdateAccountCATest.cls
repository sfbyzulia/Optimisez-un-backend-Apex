@isTest
public class UpdateAccountCATest {

    @testSetup
    static void setupTestData() {
        // Create the "Test Account with 100 Orders"
        Account testAccount = new Account(Name = 'Test Account with 100 Orders');
        insert testAccount;

        // Create a product for the orders
        Product2 prod = new Product2(Name = 'Test Product', Family = 'Test Family', IsActive = true);
        insert prod;

        // Get the Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();

        // Create a Pricebook Entry for the product
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert pbe;

        // Create 100 orders for the account
        List<Order> ordersToInsert = new List<Order>();
        for (Integer i = 0; i < 100; i++) {
            Order newOrder = new Order(
                AccountId = testAccount.Id,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id = pricebookId
            );
            ordersToInsert.add(newOrder);
        }
        insert ordersToInsert;

        // Add OrderItems to each order
        List<OrderItem> orderItemsToInsert = new List<OrderItem>();
        for (Order ord : ordersToInsert) {
            // First OrderItem with Quantity 10 and UnitPrice 150
            OrderItem oi1 = new OrderItem(
                OrderId = ord.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 10,
                UnitPrice = 150
            );
            orderItemsToInsert.add(oi1);

            // Second OrderItem with Quantity 20 and UnitPrice 1000
            OrderItem oi2 = new OrderItem(
                OrderId = ord.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 20,
                UnitPrice = 1000
            );
            orderItemsToInsert.add(oi2);
        }
        insert orderItemsToInsert;
    }

    @isTest
    static void testUpdateAccountRevenueFor100Orders() {
        // Retrieve the "Test Account with 100 Orders"
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account with 100 Orders' LIMIT 1];

        // Fetch 100 orders for this account
        List<Order> orders = [SELECT Id, Status, TotalAmount FROM Order WHERE AccountId = :testAccount.Id LIMIT 100];

        // Simulate updating the orders' status to 'Activated'
        Test.startTest();
        for (Order ord : orders) {
            ord.Status = 'Activated';
        }
        update orders;
        Test.stopTest();

        // Query the account after the order status changes
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];

        // Expected revenue from all 100 orders
        Decimal expectedRevenue = 21500 * 100;  // Each order contributes 21,500

        // Assert that the revenue has been updated correctly
        Assert.areEqual(expectedRevenue, updatedAccount.Chiffre_d_affaire__c, 
            'The account revenue should be updated based on the 100 orders.');
    }

    @isTest
    static void testSingleOrderRevenueUpdate() {
        // Retrieve the account and order
        Account acc = [SELECT Id, Chiffre_d_affaire__c FROM Account LIMIT 1];
        Order ord = [SELECT Id, Status, TotalAmount FROM Order WHERE AccountId = :acc.Id LIMIT 1];

        // Simulate updating the order status to 'Activated'
        Test.startTest();
        ord.Status = 'Activated';
        update ord;
        Test.stopTest();

        // Verify account revenue
        Account updatedAcc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(ord.TotalAmount, updatedAcc.Chiffre_d_affaire__c, 
            'The account revenue should be updated based on the single order.');
    }
}
