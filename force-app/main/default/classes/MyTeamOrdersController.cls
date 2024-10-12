public without sharing class MyTeamOrdersController {
    public decimal SumOrders {
        get {
            // Step 1: Fetch user IDs for the current user's role
            List<User> usersInCurrentRole = [
                SELECT Id 
                FROM User 
                WHERE UserRoleId = :UserInfo.getUserRoleId()
            ];
            
            // Extract User Ids from the result
            List<Id> userIdsInCurrentRole = new List<Id>();
            for (User u : usersInCurrentRole) {
                userIdsInCurrentRole.add(u.Id);
            }

            // Step 2: Fetch user IDs for the roles below the current user’s role in the hierarchy
            List<User> usersInChildRoles = [
                SELECT Id 
                FROM User 
                WHERE UserRoleId IN (
                    SELECT Id FROM UserRole WHERE ParentRoleId = :UserInfo.getUserRoleId()
                )
            ];

            // Extract User Ids from the result
            List<Id> userIdsInChildRoles = new List<Id>();
            for (User u : usersInChildRoles) {
                userIdsInChildRoles.add(u.Id);
            }

            // Combine both lists of user IDs
            List<Id> allUserIds = new List<Id>();
            allUserIds.addAll(userIdsInCurrentRole);
            allUserIds.addAll(userIdsInChildRoles);

            // Step 3: Query the total amount for the orders owned by users in the role hierarchy
            List<AggregateResult> groupedResults = [
                SELECT SUM(TotalAmount) total 
                FROM Order 
                WHERE OwnerId IN :allUserIds
            ];

            // Step 4: Return the result, or 0 if no orders found
            if (groupedResults.size() > 0 && groupedResults[0].get('total') != null) {
                return (decimal)groupedResults[0].get('total');
            }
            return 0;
        }
        set;
    }
}
