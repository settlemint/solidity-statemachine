// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {StateMachineMetadata} from "./StateMachineMetadata.sol";

/**
 * Generic
 *
 * A generic package exists of
 *  - a description of the generic state machine
 *
 * @title Generic State machine implementation
 */

contract GenericStateMachine is StateMachineMetadata {
    bytes32 public constant STATE_ONE = "CHANGE_HERE_STATE_ONE";
    bytes32 public constant STATE_TWO = "CHANGE_HERE_STATE_TWO";
    bytes32 public constant STATE_THREE = "CHANGE_HERE_STATE_THREE";
    bytes32 public constant STATE_FOUR = "CHANGE_HERE_STATE_FOUR";
    bytes32 public constant STATE_FIVE = "CHANGE_HERE_STATE_FIVE";

    bytes32 public constant ROLE_ADMIN = "ROLE_ADMIN";
    bytes32 public constant ROLE_MANUFACTURER = "ROLE_MANUFACTURER";
    bytes32 public constant ROLE_ONE = "CHANGE_HERE_ROLE_ONE";
    bytes32 public constant ROLE_TWO = "CHANGE_HERE_ROLE_TWO";
    bytes32 public constant ROLE_THREE = "CHANGE_HERE_ROLE_THREE";
    bytes32 public constant ROLE_FOUR = "CHANGE_HERE_ROLE_FOUR";

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

    function setupStateMachine(address adminAddress) internal virtual override {
        super.setupStateMachine(adminAddress);
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
