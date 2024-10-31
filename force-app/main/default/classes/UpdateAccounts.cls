/**
 * Batch class to update the revenue for all accounts based on the sum of TotalAmount
 * from activated orders associated with each account. This is used during data migration.
 */
global class UpdateAccounts implements Database.Batchable<sObject> {

    /**
     * Start method for the batch, retrieves accounts that have at least one activated order.
     * 
     * @param bc The batch context.
     * @return a QueryLocator for accounts with associated activated orders.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id 
            FROM Account 
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Activated')
        ]);
    }

    /**
     * Execute method for processing each batch of accounts. This method collects and updates
     * account revenue based on the total amount from associated activated orders.
     * 
     * @param bc The batch context.
     * @param scope The list of Account objects in the current batch scope.
     */
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<Id> accountIds = new Set<Id>();

        for (Account acc : scope) {
            accountIds.add(acc.Id);
        }

        List<Order> orders = [
            SELECT AccountId, TotalAmount 
            FROM Order 
            WHERE AccountId IN :accountIds AND (Status = 'Activated')
        ];

        updateAccountRevenue(orders);
    }

    /**
     * Updates the revenue for each account based on the total amount from their associated orders.
     * 
     * @param orders List of orders from which revenue is calculated and added to respective accounts.
     */
    private void updateAccountRevenue(List<Order> orders) {
        Map<Id, Account> accountMap = new Map<Id, Account>();

        for (Order ord : orders) {
            if (ord.AccountId != null && ord.TotalAmount != null) {
                if (!accountMap.containsKey(ord.AccountId)) {
                    accountMap.put(ord.AccountId, new Account(Id = ord.AccountId, Chiffre_d_affaire__c = 0));
                }
                Account acc = accountMap.get(ord.AccountId);
                acc.Chiffre_d_affaire__c += ord.TotalAmount;
            }
        }

        update accountMap.values();
    }

    /**
     * Finish method for the batch, called when the batch job is complete.
     * 
     * @param bc The batch context.
     */    
    global void finish(Database.BatchableContext bc) {
        System.debug('Account revenue updates during data migration are complete.');
    }
}
