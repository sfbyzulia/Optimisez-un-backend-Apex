global class UpdateProductsPricing implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all active pricebook entries for the Standard Pricebook
        return Database.getQueryLocator([
            SELECT Id, Product2Id, UnitPrice 
            FROM PricebookEntry 
            WHERE IsActive = true
            AND Pricebook2Id = :Test.getStandardPricebookId() 
        ]);
    }

    global void execute(Database.BatchableContext bc, List<PricebookEntry> scope) {
        List<PricebookEntry> entriesToUpdate = new List<PricebookEntry>();

        // Apply a 5% price increase to each pricebook entry
        for (PricebookEntry pbe : scope) {
            // Ensure that UnitPrice is not null before applying the increase
            if (pbe.UnitPrice != null) {
                pbe.UnitPrice = pbe.UnitPrice * 1.05;  // Increase price by 5%
                entriesToUpdate.add(pbe);
            }
        }

        // Only perform the update if there are entries to update
        if (!entriesToUpdate.isEmpty()) {
            update entriesToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Weekly pricebook entry updates have been completed.');
    }
}
