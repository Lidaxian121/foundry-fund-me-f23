// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Fundfundme, Withdrawfundme} from "../../script/Interaction.s.sol";

contract InteractionTest is Test {
    FundMe fundme;

    uint256 constant SEND_VALUE = 1e18;

    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER, SEND_VALUE);
    }

    function testFundAndWithdarw() public {
        Fundfundme fundfundme = new Fundfundme();
        fundfundme.fundfundme(address(fundme));

        Withdrawfundme withdrawfundme = new Withdrawfundme();
        withdrawfundme.withdrawfundme(address(fundme));
        assertEq(address(fundme).balance, 0);
    }
}
