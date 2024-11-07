/**
 * Batch class that updates the prices of all active Pricebook Entries in the Standard Pricebook
 * by applying a 5% price increase. This class also updates the revenue of accounts associated
 * with activated orders containing these products.
 * 
 * Implements the Database.Batchable interface to handle large volumes of data in batch processing.
 */
global class UpdateProductsPricing implements Database.Batchable<sObject> {

    /**
     * Prepares the batch for execution by defining the query to retrieve active PricebookEntry records.
     * 
     * @param bc The batch context.
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
     * Processes each batch of PricebookEntry records by applying a 5% price increase and updating
     * the associated products' prices. Also triggers account revenue updates based on affected products.
     * 
     * @param bc The batch context.
     * @param scope The list of PricebookEntry records to be processed in the current batch.
     */
    global void execute(Database.BatchableContext bc, List<PricebookEntry> scope) {
        List<PricebookEntry> entriesToUpdate = new List<PricebookEntry>();
        Set<Id> productIds = new Set<Id>();

        // Increase the UnitPrice by 5% for each PricebookEntry and collect Product2Id
        for (PricebookEntry pbe : scope) {
            if (pbe.UnitPrice != null) {
                pbe.UnitPrice = pbe.UnitPrice * 1.05; // Increase by 5%
                entriesToUpdate.add(pbe);
                productIds.add(pbe.Product2Id);
            }
        }

        // Update the PricebookEntry records if there are any changes
        if (!entriesToUpdate.isEmpty()) {
            update entriesToUpdate;
        }

        // Update account revenue based on the products that were updated
        updateAccountRevenue(productIds);
    }

    /**
     * Updates the revenue field (Chiffre_d_affaire__c) on Account records based on the total revenue 
     * from OrderItems linked to the updated products. Only processes orders with an 'Activated' status.
     * 
     * @param productIds A set of Product2 IDs that were updated in the batch.
     */
    private void updateAccountRevenue(Set<Id> productIds) {
        if (productIds.isEmpty()) return; // Exit if no products were updated
    
        // Query to get the total revenue from OrderItems linked to updated products and activated orders
        List<OrderItem> relatedOrderItems = [
            SELECT Order.AccountId, Quantity, UnitPrice
            FROM OrderItem
            WHERE Product2Id IN :productIds
            AND Order.Status = 'Activated'
        ];
    
        // Map to store the accumulated revenue per AccountId
        Map<Id, Decimal> accountRevenueMap = new Map<Id, Decimal>();
    
        for (OrderItem oi : relatedOrderItems) {
            if (oi.Order.AccountId != null) {
                Decimal orderItemTotal = oi.Quantity * oi.UnitPrice;
                if (!accountRevenueMap.containsKey(oi.Order.AccountId)) {
                    accountRevenueMap.put(oi.Order.AccountId, 0);
                }
                accountRevenueMap.put(oi.Order.AccountId, accountRevenueMap.get(oi.Order.AccountId) + orderItemTotal);
            }
        }
    
        // Prepare a list of Account records to update their revenue field
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accountId : accountRevenueMap.keySet()) {
            accountsToUpdate.add(new Account(Id = accountId, Chiffre_d_affaire__c = accountRevenueMap.get(accountId)));
        }
    
        // Update the accounts if there are any changes
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    /**
     * Finalizes the batch process by logging a message indicating that the process has completed.
     * 
     * @param bc The batch context.
     */
    global void finish(Database.BatchableContext bc) {
        System.debug('Weekly pricebook entry and account revenue updates have been completed.');
    }
}
