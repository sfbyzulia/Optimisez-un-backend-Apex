public class CalculMontantHandler {

    // Method to ensure that TotalAmount and ShipmentCost__c are updated properly
    public static void updateNetAmount(List<Order> orders) {
        for (Order ord : orders) {
            // Ensure that ShipmentCost__c is treated as 0 if null for the calculation
            if (ord.ShipmentCost__c == null) {
                ord.ShipmentCost__c = 0; // Default to 0 if not provided
            }
            // Ensuring that Salesforce recalculates the formula based on the other fields
        }
    }
}
