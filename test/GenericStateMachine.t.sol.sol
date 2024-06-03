// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/statemachine/extensions/GenericStateMachine.sol";
import "forge-std/console.sol";

contract GenericStateMachineTest is Test {
    GenericStateMachine stateMachine;
    address admin = address(1);
    bytes32 constant ROLE_ADMIN = "ROLE_ADMIN";
    bytes32 constant ROLE_MANUFACTURER = "ROLE_MANUFACTURER";
    bytes32 constant ROLE_ONE = "CHANGE_HERE_ROLE_ONE";
    bytes32 constant ROLE_TWO = "CHANGE_HERE_ROLE_TWO";
    bytes32 constant ROLE_THREE = "CHANGE_HERE_ROLE_THREE";
    bytes32 constant ROLE_FOUR = "CHANGE_HERE_ROLE_FOUR";

    event StateTransitioned(bytes32 indexed fromState, bytes32 indexed toState, bytes32 role);

    function setUp() public {
        stateMachine = new GenericStateMachine(1, "QmTestHash", "https://baseuri/");
        vm.label(address(stateMachine), "GenericStateMachine");
    }

    function testSupportsERC165Interface() public {
        bytes4 ERC165InterfaceId = 0x01ffc9a7;
        assertTrue(
            stateMachine.supportsInterface(ERC165InterfaceId),
            "Contract does not support ERC165 interface"
        );
    }

    function testEntityURI() public {
        string memory expectedURI = "https://baseuri/QmTestHash";
        string memory uri = stateMachine.entityURI(1);
        assertEq(uri, expectedURI, "Entity URI does not match expected value");
    }

    function testEmptyBaseURIEntityURI() public {
        GenericStateMachine stateMachine2 = new GenericStateMachine(3, "ipfshash", "");
        string memory uri = stateMachine2.entityURI(3);
        assertEq(
            uri,
            "ipfshash",
            "Entity URI does not match expected value when baseURI is empty"
        );
    }

    function testInitialState() public {
        bytes32 currentState = stateMachine.getCurrentState();
        bytes32 expectedState = "CHANGE_HERE_STATE_ONE";
        assertEq(currentState, expectedState, "Incorrect initial state");
    }

    function testRevertHistoryTransitionIfNoStateTransition() public {
        vm.expectRevert("Index out of bounds");
        stateMachine.getHistory(0);
    }

    function testTransitionHistoryLength() public {
        uint256 initialHistoryLength = stateMachine.getHistoryLength();
        assertEq(
            initialHistoryLength,
            0,
            "Initial history length should be zero"
        );
    }

    function testTransitionHistory() public {
        bytes32 stateOne = "CHANGE_HERE_STATE_ONE";
        bytes32 newState = "CHANGE_HERE_STATE_TWO";
        (, , bytes32[] memory allowedRoles, , ) = stateMachine.getState(stateOne);
        vm.prank(admin);
        stateMachine.transitionState(newState, allowedRoles[0]);
        uint256 historyLength = stateMachine.getHistoryLength();
        assertEq(historyLength, 1, "Incorrect history length");
        (bytes32 fromState, bytes32 toState, , ) = stateMachine.getHistory(0);
        assertEq(fromState, stateOne, "Incorrect from state in transition history");
        assertEq(toState, newState, "Incorrect to state in transition history");
    }

    function testCurrentState() public {
        bytes32 currentState = stateMachine.getCurrentState();
        assertEq(
            currentState,
            "CHANGE_HERE_STATE_ONE",
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
        bytes32[] memory allStates = stateMachine.getAllStates();
        bytes32[] memory expectedStates = new bytes32[](5);
        expectedStates[0] = "CHANGE_HERE_STATE_ONE";
        expectedStates[1] = "CHANGE_HERE_STATE_TWO";
        expectedStates[2] = "CHANGE_HERE_STATE_THREE";
        expectedStates[3] = "CHANGE_HERE_STATE_FOUR";
        expectedStates[4] = "CHANGE_HERE_STATE_FIVE";

        assertEq(allStates, expectedStates, "The possible states are not correct");
    }

    function testRoleAssignmentAndEnforcement() public {
        bytes32 stateOne = "CHANGE_HERE_STATE_ONE";
        address newAdmin = address(2);
        
        // Grant ROLE_ADMIN to newAdmin
        vm.prank(admin);
        stateMachine.grantRole(ROLE_ADMIN, newAdmin);

        // Test if newAdmin can transition state
        vm.prank(newAdmin);
        stateMachine.transitionState(stateOne, ROLE_ADMIN);
        bytes32 currentState = stateMachine.getCurrentState();
        assertEq(currentState, stateOne, "State transition by new admin failed");
    }

    function testUnauthorizedStateTransition() public {
        bytes32 newState = "CHANGE_HERE_STATE_TWO";
        vm.prank(address(2)); // An unauthorized address
        vm.expectRevert("Unauthorized access");
        stateMachine.transitionState(newState, ROLE_ADMIN);
    }

    function testRemoveRole() public {
        address newAdmin = address(2);
        vm.prank(admin);
        stateMachine.grantRole(ROLE_ADMIN, newAdmin);

        // Remove ROLE_ADMIN from newAdmin
        vm.prank(admin);
        stateMachine.revokeRole(ROLE_ADMIN, newAdmin);
        
        // Test if newAdmin is still able to transition state
        bytes32 newState = "CHANGE_HERE_STATE_TWO";
        vm.prank(newAdmin);
        vm.expectRevert("Unauthorized access");
        stateMachine.transitionState(newState, ROLE_ADMIN);
    }

    function testEventEmissionOnStateTransition() public {
        bytes32 newState = "CHANGE_HERE_STATE_TWO";
        (, , bytes32[] memory allowedRoles, , ) = stateMachine.getState(newState);

        vm.expectEmit(true, true, true, true);
        emit StateTransitioned("CHANGE_HERE_STATE_ONE", newState, allowedRoles[0]);

        vm.prank(admin);
        stateMachine.transitionState(newState, allowedRoles[0]);
    }

    function testTransitionHistoryAfterMultipleTransitions() public {
        bytes32 stateTwo = "CHANGE_HERE_STATE_TWO";
        bytes32 stateThree = "CHANGE_HERE_STATE_THREE";
        (, , bytes32[] memory allowedRoles, , ) = stateMachine.getState(stateTwo);
        
        // First Transition
        vm.prank(admin);
        stateMachine.transitionState(stateTwo, allowedRoles[0]);
        // Second Transition
        vm.prank(admin);
        stateMachine.transitionState(stateThree, allowedRoles[0]);
        
        // Check History Length
        uint256 historyLength = stateMachine.getHistoryLength();
        assertEq(historyLength, 2, "Incorrect history length after multiple transitions");

        // Check First Transition History
        (bytes32 fromState1, bytes32 toState1, , ) = stateMachine.getHistory(0);
        assertEq(fromState1, "CHANGE_HERE_STATE_ONE", "Incorrect from state in first transition history");
        assertEq(toState1, stateTwo, "Incorrect to state in first transition history");

        // Check Second Transition History
        (bytes32 fromState2, bytes32 toState2, , ) = stateMachine.getHistory(1);
        assertEq(fromState2, stateTwo, "Incorrect from state in second transition history");
        assertEq(toState2, stateThree, "Incorrect to state in second transition history");
    }

    function testEmptyRoleArray() public {
        // Instead of calling createState directly, we'll test if no roles are assigned to a known state
        bytes32 stateWithoutRoles = "CHANGE_HERE_STATE_SIX";
        // Test setup must ensure that this state is created without roles if it is not directly possible through tests
        // This is more of a theoretical case for the contract as there's no direct public exposure for such a state.
        
        // Ensure no roles are assigned
        (, , bytes32[] memory roles, , ) = stateMachine.getState(stateWithoutRoles);
        assertEq(roles.length, 0, "New state should have no roles assigned");
    }
}
