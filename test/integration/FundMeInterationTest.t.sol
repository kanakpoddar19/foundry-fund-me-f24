// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMeScript} from "script/DeployFundMe.s.sol";
import {fundFundMe, withdrawFundMe} from "script/Interactions.s.sol";

contract FundMeInteractionTests is Test {
    // Test for 2 major functions
    // fund()
    // withdraw()

    FundMe contract1;

    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.01 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // deploying a new "FundMe" smart contract
        // returning it for usage
        // providing STARTING_BALANCE to a "fake" account for performing txs

        DeployFundMeScript deployScriptObj = new DeployFundMeScript();
        contract1 = deployScriptObj.run();

        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFund() public {
        // checking whether fund() of interaction script works fine
        // whether funding happens through script

        fundFundMe fundCallingScript = new fundFundMe();
        fundCallingScript.fund(address(contract1));

        assertEq(address(contract1).balance, SEND_VALUE);
    }

    function testOwnerCanWithdraw() public {
        // checking whether withdraw() of the interaction script works fine or not
        // whether withdraw happens through script

        withdrawFundMe withdrawCallingScript = new withdrawFundMe();
        withdrawCallingScript.withdraw(address(contract1));

        assertEq(address(contract1).balance, 0);
    }

    /* COMBINED (test)

    function testFundMeInterations() public {
        fundFundMe fundCallingScript = new fundFundMe();
        fundCallingScript.fund(address(contract1));

        withdrawFundMe withdrawCallingScript = new withdrawFundMe();
        withdrawCallingScript.withdraw(address(contract1));

        assertEq(address(contract1).balance, 0);
    }
    */
}
