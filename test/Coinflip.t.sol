// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {Coinflip} from "../src/Coinflip.sol";

error SeedTooShort();

contract CoinflipTest is Test {
    Coinflip public game;

    function setUp() public {
        game = new Coinflip();
    }

    ///////////////////////////////////////////////
    //// Check that the owner is the deployer. ////
    //// The deployer is the test contract!    ////
    ///////////////////////////////////////////////
    
    function test_DeployerIsOwner() public {
        assertEq(game.owner(), address(this));
    }

    /////////////////////////////////////////////////////
    ////  User magically guesses correctly the flips ////
    ////           [1,0,0,0,1,1,1,1,0,1]             ////
    /////////////////////////////////////////////////////

    function test_UserCorrect() public {
        assertEq(game.userInput([1,0,0,0,1,1,1,1,0,1]), true);
    }

    //////////////////////////////////
    ////   User guesses wrongly   ////
    //////////////////////////////////

    function test_UserIncorrect() public {
        assertFalse(game.userInput([1,0,1,0,0,1,0,1,0,1]));
    }

    ////////////////////////////////////////////////////////////
    //// Assert that the initial seed is the hardcoded seed ////
    ////////////////////////////////////////////////////////////

    function test_CheckInitSeed() public {
        assertEq(game.seed(), "It is a good practice to rotate seeds often in gambling");
    }

    //////////////////////////////////////
    ////    Owner can rotate seed     ////
    //////////////////////////////////////

    function test_OwnerSeedRotation() public {
        string memory newSeed = "This is a long and new seed";
        game.seedRotation(newSeed);
        console2.log(bytes(game.seed()).length);
        assertEq(game.seed(), newSeed);
    }

    ////////////////////////////////////
    ////    Seed too short error    ////
    ////////////////////////////////////

    function test_RevertWhen_SeedTooShort() public {
        string memory newSeed = "ShortSeed";
        vm.expectRevert(SeedTooShort.selector);
        game.seedRotation(newSeed);
    }

    ////////////////////////////////////////////////
    ////        Test seed effectiveness         ////
    ////////////////////////////////////////////////

    function test_SeedChange() public {

        uint8[10] memory originalSeedResult = game.getFlips();

        string memory newSeed = "Good seeds alter computed flips drastically to prevent brute force guessing";
        game.seedRotation(newSeed);
        uint8[10] memory newSeedResult = game.getFlips();

        uint changed = 0;

        for (uint i = 0; i < 10; i++){
            if(originalSeedResult[i] != newSeedResult[1]){
                changed++;
            }
        }

        console2.logUint(changed);
        // We hope that the degree of change is not zero
        assertFalse(changed == 0);
    }
}