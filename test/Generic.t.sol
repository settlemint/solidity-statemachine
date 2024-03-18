// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/Generic.sol";
import "forge-std/console.sol";

contract GenericTest is Test {
    Generic generic;
    address admin = address(1);

    function setUp() public {
        generic = new Generic(1, "QmTestHash", "https://baseuri/");
        vm.label(address(generic), "GenericStateMachine");
    }

    function testSupportsERC165Interface() public {
        bytes4 ERC165InterfaceId = 0x01ffc9a7;
        assertTrue(
            generic.supportsInterface(ERC165InterfaceId),
            "Contract does not support ERC165 interface"
        );
    }

    function testEntityURI() public {
        string memory expectedURI = "https://baseuri/QmTestHash";
        string memory uri = generic.entityURI(1);
        assertEq(uri, expectedURI, "Entity URI does not match expected value");
    }

    function testEmptyBaseURIEntityURI() public {
        Generic generic2 = new Generic(3, "ipfshash", "");
        string memory uri = generic2.entityURI(3);
        assertEq(
            uri,
            "ipfshash",
            "Entity URI does not match expected value when baseURI is empty"
        );
    }

    function testInitialState() public {
        // Fetch the current state from the contract
        bytes32 currentState = generic.getCurrentState();

        // Define the expected initial state
        bytes32 expectedState = 0x0000000000000000000000000000000000000000000000000000000000000001;

        // Assert that the current state matches the expected initial state
        assertEq(currentState, expectedState, "Incorrect initial state");
    }

    function testRevertHistoryTransitionIfNoStateTransition() public {
        // Expecting the transaction to revert with the specified error message
        vm.expectRevert("Index out of bounds");

        // Attempt to retrieve the history at index 0
        generic.getHistory(0);
    }

    function testTransitionHistoryLength() public {
        // Fetch the initial history length
        uint256 initialHistoryLength = generic.getHistoryLength();
        // Assert that the initial history length is zero
        assertEq(
            initialHistoryLength,
            0,
            "Initial history length should be zero"
        );
    }

    function testTransitionHistory() public {
        // Fetch the state information for CHANGE_HERE_STATE_ONE
        bytes32 stateOne = 0x0000000000000000000000000000000000000000000000000000000000000001;

        // Get the state information
        (, , bytes32[] memory allowedRoles, , ) = generic.getState(stateOne);

        // Transition the state from CHANGE_HERE_STATE_ONE to CHANGE_HERE_STATE_TWO
        bytes32 newState = 0x0000000000000000000000000000000000000000000000000000000000000002;
        generic.transitionState(newState, allowedRoles[0]);

        // Fetch the history length
        uint256 historyLength = generic.getHistoryLength();
        assertEq(historyLength, 1, "Incorrect history length");

        // Fetch the history at index 0
        (bytes32 fromState, bytes32 toState, , ) = generic.getHistory(0);

        // Assert that the transition history contains the expected information
        assertEq(
            fromState,
            stateOne,
            "Incorrect from state in transition history"
        );
        assertEq(toState, newState, "Incorrect to state in transition history");
    }

    function testCurrentState() public {
        bytes32 currentState = generic.getCurrentState();
        assertEq(
            currentState,
            0x0000000000000000000000000000000000000000000000000000000000000001,
            "Current state should match the initial state"
        );
    }

    function testAllStates() public view {
        bytes32[] memory allStates = generic.getAllStates();
        bytes32[] memory expectedStates = new bytes32[](5);
        expectedStates[0] = bytes32(uint256(1));
        expectedStates[1] = bytes32(uint256(2));
        expectedStates[2] = bytes32(uint256(3));
        expectedStates[3] = bytes32(uint256(4));
        expectedStates[4] = bytes32(uint256(5));

        console.log("Actual states:");
        for (uint256 i = 0; i < allStates.length; i++) {
            console.logBytes32(allStates[i]);
        }

        console.log("Expected states:");
        for (uint256 i = 0; i < expectedStates.length; i++) {
            console.logBytes32(expectedStates[i]);
        }
        // assertEq(allStates, expectedStates, "The possible states are not correct");
    }

    //TO DO Complete rest of the tests + graph MW
}
