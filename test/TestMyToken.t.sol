// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";

contract TestMyToken is Test {

    MyToken public myToken;
    DeployMyToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {

        deployer = new DeployMyToken();
        myToken = deployer.run();

        console.log("Deployer Address: ", address(deployer));
        console.log("msg.sender Address: ", msg.sender);

        vm.prank(address(msg.sender));
        myToken.transfer(bob, STARTING_BALANCE);

    }


    function testBobBalance() public {
        assertEq(STARTING_BALANCE, myToken.balanceOf(bob));
    }

    function testAllowance() public {
        uint256 initialAllowance = 1000;

        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob),STARTING_BALANCE - transferAmount);
    }


    function testTotalSupply() public {

        uint256 initialSupply = 1000 ether;
        assertEq(myToken.totalSupply(), initialSupply);
    }


    function testTransferInsufficientBalance() public {
        uint256 transferAmount = STARTING_BALANCE + 1;

        vm.prank(bob);

        vm.expectRevert();
        myToken.transfer(alice, transferAmount);
    }

    function testTransferToZeroAddress() public {
        vm.prank(bob);
        vm.expectRevert();
        myToken.transfer(address(0), 10 ether);
    }


    function testTransferFromZeroAddress() public {
        vm.prank(alice);
        vm.expectRevert();
        myToken.transferFrom(address(0), alice, 10 ether);
    }


    function testApproveZeroAddress() public {

        vm.prank(bob);
        vm.expectRevert();
        myToken.approve(address(0), 10 ether);

    }

    function testApproveOverwrite() public {
        vm.prank(bob);
        myToken.approve(alice, 100 ether);
        assertEq(myToken.allowance(bob, alice), 100 ether);

        vm.prank(bob);
        myToken.approve(alice, 50 ether);
        assertEq(myToken.allowance(bob, alice), 50 ether);
    }



}