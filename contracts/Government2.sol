// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Government {
    address[] public citizens;
    address[] public officials;
    address[] public lawEnforcement;
    address payable owner;
    mapping(address => bool) public isOfficial;
    mapping(address => bool) public isLawEnforcement;
    mapping(address => uint256) public citizenBalances;
    mapping(address => uint256) public departmentBudgets;

    struct Law {
        string title;
        string content;
        address proposedBy;
        bool enacted;
    }
    Law[] public laws;

    struct Department {
        string name;
        address[] employees;
    }
    mapping(address => Department) public citizenDepartments;

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

    function registerAsLawEnforcement() public {
        require(!isLawEnforcement[msg.sender], "Cannot register as Law Enforcement, Already registered");
        lawEnforcement.push(msg.sender);
        isLawEnforcement[msg.sender] = true;
    }

    function vote(address candidate) public {
        require(!isOfficial[msg.sender], "Officials cannot vote");
        require(isOfficial[candidate], "Candidate is not an official");
    }

    function proposeLaw(string memory title, string memory content) public {
        require(isOfficial[msg.sender], "Only Officials can propose laws");
        laws.push(Law(title, content, msg.sender, false));
    }

    function enactLaw(uint256 lawIndex) public {
        require(msg.sender == owner || isOfficial[msg.sender], "Only Officials and the owner can enact laws");
        require(lawIndex < laws.length, "Invalid law index");
        laws[lawIndex].enacted = true;
    }

    function createDepartment(string memory name) public {
        require(isOfficial[msg.sender], "Only Officials can create departments");
        departmentBudgets[msg.sender] += 1000 ether; // Initial budget allocation
    }

    function assignToDepartment(address employee, string memory departmentName) public {
        require(isOfficial[msg.sender], "Only Officials can assign employees to departments");
        require(isOfficial[employee], "Employee must be an official");
        require(departmentBudgets[msg.sender] > 0, "Insufficient department budget");
        citizenDepartments[employee] = Department(departmentName, new address[](0));
        citizenDepartments[employee].employees.push(employee);
        departmentBudgets[msg.sender] -= 100 ether; // Deduct from the department's budget
    }

    function getOfficials() public view returns (address[] memory) {
        return officials;
    }

    function getCitizens() public view returns (address[] memory) {
        return citizens;
    }

    function getLawCount() public view returns (uint256) {
        return laws.length;
    }

    function getDepartmentEmployees(address departmentOwner) public view returns (address[] memory) {
        return citizenDepartments[departmentOwner].employees;
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