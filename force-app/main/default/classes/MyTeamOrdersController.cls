/**
 * Controller class to retrieve the orders of users in the same team or role as the current user.
 * This allows team members (peers) to view each other's orders based on role grouping and see the total order amount.
 */
public class MyTeamOrdersController {

    /**
     * Retrieves a list of orders visible to users in the same role as the current user.
     * 
     * @return a list of Order records available to users in the same role/team as the current user.
     */
    public List<Order> getTeamOrders() {
        // Query to retrieve orders based on role/team visibility set by sharing rules
        return [
            SELECT Id, TotalAmount, Status, Account.Name 
            FROM Order 
        ];
    }

    /**
     * Retrieves the sum of TotalAmount for orders visible to the current user based on team visibility.
     *
     * @return Decimal value representing the sum of TotalAmount for team orders.
     */
    public Decimal getTotalOrderSum() {
        // Query to calculate the sum of TotalAmount for all visible orders
        AggregateResult[] results = [
            SELECT SUM(TotalAmount) totalAmountSum
            FROM Order
        ];
        
        // Return the sum or 0 if no orders are found
        return (results.isEmpty() || results[0].get('totalAmountSum') == null) ? 0 : (Decimal) results[0].get('totalAmountSum');
    }
}
