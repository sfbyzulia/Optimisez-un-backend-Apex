trigger CalculMontant on Order (before insert, before update) {
    CalculMontantHandler.updateNetAmount(Trigger.new);
}
