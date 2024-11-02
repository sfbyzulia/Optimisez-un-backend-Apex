/**
 * Scheduler class to run the UpdateProductsPricing batch job on a scheduled basis,
 * applying a 5% increase to active PricebookEntry prices in the Standard Pricebook.
 */
global class UpdateProductsPricingScheduler implements Schedulable {

    /**
     * Executes the scheduled UpdateProductsPricing batch job.
     * 
     * @param sc The context of the scheduled job.
     */
    global void execute(SchedulableContext sc) {
        UpdateProductsPricing batch = new UpdateProductsPricing();
        Database.executeBatch(batch, 200);
    }
}
