import Time "mo:base/Time";
import Result "mo:base/Result";
import Array "mo:base/Array";
import TrieSet "mo:base/TrieSet";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

actor Governance {
  type Receipt<T> = Result.Result<T, Text>;

  type Proposal = {
    id: Nat;
    proposer: Principal;
    createTime: Time.Time;
    startTime: Time.Time;
    endTime: Time.Time;
    var supportVote: Nat;
    var againstVote: Nat;
  };
  type ProposalExt = {
    id: Nat;
    proposer: Principal;
    createTime: Time.Time;
    startTime: Time.Time;
    endTime: Time.Time;
    supportVote: Nat;
    againstVote: Nat;
  };
  private stable var proposals: [Proposal] = [];
  private func _newProposal(proposer: Principal, start: Time.Time, end: Time.Time) : Proposal {
    {
      id = proposals.size();
      proposer = proposer;
      createTime = Time.now();
      startTime = start;
      endTime = end;
      var supportVote = 0;
      var againstVote = 0;
    }
  };
  private func _toProposalExt(proposal: Proposal) : ProposalExt {
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
  public shared(msg) func createProposal(start: Time.Time, end: Time.Time) : async Receipt<ProposalExt> {
    if (start >= end) {
      return #err("End time must bigger than start time");
    }; 
    if (start <= Time.now()) {
      return #err("Start time must bigger than now");
    };
    let p = _newProposal(msg.caller, start, end);
    proposals := Array.append(proposals, [p]);
    #ok(_toProposalExt(p))
  };
  public query func getProposal(id: Nat) : async ?ProposalExt {
    if (id >= proposals.size()) {
      return null;
    };
    ?_toProposalExt(proposals[id])
  };

  type VoteType = {
    #Support;
    #Against;
  };
  private stable var voteSet = TrieSet.empty<Text>();
  public shared(msg) func vote(id: Nat, voteType: VoteType) :async Receipt<()> {
    if (id >= proposals.size()) {
      return #err("Proposal not exist");
    };
    let now = Time.now();
    let voter = msg.caller;
    let proposal = proposals[id];
    if (now < proposal.startTime) {
      return #err("Vote not start");
    };
    if (now > proposal.endTime) {
      return #err("Vote has ended");
    };
    let voteId = Nat.toText(id) # Principal.toText(voter);
    if (TrieSet.mem(voteSet, voteId, Text.hash(voteId), Text.equal)) {
      return #err("User has already vote for this proposal");
    };
    switch(voteType) {
      case (#Support) {
        proposal.supportVote += 1;
      };
      case (#Against) {
        proposal.againstVote += 1;
      };
    };
    #ok(())
  };

  type VoteResult = {
    #Approved;
    #Rejected;
    #Error: Text;
  };
  public query func proposalResult(id: Nat) : async VoteResult {
    if (id >= proposals.size()) {
      return #Error("Proposal not exist");
    };
    let now = Time.now();
    let proposal = proposals[id];
    if (now < proposal.startTime) {
      return #Error("Vote not start");
    };
    if (now < proposal.endTime) {
      return #Error("Vote not end");
    };
    if (proposal.supportVote > proposal.againstVote) {
      #Approved
    } else {
      #Rejected
    };
  };
};