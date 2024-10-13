trigger UpdateAccountCA on Order (after update) {
    UpdateAccountCAHandler.updateAccountRevenue(Trigger.new);
}
