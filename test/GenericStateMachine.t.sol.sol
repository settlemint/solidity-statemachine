// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/statemachine/extensions/GenericStateMachine.sol";

contract GenericStateMachineTest is Test {
    GenericStateMachine stateMachine;
    address adminAddress;
    address unauthorizedAddress;

    function setUp() public {
        adminAddress = address(this);
        unauthorizedAddress = address(0x1234);
        stateMachine = new GenericStateMachine(1, "ipfsHash", "baseURI");

        // Assign roles for testing transitions
        vm.prank(adminAddress);
        stateMachine.grantRole(stateMachine.ROLE_ADMIN(), adminAddress);
        stateMachine.grantRole(stateMachine.ROLE_ONE(), adminAddress);
        stateMachine.grantRole(stateMachine.ROLE_TWO(), adminAddress);
        stateMachine.grantRole(stateMachine.ROLE_THREE(), adminAddress);
        stateMachine.grantRole(stateMachine.ROLE_FOUR(), adminAddress);

        // Ensure unauthorizedAddress does not have any roles
        revokeAllRoles(unauthorizedAddress);
    }

    function revokeAllRoles(address addr) internal {
        stateMachine.revokeRole(stateMachine.ROLE_ADMIN(), addr);
        stateMachine.revokeRole(stateMachine.ROLE_ONE(), addr);
        stateMachine.revokeRole(stateMachine.ROLE_TWO(), addr);
        stateMachine.revokeRole(stateMachine.ROLE_THREE(), addr);
        stateMachine.revokeRole(stateMachine.ROLE_FOUR(), addr);
    }

    function testAllStates() public {
        bytes32[] memory states = stateMachine.getAllStates();
        assertEq(states.length, 5, "There should be 5 states");
        assertEq(states[0], stateMachine.STATE_ONE(), "First state should be STATE_ONE");
        assertEq(states[1], stateMachine.STATE_TWO(), "Second state should be STATE_TWO");
        assertEq(states[2], stateMachine.STATE_THREE(), "Third state should be STATE_THREE");
        assertEq(states[3], stateMachine.STATE_FOUR(), "Fourth state should be STATE_FOUR");
        assertEq(states[4], stateMachine.STATE_FIVE(), "Fifth state should be STATE_FIVE");
    }

    function testCurrentState() public {
        bytes32 initialState = stateMachine.getCurrentState();
        assertEq(initialState, stateMachine.STATE_ONE(), "Initial state should be STATE_ONE");
    }

    function testTransition() public {
        // Transition to STATE_TWO
        vm.prank(adminAddress);
        stateMachine.transitionState(stateMachine.STATE_TWO(), stateMachine.ROLE_ONE());
        bytes32 currentState = stateMachine.getCurrentState();
        assertEq(currentState, stateMachine.STATE_TWO(), "Current state should be STATE_TWO");
    }

    function testRoles() public {
        bytes32[] memory roles = stateMachine.getRoles();
        assertEq(roles.length, 6, "There should be 6 roles");
        assertEq(roles[0], stateMachine.ROLE_ADMIN(), "First role should be ROLE_ADMIN");
        assertEq(roles[1], stateMachine.ROLE_MANUFACTURER(), "Second role should be ROLE_MANUFACTURER");
        assertEq(roles[2], stateMachine.ROLE_ONE(), "Third role should be ROLE_ONE");
        assertEq(roles[3], stateMachine.ROLE_TWO(), "Fourth role should be ROLE_TWO");
        assertEq(roles[4], stateMachine.ROLE_THREE(), "Fifth role should be ROLE_THREE");
        assertEq(roles[5], stateMachine.ROLE_FOUR(), "Sixth role should be ROLE_FOUR");
    }

    function testGetState() public {
        (bytes32 stateName, bytes32[] memory nextStates, bytes32[] memory allowedRoles, bytes4[] memory allowedFunctions, bytes4 preFunction) = stateMachine.getState(stateMachine.STATE_ONE());
        assertEq(stateName, stateMachine.STATE_ONE(), "State name does not match");
        assertEq(nextStates.length, 1, "Next states length does not match");
        assertEq(nextStates[0], stateMachine.STATE_TWO(), "Next state does not match");
        assertEq(allowedRoles.length, 3, "Allowed roles length does not match");
        assertEq(allowedRoles[0], stateMachine.ROLE_ADMIN(), "Allowed role does not match");
        assertEq(allowedRoles[1], stateMachine.ROLE_ONE(), "Allowed role does not match");
        assertEq(allowedRoles[2], stateMachine.ROLE_MANUFACTURER(), "Allowed role does not match");
    }

    function testCheckAllTransitionCriteria() public {
        vm.prank(adminAddress);
        stateMachine.transitionState(stateMachine.STATE_TWO(), stateMachine.ROLE_ONE());
        bytes32 currentState = stateMachine.getCurrentState();
        assertEq(currentState, stateMachine.STATE_TWO(), "Current state should be STATE_TWO");
    }

    function testCheckAllowedRoles() public {
        bool hasRoleAdmin = stateMachine.checkAllowedRoles(stateMachine.ROLE_ADMIN());
        assertTrue(hasRoleAdmin, "Admin should have ROLE_ADMIN");

        bool hasRoleManufacturer = stateMachine.checkAllowedRoles(stateMachine.ROLE_MANUFACTURER());
        assertFalse(hasRoleManufacturer, "Admin should not have ROLE_MANUFACTURER");
    }

    function testAddCallbackForState() public {
        // Test callback through state transition
        vm.prank(adminAddress);
        stateMachine.transitionState(stateMachine.STATE_TWO(), stateMachine.ROLE_ONE());
        // The callback logic can be verified if there are specific side effects or state changes
    }
}
