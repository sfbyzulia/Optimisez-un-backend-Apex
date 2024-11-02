/**
 * Trigger on Order to calculate the Net Amount based on TotalAmount and ShipmentCost__c fields.
 */
trigger CalculMontant on Order (before insert, before update) {
    CalculMontantHandler.calculateNetAmount(Trigger.new);
}
