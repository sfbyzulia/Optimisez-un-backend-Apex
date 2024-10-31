/**
 * Handler class responsible for updating the Account revenue field (Chiffre_d_affaire__c) 
 * based on the TotalAmount of Orders where the Status changes to 'Activated'.
 * This handler is used in the `UpdateAccountCA` trigger.
 * 
 * Methods:
 * - updateAccountRevenue: Processes a list of Orders, checks for status changes, and updates the 
 *   corresponding Account's revenue field with the TotalAmount from activated Orders.
 */
public class UpdateAccountCAHandler {

    /**
     * Updates the Chiffre_d_affaire__c field on Account records based on Orders that were activated.
     * Accumulates the TotalAmount of Orders for each Account and performs a bulk update on Accounts
     * whose revenue needs adjustment.
     * 
     * @param newOrders List of new Order records.
     * @param oldOrdersMap Map of old Order records, keyed by Id, to detect status changes.
     */
    public static void updateAccountRevenue(List<Order> newOrders, Map<Id, Order> oldOrdersMap) {
        Map<Id, Decimal> accountRevenueMap = new Map<Id, Decimal>();
        
        // Collect Account IDs and their respective total revenue from Activated orders
        for (Order ord : newOrders) {
            if (ord.Status == 'Activated' && oldOrdersMap.get(ord.Id).Status != 'Activated') {
                if (ord.AccountId != null && ord.TotalAmount != null) {
                    if (!accountRevenueMap.containsKey(ord.AccountId)) {
                        accountRevenueMap.put(ord.AccountId, 0);
                    }
                    accountRevenueMap.put(ord.AccountId, accountRevenueMap.get(ord.AccountId) + ord.TotalAmount);
                }
            }
        }
        
        // Only proceed if we have accounts to update
        if (!accountRevenueMap.isEmpty()) {
            // Query the accounts to update
            Map<Id, Account> accountsToUpdate = new Map<Id, Account>([
                SELECT Id, Chiffre_d_affaire__c 
                FROM Account 
                WHERE Id IN :accountRevenueMap.keySet()
            ]);

            // Update the account revenue
            for (Id accountId : accountRevenueMap.keySet()) {
                Account acc = accountsToUpdate.get(accountId);
                if (acc != null) {
                    acc.Chiffre_d_affaire__c = (acc.Chiffre_d_affaire__c != null) ? acc.Chiffre_d_affaire__c : 0;
                    acc.Chiffre_d_affaire__c += accountRevenueMap.get(accountId);
                }
            }

            // Perform a single update for all accounts
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate.values();
            }
        }
    }
}
