/**
 * Handler class for the CalculateAmount trigger on the Order object.
 * This class contains the logic to calculate the Net Amount for each Order.
 */
public class CalculateAmountHandler {

    /**
     * Calculates the Net_Amount__c for each Order record in the provided list.
     * The Net_Amount__c is determined by subtracting ShipmentCost__c from TotalAmount.
     *
     * @param orders List of Order records in Trigger context to calculate Net Amount.
     */
    public static void calculateNetAmount(List<Order> orders) {
        for (Order ord : orders) {
            // Calculate Net_Amount__c based on TotalAmount and ShipmentCost__c values
            if (ord.TotalAmount != null) {
                ord.Net_Amount__c = ord.TotalAmount - (ord.ShipmentCost__c != null ? ord.ShipmentCost__c : 0);
        }
     }
   }
}
