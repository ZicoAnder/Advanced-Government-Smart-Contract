// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.19;

contract Government {
    address[] public citizens;
    address[] public officials;
    address payable owner;
    mapping(address => bool) public isOfficial;

    constructor() {
        owner = payable(msg.sender);
    }

    function registerAsCitizen() public {
        require(!isOfficial[msg.sender], "Cannot register as Citizen, Already an official");
        citizens.push(msg.sender);
    }

    function registerAsOfficial() public {
        require(!isOfficial[msg.sender], "Cannot register as Citizen, Already an official");
        officials.push(msg.sender);
        isOfficial[msg.sender] = true;
    }

    function vote(address candidate) public {
        require(!isOfficial[msg.sender],"Officials cannot vote");
        require(isOfficial[candidate],"Officials cannot vote");

    }

    function proposeLaw(address candidate) public {
        require(isOfficial[msg.sender],"Only Officials can propose laws");
    }

    function enactLaw(address candidate) public {
        require(msg.sender == owner ,"Only Officials can propose laws");
    }

    function getOfficials() public view returns(address[] memory) {
        return officials;
    }

    function getCitizens() public view returns(address[] memory) {
        return citizens;
    }

    function grantAccess(address payable user) public {
        require(msg.sender == owner, "Only the owner can grant access");
        owner = user;
    } 

    function revokeAccess(address payable user) public {
        require(msg.sender == owner, "Only the owner can revoke access");
        require(user != owner, "Cannot revoke access for the current owner");
        owner = payable(msg.sender);
    } 

    function destroy() public {
        require(msg.sender == owner, "Only the owner can destroy this contract");
        selfdestruct(owner);
    }    
}