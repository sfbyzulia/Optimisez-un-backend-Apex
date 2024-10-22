global class UpdateProductsPricingScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateProductsPricing batch = new UpdateProductsPricing();
        Database.executeBatch(batch, 200);  // Process 200 records per batch
    }
}
