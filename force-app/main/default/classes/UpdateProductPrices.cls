global class UpdateProductPrices implements Database.Batchable<sObject> {

    // Start method to query products updated in the last 7 days
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, UnitPrice 
            FROM Product2 
            WHERE LastModifiedDate = LAST_N_DAYS:7
        ]);
    }

    // Execute method to process each batch of products and reflect updated prices
    global void execute(Database.BatchableContext bc, List<Product2> scope) {
        // Product prices have been updated externally
        // This loop updates related orders or revenue records if needed
        Set<Id> productIds = new Set<Id>();
        for (Product2 prod : scope) {
            productIds.add(prod.Id);
        }

        // Query related Orders that use these updated products
        List<OrderItem> orderItems = [
            SELECT Id, OrderId, Product2Id, UnitPrice 
            FROM OrderItem 
            WHERE Product2Id IN :productIds
        ];

        // Recalculate totals for orders based on updated product prices
        for (OrderItem oi : orderItems) {
            Product2 prod = [SELECT UnitPrice FROM Product2 WHERE Id = :oi.Product2Id];
            oi.UnitPrice = prod.UnitPrice; // Update order item with the new product price
        }

        // Update the order items with the new prices
        update orderItems;
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Product price updates for the last week have been completed.');
    }
}
