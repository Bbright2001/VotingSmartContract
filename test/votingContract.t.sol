// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {votingContract} from "../src/votingContract.sol";


contract votingContractTest is Test{
    votingContract public election;
    address admin;
    address voter1;
    address voter2;
    address candidate1; 
    address candidate2;

    function setUp() public{
    election = new votingContract();
    admin    = address(this);
    voter1   = address(0x1);
    voter2   = address(0x2);
    candidate1 = address(0x3);
    candidate2 = address(0x4);
    }

    function testVoterRegistration() public{

        vm.prank(admin);

        election.voterRegistration(voter1, "Amanda", votingContract.Gender.female);
        (string memory name, , bool isRegistered, bool voted) = election.voters(voter1);

        assertEq(name, "Amanda");
        assertTrue(isRegistered);
        assertFalse(voted);
    }

    function testCandidatesRegisteration() public{
        election.addCandidates(candidate1, "Unwana Bright Bassey");

        (string memory fullName, uint voteCount, bool isRegistered) = election.candidates(candidate1);
        assertEq(fullName, "Unwana Bright Bassey");
        assertEq(voteCount, 0);
        assertTrue(isRegistered);

    }

    function testVoting() public {

        vm.prank(admin);
        election.voterRegistration(voter1, "Amanda", votingContract.Gender.female);
        election.addCandidates(candidate1, "Unwana Bright Bassey");
        election.addCandidates(candidate2, "Peter obi");

            vm.prank(admin);
            //move to voting phase
            election.setElectionPhase(votingContract.electionPhase.voting);

            //cast a vote
            vm.prank(voter1);
            election.voteCandidates(candidate2);


            ( , uint voteCount, ) = election.candidates(candidate2);

        assertEq(voteCount, 1); 
    }
    function testGetWinner() public{
            // simulate the election
            vm.prank(admin);
            election.voterRegistration(voter1, "Amanda", votingContract.Gender.female);

            // Register candidates
            election.addCandidates(candidate1, "Unwana Bright Bassey");
            election.addCandidates(candidate2, "Peter obi");

             //move to voting phase
             vm.prank(admin);
             election.setElectionPhase(votingContract.electionPhase.voting);

                //vote a candidate
                vm.prank(voter1);
                election.voteCandidates(candidate1);

                //move to vote closing phase

                vm.prank(admin);
                election.setElectionPhase(votingContract.electionPhase.ended);

                //announce winner
                (, uint voteCount, ) = election.getWinner();
                assertEq(voteCount, 1);
    }

    function testOnlyOwnerAllowed() public{
        vm.prank(voter1);
        vm.expectRevert("Only Admin can perform this function");
        election.voterRegistration(voter1, "Amanda", votingContract.Gender.female);
        
    }

    function voteCandidatesOnlyRegisteredStudent() public{
        vm.prank(voter1);
        vm.expectRevert("You are not a registered student");
        election.voteCandidates(candidate1);
    } 

}

