public class TestDataFactory {

    // Method to create a test account
    public static Account createTestAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }

    // Method to create a test product
    public static Product2 createTestProduct() {
        Product2 prod = new Product2(Name = 'Test Product', Family = 'Test Family', IsActive = true);
        insert prod;
        return prod;
    }

    // Method to create a pricebook entry
    public static PricebookEntry createPricebookEntry(Product2 prod) {
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert pbe;
        return pbe;
    }

    // Method to create a contract
    public static Contract createContract(Account acc) {
        Contract con = new Contract(
            AccountId = acc.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
        );
        insert con;
        con.Status = 'Activated';
        update con;
        return con;
    }

    // Method to create an order
    public static Order createOrder(Account acc, Contract con, PricebookEntry pbe) {
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            ContractId = con.Id,
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            ShipmentCost__c = 100
        );
        insert ord;  // Ensure the order is inserted before returning it
        return ord;
    }

    // Method to create order items
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

    // Parent method to group multiple creation methods and return a map of created data
    public static Map<String, Object> createFullOrderData() {
        // Create test data for Account, Product, PricebookEntry, Contract, and Order
        Account acc = createTestAccount();
        Product2 prod = createTestProduct();
        PricebookEntry pbe = createPricebookEntry(prod);
        Contract con = createContract(acc);
        Order ord = createOrder(acc, con, pbe);
        List<OrderItem> orderItems = createOrderItems(ord, pbe);

        // Insert order items after order is inserted
        insert orderItems;

        // Return a map with the created data to be used in tests
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('account', acc);
        dataMap.put('product', prod);
        dataMap.put('pricebookEntry', pbe);
        dataMap.put('contract', con);
        dataMap.put('order', ord);
        dataMap.put('orderItems', orderItems);

        return dataMap;
    }
    
        // New parent method to create test data without orders
        public static Map<String, Object> createBasicDataWithoutOrder() {
            // Create test data for Account, Product, PricebookEntry, and Contract (no Order)
            Account acc = createTestAccount();
            Product2 prod = createTestProduct();
            PricebookEntry pbe = createPricebookEntry(prod);
            Contract con = createContract(acc);
    
            // Return a map with the created data
            Map<String, Object> dataMap = new Map<String, Object>();
            dataMap.put('account', acc);
            dataMap.put('product', prod);
            dataMap.put('pricebookEntry', pbe);
            dataMap.put('contract', con);
    
            return dataMap;
        }
    }    