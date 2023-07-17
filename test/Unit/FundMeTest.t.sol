// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;

    uint256 constant SEND_VALUE = 1e18;

    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER, SEND_VALUE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundme.getOwner(), msg.sender);
    }

    // 1. Unit
    // 2. Integration
    // 3. Forked
    // 4. Staging
    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testFundSuccessWithEnoughETH() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();

        uint256 ethAmount = fundme.getAddressToAmountFunded(USER);
        assertEq(ethAmount, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();

        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithdrawSingleFunder() public funded {
        // Arrange
        uint256 startFundmeBalance = address(fundme).balance;
        uint256 startOwnerBalance = fundme.getOwner().balance;

        // Act
        vm.prank(fundme.getOwner());
        fundme.withdraw();

        // Assert
        uint256 endFundmeBalance = address(fundme).balance;
        uint256 endOwnerBalance = fundme.getOwner().balance;
        assertEq(endFundmeBalance, 0);
        assertEq(endOwnerBalance, startOwnerBalance + startFundmeBalance);
    }

    function testWithdrawMultipleFunder() public {
        uint160 numberOfFunders = 10;
        uint160 startIndex = 1;
        for (uint160 i = startIndex; i <= numberOfFunders; i++) {
            address funder = address(i);
            hoax(funder, SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        // Arrange
        uint256 startFundmeBalance = address(fundme).balance;
        uint256 startOwnerBalance = fundme.getOwner().balance;

        // Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endFundmeBalance = address(fundme).balance;
        uint256 endOwnerBalance = fundme.getOwner().balance;
        assertEq(endFundmeBalance, 0);
        assertEq(endOwnerBalance, startOwnerBalance + startFundmeBalance);
    }
}
