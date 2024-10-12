@isTest
public class TestWeeklyProductPriceUpdate {
    @isTest static void testWeeklyProductPriceUpdate() {
        Test.startTest();

        Account acc = TestDataFactory.createTestAccount();
        Product2 prod = new Product2(Name = 'Test Product', Family = 'Test Family', IsActive = true);
        insert prod;
        
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);
        Contract con = TestDataFactory.createContract(acc);
        Order ord = TestDataFactory.createOrder(acc, con, pbe);

        // Simulate the execution of the scheduled class
        WeeklyProductPriceUpdate weeklyUpdate = new WeeklyProductPriceUpdate();
        weeklyUpdate.execute(null);

        // Retrieve the updated pricebook entry
        PricebookEntry updatedPbe = [SELECT UnitPrice FROM PricebookEntry WHERE Id = :pbe.Id];

        // Verify that the price has been increased by 5%
        Decimal expectedNewPrice = 1000 * 1.05;  // Assuming initial price was 1000 in TestDataFactory
        System.assertEquals(expectedNewPrice, updatedPbe.UnitPrice, 'Pricebook entry price should be increased by 5%');

        // Verify that the batch job was triggered
        List<AsyncApexJob> jobs = [SELECT Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Completed'];
        System.assert(jobs.size() > 0, 'Batch job should have been triggered to update account revenue.');

        Test.stopTest();
    }
}