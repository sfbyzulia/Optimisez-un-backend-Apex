/**
 * Trigger that fires after an Order is updated. It invokes the `UpdateAccountCAHandler`
 * to update the associated Account's revenue (Chiffre_d_affaire__c) when an Order's 
 * status changes to 'Activated'.
 * 
 * Trigger Context:
 * - after update: Executes only after an Order record has been modified.
 * 
 * Purpose:
 * - To ensure that Accounts accurately reflect the total revenue from Orders in 'Activated' status.
 */
trigger UpdateAccountCA on Order (after update) {
    UpdateAccountCAHandler.updateAccountRevenue(Trigger.new, Trigger.oldMap);
}
