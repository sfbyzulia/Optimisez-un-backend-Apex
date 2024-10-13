public without sharing class MyTeamOrdersController {
    public decimal SumOrders {
        get {
            // Calculate the total orders for the current user
            AggregateResult totalOrders = [
                SELECT SUM(TotalAmount) total FROM Order WHERE OwnerId = :UserInfo.getUserId()
            ];

            if (totalOrders.get('total') != null) {
                return (decimal)totalOrders.get('total');
            }
            return 0;
        }
        set;
    }
}
