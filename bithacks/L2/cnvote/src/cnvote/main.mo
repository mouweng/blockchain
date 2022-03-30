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
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Result "mo:base/Result";

actor class vote (

){
  type Proposal = {
      id: Text;
      proposer: Principal;
      createTime: Time.Time;
      startTime: Time.Time;
      endTime: Time.Time;
      var supportVote: Nat;
      var againstVote: Nat;
  };
  type ProposalExt = {
      id: Text;
      proposer: Principal;
      createTime: Time.Time;
      startTime: Time.Time;
      endTime: Time.Time;
      supportVote: Nat;
      againstVote: Nat;
  };

  private let genPro : ProposalExt = {
      id = "not found";
      proposer = Principal.fromText("aaaaa-aa");
      createTime = 0;
      startTime = 0;
      endTime = 0;
      supportVote = 0;
      againstVote = 0;
  };

  private stable var proposalsEntries: [(Text, Proposal)] = [];
  private var proposals = HashMap.HashMap<Text, Proposal>(1, Text.equal, Text.hash);

  public shared(msg) func createProposal(id: Text, start: Int, end: Int) { //多少秒后开始，结束
    let proposer = msg.caller;
    let proposal = _newProposal(id, proposer, start, end);
    proposals.put(id, proposal);
  };

  private func _newProposal(id: Text, proposer: Principal, start: Int, end: Int) : Proposal {
    let createTime = Time.now();
    let startTime = createTime + start * 1000000000;
    let endTime = createTime + end * 1000000000;
    {
      id = id;
      proposer = proposer;
      createTime = createTime;
      startTime = startTime;
      endTime = endTime;
      var supportVote = 0;
      var againstVote = 0;
    }
  };

  public query func getProposal(id: Text) : async ProposalExt {
      _getProposal(id);
  };


  private func _getProposal(id: Text) : ProposalExt {
      switch (proposals.get(id)) {
        case (null) {
          genPro //初始分配的情况
        };
        case (?bal) {
          transform(bal)
        };
      }
  };

 
  // 将可变的proposal转换为不可变的返回值
  private func transform(p: Proposal) : ProposalExt {
    {
      id = p.id;
      proposer = p.proposer;
      createTime = p.createTime;
      startTime = p.startTime;
      endTime = p.endTime;
      supportVote = p.supportVote;
      againstVote = p.againstVote;
    }
  };

  type VoteType = {
    #Support;
    #Against;
  };

  // 将投票的id名称与投票者组合起来，成为唯一的变量。每个人只能对一个投票实例投票一次
  type IdVote = (Text, Principal);
  private var isVote = HashMap.HashMap<IdVote, Bool>(1, func (a : IdVote, b : IdVote) : Bool {
    Text.equal(a.0, b.0) and Principal.equal(a.1,b.1)
  }, func (k : IdVote){
    Text.hash(Text.concat(k.0, Principal.toText(k.1)))
  });

  private func supportInc(prop : Proposal) : ProposalExt {
      let ans = {  
        id = prop.id;
        proposer = prop.proposer;
        createTime = prop.createTime;
        startTime = prop.startTime;
        endTime = prop.endTime;
        var supportVote = prop.supportVote + 1;
        var againstVote = prop.againstVote;   
      };
      proposals.put(prop.id, ans);
      transform(ans);
  };

  private func againstInc(prop : Proposal) : ProposalExt {
        let ans = {  
          id = prop.id;
          proposer = prop.proposer;
          createTime = prop.createTime;
          startTime = prop.startTime;
          endTime = prop.endTime;
          var supportVote = prop.supportVote;
          var againstVote = prop.againstVote + 1;   
        };
        proposals.put(prop.id, ans);
        transform(ans);
      };  


  type VoteErr = {
    #VoteNotBegin;
    #VoteIsOver;
    #VoteRepeat;
  };

  type VoteReceipt = {
    #Ok: ProposalExt;
    #Err: VoteErr;
  };

  public shared(msg) func vote(id: Text, vote: VoteType) : async VoteReceipt{
    var prop = _getproposal(id);
    if (prop.startTime >= Time.now()) {
      return #Err(#VoteNotBegin);
    };
    if (prop.endTime <= Time.now()) {
      return #Err(#VoteIsOver);
    };
    let iv = (id, msg.caller);
    let isvote = _getvote(iv);
    if (isvote == true) {
      return #Err(#VoteRepeat);
    };
    if (vote == #Support) {
      #Ok(supportInc(prop));
    } else {
      #Ok(againstInc(prop));
    };
  };

  private func _getproposal(id: Text) : Proposal {
    switch (proposals.get(id)) {
      case (null) { // 如何处理option为空的情况？一种可以用Err包装，或者呢
        {
          id = "default prop";
          proposer = Principal.fromText("aaaaa-aa");
          createTime = 0;
          startTime = 0;
          endTime = 0;
          var supportVote = 0;
          var againstVote = 0;
        };
      };
      case (?val) {
        val;
      };
    };
  };

  private func _getvote(idVote: IdVote) : Bool {
    switch (isVote.get(idVote)) {
      case (null) {
        isVote.put(idVote, true);
        false;
      };
      case (?val) {
        val;
      };
    };
  };

  type VoteResult = {
      #Approved;
      #Rejected;
  };

  type VoteResultErr = {
    #VoteNotOver;
    #VoteDraw;
    #VoteNotExist;
  };

  type VoteResultReceipt = {
    #Ok: VoteResult;
    #Err: VoteResultErr;
  };

    //查询合约中存在的所有的投票结果（此时此刻的状态）[// fix 通过pair来转换，将id与receipt一起返回失败]
  // public query func getAllProposalResult() : async [VoteResultReceipt]{
  //   let vals = proposals.vals();
  //   // let mappedIter = Iter.map(vals, func (x : (Text, Proposal)) : (Text, VoteResultReceipt) {(x.0, proposalResult(x.1.id))});
  //   let arr = Iter.toArray(mappedIter);
  // };

  public query func proposalResult(id : Text) : async VoteResultReceipt {
    var prop = _getproposal(id);
    if (prop.endTime >= Time.now()) {
      return #Err(#VoteNotOver);
    } else {
      let supportVote = prop.supportVote;
      let againstVote = prop.againstVote;
      if (prop.createTime == 0) {
        return #Err(#VoteNotExist);
      };
      if (supportVote == againstVote) {
        return #Err(#VoteDraw);
      };
      if (supportVote > againstVote) {
        return #Ok(#Approved);
      } else {
        return #Ok(#Rejected);
      }
    }
  };

  //查询合约中存在的所有的投票（此时此刻的状态）
  public query func getAllProrosal() : async [ProposalExt]{
    let vals = proposals.vals();
    let mappedIter = Iter.map(vals, func (x : Proposal) : ProposalExt {transform(x)});
    let arr = Iter.toArray(mappedIter);
    // debug_show(arr);
  };

  system func preupgrade() {
    proposalsEntries := Iter.toArray(proposals.entries());
  };

    system func postupgrade() {
    proposals := HashMap.fromIter<Text, Proposal>(proposalsEntries.vals(), 1, Text.equal, Text.hash);
    proposalsEntries := [];
  };
};
