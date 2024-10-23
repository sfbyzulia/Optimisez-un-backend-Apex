public class UpdateAccountCAHandler {

    // Method to update account revenue based on orders where the status changes to 'Activated'
    public static void updateAccountRevenue(List<Order> newOrders, Map<Id, Order> oldOrdersMap) {
        // Set to track Account IDs
        Set<Id> accountIds = new Set<Id>();
        
        // Collect Account IDs where orders' statuses changed to 'Activated'
        for (Order ord : newOrders) {
            if (ord.Status == 'Activated' && oldOrdersMap.get(ord.Id).Status != 'Activated') {
                if (ord.AccountId != null && ord.TotalAmount != null) {
                    accountIds.add(ord.AccountId);
                }
            }
        }
        
        // Only proceed if we have accounts to update
        if (!accountIds.isEmpty()) {
            // Query all accounts associated with the orders
            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id, Chiffre_d_affaire__c 
                FROM Account 
                WHERE Id IN :accountIds
            ]);
            
            // Loop through the orders and update the revenue for each related account
            for (Order ord : newOrders) {
                if (ord.Status == 'Activated' && oldOrdersMap.get(ord.Id).Status != 'Activated') {
                    Account acc = accountMap.get(ord.AccountId);
                    if (acc != null && ord.TotalAmount != null) {
                        acc.Chiffre_d_affaire__c = (acc.Chiffre_d_affaire__c != null) ? acc.Chiffre_d_affaire__c : 0;
                        acc.Chiffre_d_affaire__c += ord.TotalAmount;
                    }
                }
            }
            
            // Perform a single update for all accounts
            if (!accountMap.isEmpty()) {
                update accountMap.values();
            }
        }
    }
}
