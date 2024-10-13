public class UpdateAccountCAHandler {
    
    public static void updateAccountRevenue(List<Order> orders) {
        Set<Id> setAccountIds = new Set<Id>();

        for (Order newOrder : orders) {
            if (newOrder.AccountId != null && newOrder.TotalAmount != null) {
                setAccountIds.add(newOrder.AccountId);
            }
        }

        if (!setAccountIds.isEmpty()) {
            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :setAccountIds
            ]);

            for (Order newOrder : orders) {
                if (newOrder.TotalAmount != null && accountMap.containsKey(newOrder.AccountId)) {
                    Account acc = accountMap.get(newOrder.AccountId);
                    acc.Chiffre_d_affaire__c = (acc.Chiffre_d_affaire__c != null) ? acc.Chiffre_d_affaire__c : 0;
                    acc.Chiffre_d_affaire__c += newOrder.TotalAmount;
                }
            }
            update accountMap.values();
        }
    }
}
