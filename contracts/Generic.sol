// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {StateMachineMetadata} from "./statemachine/extensions/StateMachineMetadata.sol";

/**
 *
 * @title Generic State machine implementation
 */

contract Generic is StateMachineMetadata {
    bytes32 public constant STATE_ONE =
        0x0000000000000000000000000000000000000000000000000000000000000001;
    bytes32 public constant STATE_TWO =
        0x0000000000000000000000000000000000000000000000000000000000000002;
    bytes32 public constant STATE_THREE =
        0x0000000000000000000000000000000000000000000000000000000000000003;
    bytes32 public constant STATE_FOUR =
        0x0000000000000000000000000000000000000000000000000000000000000004;
    bytes32 public constant STATE_FIVE =
        0x0000000000000000000000000000000000000000000000000000000000000005;

    bytes32 public constant ROLE_ADMIN =
        0x000000000000000000000000000000000000000000000000000000000000000a;
    bytes32 public constant ROLE_MANUFACTURER =
        0x000000000000000000000000000000000000000000000000000000000000000b;
    bytes32 public constant ROLE_ONE =
        0x000000000000000000000000000000000000000000000000000000000000000c;
    bytes32 public constant ROLE_TWO =
        0x000000000000000000000000000000000000000000000000000000000000000d;
    bytes32 public constant ROLE_THREE =
        0x000000000000000000000000000000000000000000000000000000000000000e;
    bytes32 public constant ROLE_FOUR =
        0x000000000000000000000000000000000000000000000000000000000000000f;

    bytes32[] public _roles;

    constructor(
        uint256 entityId,
        string memory ipfsHash,
        string memory baseURI
    ) {
        address adminAddress = msg.sender;
        _roles = [
            ROLE_ADMIN,
            ROLE_MANUFACTURER,
            ROLE_ONE,
            ROLE_TWO,
            ROLE_THREE,
            ROLE_FOUR
        ];
        _grantRole(DEFAULT_ADMIN_ROLE, adminAddress);
        setupStateMachine(adminAddress);
        _entityId = entityId;
        _baseURI = baseURI;
        _setEntityURI(_entityId, ipfsHash);
    }

    /**
     * @notice Returns all the roles for this contract
     * @return bytes32[] array of raw bytes representing the roles
     */
    function getRoles() public view returns (bytes32[] memory) {
        return _roles;
    }

    function setupStateMachine(address adminAddress) internal override {
        /**
         * @notice Abstract function from StateMachine
         * @dev create a state in the supplychain
         * @param NAME_STATE the name of the state
         */
        createState(STATE_ONE);
        createState(STATE_TWO);
        createState(STATE_THREE);
        createState(STATE_FOUR);
        createState(STATE_FIVE);

        // add properties
        // STATE_ONE
        addNextStateForState(STATE_ONE, STATE_TWO);
        addRoleForState(STATE_ONE, ROLE_ADMIN, adminAddress);
        addRoleForState(STATE_ONE, ROLE_ONE, adminAddress);
        addRoleForState(STATE_ONE, ROLE_MANUFACTURER, adminAddress);

        // STATE_TWO
        addNextStateForState(STATE_TWO, STATE_THREE);
        addRoleForState(STATE_TWO, ROLE_ADMIN, adminAddress);
        addRoleForState(STATE_TWO, ROLE_TWO, adminAddress);

        // STATE_THREE
        addNextStateForState(STATE_THREE, STATE_FOUR);
        addRoleForState(STATE_THREE, ROLE_ADMIN, adminAddress);
        addRoleForState(STATE_THREE, ROLE_THREE, adminAddress);

        // STATE_FOUR
        addNextStateForState(STATE_FOUR, STATE_FIVE);
        addRoleForState(STATE_FOUR, ROLE_ADMIN, adminAddress);
        addRoleForState(STATE_FOUR, ROLE_FOUR, adminAddress);

        setInitialState(STATE_ONE);
    }
}
