global class UpdateProductPricesScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateProductPrices batch = new UpdateProductPrices();
        Database.executeBatch(batch, 200);  // Process 200 records per batch
    }
}
