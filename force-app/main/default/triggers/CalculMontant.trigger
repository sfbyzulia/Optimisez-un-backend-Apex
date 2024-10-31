trigger CalculMontant on Order (before insert, before update) {
    for (Order ord : Trigger.new) {
        // Calculate Net_Amount__c based on TotalAmount and ShipmentCost__c values
        if (ord.TotalAmount != null) {
            ord.Net_Amount__c = ord.TotalAmount - (ord.ShipmentCost__c != null ? ord.ShipmentCost__c : 0);
        } else {
            ord.Net_Amount__c = 0;
        }
    }
}
