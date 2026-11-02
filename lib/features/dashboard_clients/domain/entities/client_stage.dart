/// Commercial pipeline stage, from first contact to signed contract.
enum ClientStage {
  potential,
  inspection,
  quotation,
  contracted;

  /// Stages a new client can start in, in order. "Contracted" is only set
  /// once the contract is signed (quotes & contracts page).
  static const forNewClient = [potential, inspection, quotation];
}
