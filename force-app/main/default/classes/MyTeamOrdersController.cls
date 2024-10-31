/**
 * Controller class to retrieve the orders of users in the same team or role as the current user.
 * This allows team members (peers) to view each other's orders based on role grouping.
 */
public class MyTeamOrdersController {

    /**
     * Retrieves a list of orders created by users in the same role as the current user.
     * 
     * @return a list of Order records owned by users in the same role/team as the current user.
     */
    public List<Order> getTeamOrders() {
        // Query to retrieve orders for all users in the same role/team as the current user
        return [
            SELECT Id, TotalAmount, Status, Account.Name 
            FROM Order 
            WHERE Owner.UserRoleId = :UserInfo.getUserRoleId()
        ];
    }
}
