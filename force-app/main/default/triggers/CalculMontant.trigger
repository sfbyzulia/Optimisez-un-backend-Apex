trigger CalculMontant on Order (before update) {
    for (Order ord : Trigger.new) {
        if (ord.TotalAmount != null && ord.ShipmentCost__c != null) {
            ord.Net_Amount__c = ord.TotalAmount - ord.ShipmentCost__c;
        } else if (ord.TotalAmount != null) {
            ord.Net_Amount__c = ord.TotalAmount;
        } else {
            ord.Net_Amount__c = 0;
        }
    }
}
