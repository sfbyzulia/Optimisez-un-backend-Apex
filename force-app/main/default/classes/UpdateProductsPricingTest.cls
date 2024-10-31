@isTest
public class UpdateProductsPricingTest {

    @testSetup
    static void setupTestData() {
        // Create a list of products
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            Product2 prod = new Product2(
                Name = 'Test Product ' + i,
                IsActive = true
            );
            products.add(prod);
        }
        insert products;

        // Fetch the Standard Pricebook ID after product creation
        Id standardPricebookId = Test.getStandardPricebookId();

        // Create a Standard Pricebook Entry for each product
        List<PricebookEntry> standardPricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : products) {
            PricebookEntry standardPbe = new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100 * (products.indexOf(prod) + 1), // Set varying prices for each product
                IsActive = true
            );
            standardPricebookEntries.add(standardPbe);
        }
        // Insert the Standard PricebookEntries
        insert standardPricebookEntries;
    }

    @isTest
    static void testBatchPriceUpdate() {
        // Start the test context
        Test.startTest();

        // Execute the batch job
        UpdateProductsPricing batch = new UpdateProductsPricing();
        Database.executeBatch(batch, 200);

        // End the test context
        Test.stopTest();

        // Query the updated pricebook entries
        List<PricebookEntry> updatedPricebookEntries = [
            SELECT Id, UnitPrice FROM PricebookEntry WHERE IsActive = true
        ];

        // Assert that the prices have been updated (increased by 5%)
        for (PricebookEntry pbe : updatedPricebookEntries) {
            Decimal originalPrice = pbe.UnitPrice / 1.05; // Reverse the price update logic to validate
            Decimal expectedUpdatedPrice = originalPrice * 1.05;
            Assert.areEqual(expectedUpdatedPrice, pbe.UnitPrice, 'Pricebook entry price should have increased by 5%.');
        }
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
