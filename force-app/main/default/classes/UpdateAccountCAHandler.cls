public class UpdateAccountCAHandler {

    // Method to update account revenue based on orders where the status changes to 'Activated'
    public static void updateAccountRevenue(List<Order> newOrders, Map<Id, Order> oldOrdersMap) {
        List<Order> ordersToUpdate = new List<Order>();

        // Collect orders where the status changed to 'Activated'
        for (Order ord : newOrders) {
            if (ord.Status == 'Activated' && oldOrdersMap.get(ord.Id).Status != 'Activated') {
                ordersToUpdate.add(ord);
            }
        }

        // Call the logic to update the accounts based on these orders
        if (!ordersToUpdate.isEmpty()) {
            updateAccountRevenueForOrders(ordersToUpdate);
        }
    }

    // Separate method to handle the actual account revenue update
    private static void updateAccountRevenueForOrders(List<Order> orders) {
        Set<Id> accountIds = new Set<Id>();

        // Collect Account IDs from orders
        for (Order ord : orders) {
            if (ord.AccountId != null && ord.TotalAmount != null) {
                accountIds.add(ord.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            Map<Id, Account> accountsToUpdate = new Map<Id, Account>([
                SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds
            ]);

            // Update account revenue
            for (Order ord : orders) {
                if (accountsToUpdate.containsKey(ord.AccountId)) {
                    Account acc = accountsToUpdate.get(ord.AccountId);
                    acc.Chiffre_d_affaire__c = (acc.Chiffre_d_affaire__c != null) ? acc.Chiffre_d_affaire__c : 0;
                    acc.Chiffre_d_affaire__c += ord.TotalAmount;
                }
            }

            // Update the accounts
            update accountsToUpdate.values();
        }
    }
}
