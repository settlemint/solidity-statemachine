// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/Generic.sol";
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
        bytes32 currentState = generic.getCurrentState();
        bytes32 expectedState = 0x0000000000000000000000000000000000000000000000000000000000000001;
        assertEq(currentState, expectedState, "Incorrect initial state");
    }

    function testRevertHistoryTransitionIfNoStateTransition() public {
        vm.expectRevert("Index out of bounds");
        generic.getHistory(0);
    }

    function testTransitionHistoryLength() public {
        uint256 initialHistoryLength = generic.getHistoryLength();
        assertEq(
            initialHistoryLength,
            0,
            "Initial history length should be zero"
        );
    }

    function testTransitionHistory() public {
        bytes32 stateOne = 0x0000000000000000000000000000000000000000000000000000000000000001;
        bytes32 newState = 0x0000000000000000000000000000000000000000000000000000000000000002;
        (, , bytes32[] memory allowedRoles, , ) = generic.getState(stateOne);
        generic.transitionState(newState, allowedRoles[0]);
        uint256 historyLength = generic.getHistoryLength();
        assertEq(historyLength, 1, "Incorrect history length");
        (bytes32 fromState, bytes32 toState, , ) = generic.getHistory(0);
        assertEq(fromState, stateOne, "Incorrect from state in transition history");
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

    function assertEq(bytes32[] memory a, bytes32[] memory b, string memory message) internal {
        require(a.length == b.length, "Array lengths do not match.");
        for (uint i = 0; i < a.length; i++) {
            require(a[i] == b[i], message);
        }
    }

    function testAllStates() public {
        bytes32[] memory allStates = generic.getAllStates();
        bytes32[] memory expectedStates = new bytes32[](5);
        expectedStates[0] = bytes32(uint256(1));
        expectedStates[1] = bytes32(uint256(2));
        expectedStates[2] = bytes32(uint256(3));
        expectedStates[3] = bytes32(uint256(4));
        expectedStates[4] = bytes32(uint256(5));

        assertEq(allStates, expectedStates, "The possible states are not correct");
    }
}
