global class UpdateAccounts implements Database.Batchable<sObject> {

       global Database.QueryLocator start(Database.BatchableContext info){ 
        // Query only accounts with at least one order in status 'Activated' 
        return Database.getQueryLocator([
            SELECT Id 
            FROM Account 
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Activated') 
        ]);
    }

        global void execute(Database.BatchableContext info, List<Account> scope){
            // Collect the account IDs from the current batch
            Set<Id> accountIds = new Set<Id>();
            for (Account acc : scope) {
                accountIds.add(acc.Id);
            }
     
            // Query only the orders related to the accounts in the current batch
            List<Order> orders = [
                SELECT AccountId, TotalAmount 
                FROM Order 
                WHERE AccountId IN :accountIds
            ];
     
            // Create a map to store the revenue for each account
            Map<Id, Decimal> accountRevenueMap = new Map<Id, Decimal>();
     
            // For each order, add its total amount to the corresponding account's revenue
            for (Order order : orders) {
                if (accountRevenueMap.containsKey(order.AccountId)) {
                    accountRevenueMap.put(order.AccountId, accountRevenueMap.get(order.AccountId) + order.TotalAmount);
                } else {
                    accountRevenueMap.put(order.AccountId, order.TotalAmount);
                }
            }
     
            // Update the accounts in the current batch based on the revenue data from the map
            for (Account acc : scope) {
                if (accountRevenueMap.containsKey(acc.Id)) {
                    acc.Chiffre_d_affaire__c = accountRevenueMap.get(acc.Id);
                } else {
                    acc.Chiffre_d_affaire__c = 0;
                }
            }
     
            // Update the accounts in the database
            update scope;
        }    
         
        global void finish(Database.BatchableContext info) {     
            System.debug('Account revenue updates during data migration have been completed.');
        }        
     }
     