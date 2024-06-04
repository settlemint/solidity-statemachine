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

 
    function testCurrentState() public {
        bytes32 currentState = generic.getCurrentState();
        assertEq(
            currentState,
            0x0000000000000000000000000000000000000000000000000000000000000001,
            "Current state should match the initial state"
        );
    }

    function assertEq(bytes32[] memory a, bytes32[] memory b, string memory message) internal  override pure {
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

    // function testSetEntityURI() public {
    //     string memory newURI = "newIPFSHash";
    //     vm.prank(admin);
    //     generic._setEntityURI(1, newURI);
    //     string memory uri = generic.entityURI(1);
    //     assertEq(uri, string(abi.encodePacked("https://baseuri/", newURI)), "Entity URI does not match expected value after update");
    // }

    function testGrantRoleToAccount() public {
        address newAccount = address(2);
        vm.prank(admin);
        generic.grantRoleToAccount(generic.ROLE_ONE(), newAccount);
        assertTrue(generic.hasRole(generic.ROLE_ONE(), newAccount), "New account does not have the expected role");
    }

    function testAddRoleForState() public {
        vm.prank(admin);
        generic.addRoleForState(generic.STATE_ONE(), generic.ROLE_TWO(), admin);
        (, , bytes32[] memory allowedRoles, , ) = generic.getState(generic.STATE_ONE());
        assertTrue(containsRole(allowedRoles, generic.ROLE_TWO()), "Role not added to the state");
    }

    function containsRole(bytes32[] memory roles, bytes32 role) internal pure returns (bool) {
        for (uint i = 0; i < roles.length; i++) {
            if (roles[i] == role) {
                return true;
            }
        }
        return false;
    }

    function testAddAllowedFunctionForState() public {
        bytes4 functionSelector = this.testAddAllowedFunctionForState.selector;
        vm.prank(admin);
        generic.addAllowedFunctionForState(generic.STATE_ONE(), functionSelector);
        (,,, bytes4[] memory allowedFunctions,) = generic.getState(generic.STATE_ONE());
        assertTrue(containsFunction(allowedFunctions, functionSelector), "Function not added to the state");
    }

    function containsFunction(bytes4[] memory functions, bytes4 fn) internal pure returns (bool) {
        for (uint i = 0; i < functions.length; i++) {
            if (functions[i] == fn) {
                return true;
            }
        }
        return false;
    }

    function testAddNextStateForState() public {
        vm.prank(admin);
        generic.addNextStateForState(generic.STATE_ONE(), generic.STATE_THREE());
        (, bytes32[] memory nextStates,,,) = generic.getState(generic.STATE_ONE());
        assertTrue(containsState(nextStates, generic.STATE_THREE()), "Next state not added to the state");
    }

    function containsState(bytes32[] memory states, bytes32 state) internal pure returns (bool) {
        for (uint i = 0; i < states.length; i++) {
            if (states[i] == state) {
                return true;
            }
        }
        return false;
    }
}
