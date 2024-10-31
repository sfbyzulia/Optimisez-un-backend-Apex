/**
 * Batch class that updates the prices of all active Pricebook Entries in the Standard Pricebook
 * by applying a 5% price increase. This batch process is designed to run weekly to ensure prices are
 * adjusted according to the latest business requirements.
 * 
 * Implements the Database.Batchable interface to handle large volumes of data in batch processing.
 * 
 * Usage:
 * - Execute this batch using Database.executeBatch(new UpdateProductsPricing(), 200);
 * 
 * Methods:
 * - start: Retrieves all active PricebookEntry records in the Standard Pricebook.
 * - execute: Applies a 5% increase to each PricebookEntry's UnitPrice.
 * - finish: Logs a completion message once all entries have been processed.
 */
global class UpdateProductsPricing implements Database.Batchable<sObject> {

    /**
     * Prepares the batch for execution by defining the query to retrieve active PricebookEntry records.
     * 
     * @param bc BatchableContext object for the start method.
     * @return A Database.QueryLocator for querying all active Pricebook Entries in the Standard Pricebook.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Product2Id, UnitPrice 
            FROM PricebookEntry 
            WHERE IsActive = true
            AND Pricebook2Id = :Test.getStandardPricebookId()
        ]);
    }

    /**
     * Executes the batch logic for each batch of PricebookEntry records.
     * Increases the UnitPrice by 5% for each entry in the provided scope.
     * 
     * @param bc BatchableContext object for the execute method.
     * @param scope List of PricebookEntry records to be processed in the current batch.
     */
    global void execute(Database.BatchableContext bc, List<PricebookEntry> scope) {
        List<PricebookEntry> entriesToUpdate = new List<PricebookEntry>();

        for (PricebookEntry pbe : scope) {
            if (pbe.UnitPrice != null) {
                pbe.UnitPrice = pbe.UnitPrice * 1.05; // Increase by 5%
                entriesToUpdate.add(pbe);
            }
        }

        if (!entriesToUpdate.isEmpty()) {
            update entriesToUpdate;
        }
    }

    /**
     * Finalizes the batch process, logging a message indicating the completion of the weekly updates.
     * 
     * @param bc BatchableContext object for the finish method.
     */
    global void finish(Database.BatchableContext bc) {
        System.debug('Weekly pricebook entry updates have been completed.');
    }
}
