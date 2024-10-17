public without sharing class MyTeamOrdersController {
    public decimal SumOrders {
        get {
            // Calculate the total orders for the current user
            AggregateResult totalOrders = [
                SELECT SUM(TotalAmount) total FROM Order WHERE OwnerId = :UserInfo.getUserId()
            ];

            // Return the total or 0 if total is null
            return (totalOrders.get('total') == null) ? 0 : (decimal)totalOrders.get('total');
        }
        set;
    }
}
