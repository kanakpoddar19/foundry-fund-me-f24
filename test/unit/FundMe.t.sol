// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMeScript} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe contract1;

    address USER = makeAddr("USER");

    function setUp() external {
        /* Hard-coding Pricefeed address
        contract1 = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        */

        DeployFundMeScript deployScript = new DeployFundMeScript(); // Testing + Deployment environment is same now
        contract1 = deployScript.run();

        vm.deal(USER, 10e18);
    }

    function testMinimumUSDIsFive() public view {
        assertEq(contract1.MINIMUM_USD(), 5e18); // MINIMUM_USD() : associated "view" fn
    }

    function testOwner() public view {
        console.log(contract1.getOwnerAddress()); // the one who is deploying contract1 (FundMeTest contract)
        console.log(msg.sender); // whoever that is calling the FundMeTest (Us)
        console.log(address(this)); // referring to this very contract (FundMeTest contract)

        //  assertEq(contract1.i_owner(), address(this)); (OLD)

        // us --calling--> FundMeTest --deploys--> contract1 (OLD)

        assertEq(contract1.getOwnerAddress(), msg.sender);

        /*

         DeployFundMeScript --deploys--> contract1

         In DeployFundMeScript : 
         vm.startBroadcast() == us (msg.sender)
         */
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = contract1.getVersion();

        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        contract1.fund(); // sending 0 value with calling fund fn

        // sending some value
        // contract1.fund{value: xyz}();
    }

    function testMappingBeingUpdatedByFund() public {
        vm.prank(USER);
        contract1.fund{value: 10e18}(); // value >= 5 USD

        // uint256 amount = contract1.getAddressToAmountFunded(address(this));

        uint256 amount = contract1.getAddressToAmountFunded(USER);

        assertEq(amount, 10e18);
    }

    function testFunderListBeingUpdatedByFund() public {
        vm.prank(USER);
        contract1.fund{value: 10e18}(); // value >= 5 USD

        address funder = contract1.getFunderAddress(0);

        // assertEq(funder, address(this));
        assertEq(funder, USER);
    }

    modifier fundThis() {
        vm.prank(USER);
        contract1.fund{value: 10e18}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public fundThis {
        // vm.prank(USER);
        // contract1.fund{value: 10e18}();

        vm.expectRevert();
        vm.prank(USER); // Should revert as USER isn't the owner
        contract1.withdraw(); // USER calling withdraw() should revert and throw "FundMe_NotOwner()" error
    }

    function testWithdrawWithSingleFunder() public fundThis {
        // Arrange
        uint256 startingOwnerBalance = contract1.getOwnerAddress().balance;
        uint256 startingContractBalance = address(contract1).balance;

        // Act
        vm.prank(contract1.getOwnerAddress());
        contract1.withdraw();

        // Assert
        uint256 endingOwnerBalance = contract1.getOwnerAddress().balance;
        uint256 endingContractBalance = address(contract1).balance;

        assertEq(endingContractBalance, 0);
        assertEq(
            startingContractBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public {
        // Arrange
        uint160 totalFunders = 10;

        for (uint160 funder = 1; funder <= totalFunders; funder++) {
            /*
            // creating address for a funder
            address funderAddress = address(funder);

            // providng that address with money to fund
            vm.deal(funderAddress, 10e18);

            // funding "contract1"
            vm.prank(funderAddress);
            contract1.fund{value: 10e18}();
            */

            // or
            hoax(address(funder), 10e18);
            contract1.fund{value: 10e18}();
        }

        uint256 startingOwnerBalance = contract1.getOwnerAddress().balance;
        uint256 startingContractBalance = address(contract1).balance;

        // Act
        vm.prank(contract1.getOwnerAddress());
        contract1.withdraw();

        // Assert
        uint256 endingOwnerBalance = contract1.getOwnerAddress().balance;
        uint256 endingContractBalance = address(contract1).balance;

        assertEq(endingContractBalance, 0);
        assertEq(
            startingContractBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
}
