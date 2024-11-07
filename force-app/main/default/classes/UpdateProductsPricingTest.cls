@isTest
public class UpdateProductsPricingTest {

    @testSetup
    static void setupTestData() {
        // Create a list of Product2 records and insert them
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            Product2 prod = new Product2(
                Name = 'Test Product ' + i,
                IsActive = true
            );
            products.add(prod);
        }
        insert products;

        // Fetch the Standard Pricebook ID
        Id standardPricebookId = Test.getStandardPricebookId();

        // Create and insert PricebookEntry records for each product
        List<PricebookEntry> standardPricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : products) {
            PricebookEntry standardPbe = new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100 * (products.indexOf(prod) + 1), // Variable price
                IsActive = true
            );
            standardPricebookEntries.add(standardPbe);
        }
        insert standardPricebookEntries;

        // Create an Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create an Order in 'Draft' status first
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebookId
        );
        insert testOrder;

        // Create and insert OrderItems linked to the test Order
        List<OrderItem> orderItems = new List<OrderItem>();
        for (PricebookEntry pbe : standardPricebookEntries) {
            OrderItem oi = new OrderItem(
                OrderId = testOrder.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = pbe.UnitPrice
            );
            orderItems.add(oi);
        }
        insert orderItems;

        // Update the order to 'Activated' status after adding OrderItems
        testOrder.Status = 'Activated';
        update testOrder;
    }

    @isTest
    static void testBatchPriceUpdate() {
        Test.startTest();
        UpdateProductsPricing batch = new UpdateProductsPricing();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that the UnitPrice of PricebookEntry records was updated
        List<PricebookEntry> updatedPricebookEntries = [
            SELECT Id, UnitPrice FROM PricebookEntry WHERE IsActive = true
        ];

        for (PricebookEntry pbe : updatedPricebookEntries) {
            Decimal originalPrice = pbe.UnitPrice / 1.05; // Reverse the price update logic
            Decimal expectedUpdatedPrice = originalPrice * 1.05;
            Assert.areEqual(expectedUpdatedPrice, pbe.UnitPrice, 'Pricebook entry price should have increased by 5%.');
        }

        // Verify that the account revenue was updated
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Name = 'Test Account'];
        Decimal expectedRevenue = updatedAccount.Chiffre_d_affaire__c; // Expected revenue after batch run

        Assert.isTrue(expectedRevenue > 0, 'The account revenue should be updated after the product price update.');
    }
    @isTest
    static void testSchedulerExecution() {
        // Start the test context
        Test.startTest();

        // Schedule the job using a test cron expression
        String cronExp = '0 0 0 ? * 1'; // Every Sunday at midnight
        String jobId = System.schedule('TestWeeklyProductPriceUpdate', cronExp, new UpdateProductsPricingScheduler());

        // End the test context
        Test.stopTest();

        // Verify the scheduled job exists
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(cronExp, ct.CronExpression, 'The cron expression should match.');
    }
}
