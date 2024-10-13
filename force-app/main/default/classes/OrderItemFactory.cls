public class OrderItemFactory {
    public static List<OrderItem> createOrderItems(Order ord, PricebookEntry pbe) {
        List<OrderItem> orderItems = new List<OrderItem>();
        
        // 10 items at 150
        OrderItem oi1 = new OrderItem(OrderId = ord.Id, PricebookEntryId = pbe.Id, Quantity = 10, UnitPrice = 150);
        orderItems.add(oi1);
        
        // 20 items at 1000
        OrderItem oi2 = new OrderItem(OrderId = ord.Id, PricebookEntryId = pbe.Id, Quantity = 20, UnitPrice = 1000);
        orderItems.add(oi2);
    
        return orderItems;
    }
}
