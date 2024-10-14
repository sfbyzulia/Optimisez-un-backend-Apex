global class UpdateAccountsSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateAccounts batch = new UpdateAccounts();
        Database.executeBatch(batch, 200); // 200 is the batch size
    }
}
