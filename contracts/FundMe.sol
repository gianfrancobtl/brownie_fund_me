// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    // this allows the contract to use the SafeMathChainlink library; it's very similar to OnlyZeppelin's one.
    using SafeMathChainlink for uint256;

    // mapping from address to the total amount funded to the contract.
    mapping(address => uint256) public addressToAmountFunded;

    address[] public funders;
    address public owner;

    AggregatorV3Interface public priceFeed;

    // this constructor executes at the beginning of the contract and sets the owner to the address which deploys it.
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    // this function actually makes the mapping and adds the amount funded to the previous amount (could be 0).
    function fund() public payable {
        uint256 minimumUSD = 1 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend at least 1 USD."
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    // this function returns eth price in gwei.
    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // this function returns eth price in usd.
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
