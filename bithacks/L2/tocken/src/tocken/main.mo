import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Order "mo:base/Order";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Result "mo:base/Result";

actor class Token (
  owner: Principal,
  name: Text,
  symbol: Text,
  decimals: Nat8,
  totalSupply: Nat,
) {

  type Status = {
    #Succeed;
    #Fail: {
      #InsuffcientBalance;
    };
  };

  type TxRecord = {
    index: Nat;
    from: Principal;
    to: Principal;
    amount: Nat;
    timestamp: Time.Time;
    status: Status;
  };

  type MetaData = {
    name : Text;
    symbol : Text;
    decimals : Nat8;
    totalSupply : Nat;
  };

  // storage
  // meta data
  private stable let meta: MetaData = {
    name = name;
    symbol = symbol;
    decimals = decimals;
    totalSupply = totalSupply;
  };
  // user balance
  private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
  private stable var balanceEntries: [(Principal, Nat)] = [];
  // tx record
  private var records = Buffer.Buffer<TxRecord>(10);
  private stable var recordArray: [TxRecord] = [];
  // genesis record
  balances.put(owner, totalSupply);
  private let genesis : TxRecord = {
      index = 0;
      from = Principal.fromText("aaaaa-aa");
      to = owner;
      amount = totalSupply;
      timestamp = Time.now();
      status = #Succeed;
  };
  records.add(genesis);

  // update methods
  // transfer from msg.caller to `to`, with `amount`
  public shared(msg) func transfer(to: Principal, amount: Nat) : async TxRecord {
    let from = msg.caller;
    let balanceFrom = _getBalance(from);
    let status = if (balanceFrom < amount) {
      #Fail(#InsuffcientBalance)
    } else {
      let balanceTo = _getBalance(to);
      balances.put(from, balanceFrom - amount);
      balances.put(to, balanceTo + amount);
      #Succeed
    };
    let record = _newRecord(from, to, amount, status);
    records.add(record);
    return record;
  };

  // query methods
  // get balance
  public query func getBalance(who: Principal) : async Nat {
    _getBalance(who)
  };

  public query func getTxRecordSize() : async Nat {
    records.size()
  };

  public query func getTxRecord(index: Nat) : async ?TxRecord {
    records.getOpt(index)
  };

  public query func getMetaData() : async MetaData {
    meta
  };

  // internal methos
  private func _getBalance(who: Principal) : Nat {
    switch (balances.get(who)) {
      case (null) {
        0
      };
      case (?bal) {
        bal
      };
    };
  };

  private func _newRecord(from: Principal, to: Principal, amount: Nat, status: Status) : TxRecord {
    {
      index = records.size();
      from = from;
      to = to;
      amount = amount;
      timestamp = Time.now();
      status = status;
    }
  };

  // system methods
  system func preupgrade() {
    balanceEntries := Iter.toArray(balances.entries());
    recordArray := records.toArray();
  };

  system func postupgrade() {
    balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
    balanceEntries := [];

    records := Buffer.Buffer<TxRecord>(recordArray.size());
    for (record in recordArray.vals()) {
      records.add(record);
    };
    recordArray := [];
  };
};