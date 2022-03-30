import Principal "mo:base/Principal"
import HashMap "mo:base/HashMap"

actor class Tocken(
  owner_ : Principal,
  name_ : Text,
  symbol_ : Text,
  decimals_ : Nat8,
  totalSupply_ : Nat
){

  stable let owner = owner_;
  stable let name = name_;
  stable let symbol = symbol_;
  stable let decimals = decimals_;
  stable let totalSupply = totalSupply_;

  type TxRecord = {
    index: Nat,
    from: Principal,
    to: Principal,
    amount: Nat
  };

  var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Pripal.hash);
  var records: [TxRecord] = [];

  balances.put(owner, totalSupply);


  public query func _getBalance(who : Principal) : async Nat {
    switch (balances.get(who)) {
      case (null) {0};
      case(?val) {val};
    };
  };

  public query func getTxRecords() : async ?TxRecord {
    if (index >= records.size()) {
      null;
    } else {
      records[index];
    };
  }

  public query func getBalance(who : Principal) : async Nat {
    _getBalance(who)
  };

  public shared(msg) func transfer(to: Principal, amount: Nat) : async TxRecord {
    let from = msg.sender;
    let balance = await _getBalance(from);
    if (balance < amount) {
      throw new Error("transfer: insufficient funds");
    }
    balances.set(from, balance - amount);
    balances.set(to, await getBalance(to) + amount);
    return new TxRecord(from, to, amount);
  };

};