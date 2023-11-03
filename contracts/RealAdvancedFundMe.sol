// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

contract FundMeAdvanced {
    using PriceConverter for uint256; // Import the PriceConverter library

    enum FundraiserStatus { Active, Completed }

    struct Fundraiser {
        address creator;
        string name;
        string description;
        uint goal;
        uint amountRaised;
        FundraiserStatus status;
    }

    Fundraiser[] public fundraisers;
    address public owner;
    uint public minimumUSD = 500 * 10**18; // Minimum funding goal in USD

    AggregatorV3Interface public priceFeed; // Chainlink Price Feed Interface

    event FundraiserCreated(address indexed creator, uint fundraiserIndex);
    event FundraiserFunded(address indexed funder, uint fundraiserIndex, uint amount);

    constructor(address _priceFeedAddress) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function createFundraiser(string memory name, string memory description, uint goal) public {
        // ... (unchanged)
         require(bytes(name).length > 0, "Fundraiser name cannot be empty");
        require(bytes(description).length > 0, "Fundraiser description cannot be empty");
        require(goal > 0, "Fundraiser goal amount must be greater than 0");

        uint fundraiserIndex = fundraisers.length;
        fundraisers.push(Fundraiser({
            creator: msg.sender,
            name: name,
            description: description,
            goal: goal,
            amountRaised: 0,
            status: FundraiserStatus.Active
        }));

        emit FundraiserCreated(msg.sender, fundraiserIndex);
    }

    function fund(uint fundraiserIndex) public payable {
    require(fundraiserIndex < fundraisers.length, "Fundraiser does not exist");
    Fundraiser storage fundraiser = fundraisers[fundraiserIndex];

    require(fundraiser.status == FundraiserStatus.Active, "Fundraiser is not active");
    require(msg.value > 0, "Sent amount must be greater than 0");

    // Convert the sent ETH amount to USD using the PriceConverter library
    uint ethAmountInUsd = msg.value.getConversionRate();

    uint currentRaisedUSD = fundraiser.amountRaised.getConversionRate();

    require(ethAmountInUsd + currentRaisedUSD >= minimumUSD, "Fundraiser does not meet the minimum funding requirement");

    fundraiser.amountRaised += msg.value;
    emit FundraiserFunded(msg.sender, fundraiserIndex, msg.value);

    if (fundraiser.amountRaised >= fundraiser.goal) {
        fundraiser.status = FundraiserStatus.Completed;
    }
}


    function withdrawFunds(uint fundraiserIndex) public onlyOwner {
        require(fundraiserIndex < fundraisers.length, "Fundraiser does not exist");
        Fundraiser storage fundraiser = fundraisers[fundraiserIndex];

        require(fundraiser.status == FundraiserStatus.Completed, "Fundraiser is not completed");

        uint balanceToWithdraw = fundraiser.amountRaised;
        fundraiser.amountRaised = 0;

        (bool success, ) = owner.call{value: balanceToWithdraw}("");
        require(success, "Withdrawal failed");
        // ... (unchanged)
    }
}
