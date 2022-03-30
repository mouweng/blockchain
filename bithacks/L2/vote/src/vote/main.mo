import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Result "mo:base/Result";

actor Myvote{
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

  type VoteType = {
    #Support;
    #Against;
  };

  type VoteResult = {
    #Approved;
    #Rejected;
    #Draw;
    #Error: Text;
  };

  // 返回结构体
  type Response<T> = Result.Result<T, Text>;

  // proposalMap，存储id到proposal的映射
  private var proposalMap = HashMap.HashMap<Text, Proposal>(1, Text.equal, Text.hash);
  // Map记录投票信息，存储Text:proposalId + proposer
  private var voteMap = HashMap.HashMap<Text, Bool>(1, Text.equal, Text.hash);
  
  // stable
  private stable var proposalsEntries: [(Text, Proposal)] = [];
  private stable var votesEntries: [(Text, Bool)] = [];

  // 转换Proposal为ProposalExt
  private func transform(proposal: Proposal) : ProposalExt {
    {
      id = proposal.id;
      proposer = proposal.proposer;
      createTime = proposal.createTime;
      startTime = proposal.startTime;
      endTime = proposal.endTime;
      supportVote = proposal.supportVote;
      againstVote = proposal.againstVote;
    }
  };


  // 创建Proposal
  private func _createProposal(proposalId: Text, proposer: Principal, startTime: Int, endTime: Int) : Proposal {
      let baseTime = 1000000000;
      let createTime = Time.now();
      {
        id = proposalId;
        proposer = proposer;
        createTime = createTime;
        startTime = createTime + startTime * baseTime;
        endTime = createTime + endTime * baseTime;
        var supportVote = 0;
        var againstVote = 0;
      }
  };

  // 创建Proposal，传入参数：Proposal id | Proposal startTime | Proposal endTime
  public shared(msg) func createProposal(proposalId: Text, startTime: Int, endTime: Int) : async Response<ProposalExt> {
    // 特殊情况处理
    if (startTime >= endTime) {
      return #err("The end time should be bigger than the start time");
    };
    if (startTime < 0) {
      return #err("start time should bigger than zero");
    };

    // 判断proposal是否存在
    switch(proposalMap.get(proposalId)) {
      case (null) {};
      case (?proposal) {
        return #err("vote exist!");
      };
    };

    // 调用_createProposal，创建一个proposal
    let proposal = _createProposal(proposalId, msg.caller, startTime, endTime);
    // 存储到proposalMap中
    proposalMap.put(proposalId, proposal);

    // 返回结果
    #ok(transform(proposal));
  };

  // 获取Proposal
  private func _getProposal(proposalId: Text) : Proposal {
    switch (proposalMap.get(proposalId)) {
      // 如果不存在，则返回一个null格式的Proposal
      case (null) {
        {
          id = "null";
          proposer = Principal.fromText("aaaaa-aa");
          createTime = 0;
          startTime = 0;
          endTime = 0;
          var supportVote = 0;
          var againstVote = 0;
        };
      };
      case (?proposal) {
        proposal;
      };
    };
  };

  // 获取Proposal
  public query func getProposal(proposalId: Text) : async ProposalExt {
    transform(_getProposal(proposalId));
  };

  

  // 投票
  public shared(msg) func vote(proposalId: Text, voteType: VoteType) :async Response<()> {
    // 获取proposal
    var proposal = _getProposal(proposalId);

    // 特殊情况处理
    if (proposal.id == "null") {
      return #err("proposal is null!");
    };
    if (proposal.startTime >= Time.now()) {
      return #err("vote not start");
    };
    if (proposal.endTime <= Time.now()) {
      return #err("vote has ended");
    };

    // 组合proposalId + proposer，记录用户历史投票
    let voteMsg = proposalId # Principal.toText(msg.caller);
    // 判断用户是否已经投过票
    switch (voteMap.get(voteMsg)) {
      case (null) {
        voteMap.put(voteMsg, true);
      };
      case (?val) {
        return #err("you can not vote twice");
      };
    };
    // 投票++
    switch(voteType) {
      case (#Support) {
        proposal.supportVote += 1;
      };
      case (#Against) {
        proposal.againstVote += 1;
      };
    };
    // 返回
    #ok(());
  };

  // 返回投票结果
  public query func proposalResult(proposalId : Text) : async VoteResult {
    // 获取proposal
    var proposal = _getProposal(proposalId);

    // 特殊情况处理
    if (proposal.id == "null") {
      return #Error("proposal is null!");
    };
    if (proposal.endTime >= Time.now()) {
      return #Error("Vote not over");
    };

    // 返回投票结果
    if (proposal.supportVote == proposal.againstVote) {
      return #Draw;
    } 
    else if (proposal.supportVote > proposal.againstVote) {
      return #Approved;
    } else {
      return #Rejected;
    };
  };

  // system methods
  system func preupgrade() {
    proposalsEntries := Iter.toArray(proposalMap.entries());
    votesEntries := Iter.toArray(voteMap.entries());
  };

  // system methods
  system func postupgrade() {
    proposalMap := HashMap.fromIter<Text, Proposal>(proposalsEntries.vals(), 1, Text.equal, Text.hash);
    proposalsEntries := [];

    voteMap := HashMap.fromIter<Text, Bool>(votesEntries.vals(), 1, Text.equal, Text.hash);
    votesEntries := [];
  };
};
