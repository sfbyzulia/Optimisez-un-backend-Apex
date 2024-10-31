/**
 * Utility class providing methods to create test data for testing purposes.
 * This class prevents duplicate data creation by grouping methods that handle
 * the creation of commonly used test records (e.g., Account, Product, PricebookEntry).
 */
public class TestDataFactory {

    /**
     * Creates a test Account.
     * 
     * @return an Account object that has been inserted into the database.
     */
    public static Account createTestAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }

    /**
     * Creates a test Product.
     * 
     * @return a Product2 object with a predefined Name, Family, and active status.
     */
    public static Product2 createTestProduct() {
        Product2 prod = new Product2(Name = 'Test Product', Family = 'Test Family', IsActive = true);
        insert prod;
        return prod;
    }

    /**
     * Creates a PricebookEntry associated with a given Product.
     * 
     * @param prod The Product2 instance for which a PricebookEntry will be created.
     * @return a PricebookEntry object associated with the given product.
     */
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

    /**
     * Creates and activates a test Contract associated with an Account.
     * 
     * @param acc The Account instance to associate with the Contract.
     * @return an activated Contract object.
     */
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

    /**
     * Creates a test Order associated with an Account and a Contract.
     * 
     * @param acc The Account associated with the Order.
     * @param con The Contract associated with the Order.
     * @param pbe The PricebookEntry used to set the pricebook for the Order.
     * @return an Order object in draft status.
     */
    public static Order createOrder(Account acc, Contract con, PricebookEntry pbe) {
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            ContractId = con.Id,
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            ShipmentCost__c = 100
        );
        insert ord;
        return ord;
    }

    /**
     * Creates a list of OrderItems for a given Order and PricebookEntry.
     * 
     * @param ord The Order associated with the OrderItems.
     * @param pbe The PricebookEntry associated with the products in the OrderItems.
     * @return a list of OrderItem objects.
     */
    public static List<OrderItem> createOrderItems(Order ord, PricebookEntry pbe) {
        List<OrderItem> orderItems = new List<OrderItem>();

        // 10 items at 150
        OrderItem oi1 = new OrderItem(OrderId = ord.Id, PricebookEntryId = pbe.Id, Quantity = 10, UnitPrice = 150);
        orderItems.add(oi1);

        // 20 items at 1000
        OrderItem oi2 = new OrderItem(OrderId = ord.Id, PricebookEntryId = pbe.Id, Quantity = 20, UnitPrice = 1000);
        orderItems.add(oi2);

        insert orderItems;
        return orderItems;
    }

    /**
     * Creates and returns a set of test data including an Account, Product, PricebookEntry, 
     * Contract, Order, and associated OrderItems. Designed for full test data setup.
     * 
     * @return a map of created objects for use in tests.
     */
    public static Map<String, Object> createFullOrderData() {
        Account acc = createTestAccount();
        Product2 prod = createTestProduct();
        PricebookEntry pbe = createPricebookEntry(prod);
        Contract con = createContract(acc);
        Order ord = createOrder(acc, con, pbe);
        List<OrderItem> orderItems = createOrderItems(ord, pbe);

        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('account', acc);
        dataMap.put('product', prod);
        dataMap.put('pricebookEntry', pbe);
        dataMap.put('contract', con);
        dataMap.put('order', ord);
        dataMap.put('orderItems', orderItems);

        return dataMap;
    }
    
    /**
     * Creates test data for basic setup excluding Orders.
     * 
     * @return a map of created data objects excluding Order instances.
     */
        public static Map<String, Object> createBasicDataWithoutOrder() {
            Account acc = createTestAccount();
            Product2 prod = createTestProduct();
            PricebookEntry pbe = createPricebookEntry(prod);
            Contract con = createContract(acc);
    
            Map<String, Object> dataMap = new Map<String, Object>();
            dataMap.put('account', acc);
            dataMap.put('product', prod);
            dataMap.put('pricebookEntry', pbe);
            dataMap.put('contract', con);
    
            return dataMap;
        }
    }    