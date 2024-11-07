/**
 * Trigger on Order to calculate the Net Amount based on TotalAmount and ShipmentCost__c fields.
 */
trigger CalculateAmount on Order (before insert, before update) {
    CalculateAmountHandler.calculateNetAmount(Trigger.new);
}
