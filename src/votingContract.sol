// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract votingContract{
 enum Gender{male, female, others}
 enum electionPhase{ registration, voting, ended}
 
    struct Voter{
        string name;
        Gender gender;
        bool isRegistered;
        bool voted;
    }

    struct Candidate{
        string fullName;
        uint voteCount;
        bool isRegistered;
    }
    //state variables
    address admin;
    electionPhase currentPhase;

    //mappiings
    mapping(address => Voter) public voters;
    mapping(address => Candidate) public candidates;
    mapping(Gender => uint) public genderVotes;// to track votes by gender
    mapping(Gender => uint) public genderCount;// to track how many people registered as male, female.

    address[] public candidateAddresses;


    //Events
    event voteCast(address voterAddress, address candidateAddress, string fullName );
    event voterRegistered(address  voterAddress,string name, Gender gender);
    

    //modifier
    modifier onlyOwner {
        require(msg.sender == admin, "Only Admin can perform this function");
        _;
    }
    //  modifier isRegistered {
    //     require(voters[msg.sender].isRegistered , "You are not a registered voter");
    //      _; 
    // }

    modifier alreadyVoted {
        require(!voters[msg.sender].voted, "Already Voted");
        _;
    }

    

    //Constructor
        constructor(){
            admin = msg.sender;
            currentPhase = electionPhase.registration;
        }
    //Functions

        // to go from one Phase to another
    function setElectionPhase(electionPhase _phase) public onlyOwner(){
        currentPhase = _phase;

    }

    // To register a voter
    function voterRegistration(address voterAddress, string memory _name, Gender _gender) public onlyOwner {
        require(currentPhase == electionPhase.registration, "Not in registration phase");
        require(!voters[voterAddress].isRegistered, "You are already a registered voter!");

        voters[voterAddress] = Voter(_name, _gender, true, false);
        
        genderCount[_gender] += 1;

        emit voterRegistered(voterAddress, _name, _gender);
    }
    //  to add a candidates
    function addCandidates(address _candidateAddress, string memory _fullName) public onlyOwner{
        require(!candidates[_candidateAddress].isRegistered, "Already a registered candidate");

        candidates[_candidateAddress] = Candidate({
            fullName: _fullName,
        voteCount: 0,
        isRegistered: true
        });
        
        candidateAddresses.push(_candidateAddress);
    }

    //To vote a candidate
    function  voteCandidates(address _candidateAddress) public  alreadyVoted {
            Voter storage v =  voters[msg.sender];
            require(currentPhase == electionPhase.voting, "voting is not active");
            require(candidates[_candidateAddress].isRegistered, "not a registered candidate");

            v.voted = true;

            candidates[_candidateAddress].voteCount += 1;
            genderVotes[v.gender] += 1;

            emit voteCast(msg.sender, _candidateAddress, candidates[_candidateAddress].fullName);

    }

        // To get votes stat by gender
    function getVotesByGender() public view returns (uint maleVotes, uint femaleVotes, uint otherVotes){
        maleVotes = genderCount[Gender.male];
        femaleVotes = genderCount[Gender.female];
        otherVotes = genderCount[Gender.others];
    }
    
    // to get Voting winner

  function getWinner() public view returns (address winnerAddress, uint voteCount, string memory fullName) {
    require(currentPhase == electionPhase.ended, "Election has not yet ended!!!");

    uint winningCount = 0;
    address topCandidate;

    for (uint i = 0; i < candidateAddresses.length; i++) {
        address candidateAddr = candidateAddresses[i];
        if (candidates[candidateAddr].voteCount > winningCount) {
            winningCount = candidates[candidateAddr].voteCount;
            topCandidate = candidateAddr; // ✅ Correct assignment
        }
    }

    Candidate memory top = candidates[topCandidate];
    return (topCandidate, top.voteCount, top.fullName);
}
}