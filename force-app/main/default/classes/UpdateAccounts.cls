global class UpdateAccounts implements Database.Batchable<sObject> {

    // This method is used to retrieve the data to process
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all accounts that have at least one order in status 'Activated' or 'Ordered'
        return Database.getQueryLocator([
            SELECT Id 
            FROM Account 
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Activated')
        ]);
    }

    // This method is used to process the records in batches
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<Id> accountIds = new Set<Id>();

        // Collect Account IDs from the current batch of accounts
        for (Account acc : scope) {
            accountIds.add(acc.Id);
        }

        // Query orders related to those accounts in 'Activated' or 'Ordered' status
        List<Order> orders = [
            SELECT AccountId, TotalAmount 
            FROM Order 
            WHERE AccountId IN :accountIds AND (Status = 'Activated' OR Status = 'Ordered')
        ];

        // Call the method to update account revenue
        updateAccountRevenue(orders);
    }

    // This method updates the revenue for each account based on their related orders
    private void updateAccountRevenue(List<Order> orders) {
        Map<Id, Account> accountMap = new Map<Id, Account>();

        // Loop through orders and accumulate revenue for each account
        for (Order ord : orders) {
            if (ord.AccountId != null && ord.TotalAmount != null) {
                if (!accountMap.containsKey(ord.AccountId)) {
                    accountMap.put(ord.AccountId, new Account(Id = ord.AccountId, Chiffre_d_affaire__c = 0));
                }
                Account acc = accountMap.get(ord.AccountId);
                acc.Chiffre_d_affaire__c += ord.TotalAmount;
            }
        }

        // Update all accounts with their updated revenue
        update accountMap.values();
    }

    // This method is called after the batch completes
    global void finish(Database.BatchableContext bc) {
        System.debug('Account revenue updates during data migration are complete.');
    }
}
