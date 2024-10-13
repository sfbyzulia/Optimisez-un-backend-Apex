public without sharing class MyTeamOrdersController {
    public decimal SumOrders {
        get {
            // Step 1: Get the current user's role
            Id currentUserRoleId = [SELECT UserRoleId FROM User WHERE Id = :UserInfo.getUserId()].UserRoleId;

            // Step 2: Get users in the current user's role
            List<User> usersInCurrentRole = [
                SELECT Id FROM User WHERE UserRoleId = :currentUserRoleId
            ];

            // Extract User IDs from users in the current role
            List<Id> userIdsInCurrentRole = new List<Id>();
            for (User u : usersInCurrentRole) {
                userIdsInCurrentRole.add(u.Id);
            }

            // Step 3: Get users in child roles (roles below the current user's role)
            List<User> usersInChildRoles = [
                SELECT Id FROM User WHERE UserRoleId IN (
                    SELECT Id FROM UserRole WHERE ParentRoleId = :currentUserRoleId
                )
            ];

            // Extract User IDs from users in child roles
            List<Id> userIdsInChildRoles = new List<Id>();
            for (User u : usersInChildRoles) {
                userIdsInChildRoles.add(u.Id);
            }

            // Step 4: Combine both lists of user IDs
            List<Id> allUserIds = new List<Id>();
            allUserIds.addAll(userIdsInCurrentRole);
            allUserIds.addAll(userIdsInChildRoles);

            // Step 5: Calculate the total orders for those users
            AggregateResult totalOrders = [
                SELECT SUM(TotalAmount) total FROM Order WHERE OwnerId IN :allUserIds
            ];

            // Step 6: Return the total order amount or 0 if there are no orders
            if (totalOrders.get('total') != null) {
                return (decimal)totalOrders.get('total');
            }
            return 0;
        }
        set;
    }
}
