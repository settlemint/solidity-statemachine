import { assert, expect } from 'chai';
import { ethers } from 'hardhat';
import { Generic } from '../typechain-types/src/Generic';


describe('StateMachine', async () => {
  let stateMachine: Generic;

  beforeEach(async () => {
    const [userOne, userTwo] = await ethers.getSigners();
    const stateMachineFactory = await ethers.getContractFactory('Generic', userOne);
    stateMachine = (await stateMachineFactory.deploy(1, "ipfshash", "baseurl")) as unknown as Generic;
  });

  it('supports ERC165 interface', async () => {
    const ERC165InterfaceId = '0x01ffc9a7';
    expect(await stateMachine.supportsInterface(ERC165InterfaceId)).to.be.true;
  });
  
  it('should be able to get the transition history and history length', async () => {
    const stateInfo = await stateMachine.getState(ethers.encodeBytes32String('CHANGE_HERE_STATE_ONE'));
    const allowedRoles = stateInfo[2];

    await stateMachine.transitionState(ethers.encodeBytes32String('CHANGE_HERE_STATE_TWO'), allowedRoles[0]);
    const historyLength = await stateMachine.getHistoryLength();
    expect(historyLength).to.equal(1);

    const historyAtIndex = await stateMachine.getHistory(0);
    expect(historyAtIndex[0]).to.equal(ethers.encodeBytes32String('CHANGE_HERE_STATE_ONE'));
    expect(historyAtIndex[1]).to.equal(ethers.encodeBytes32String('CHANGE_HERE_STATE_TWO'));
  });


//   it('transition history should be equal to zero if no state transition', async () => {
//     const historyLength = await stateMachine.getHistoryLength();
//     expect(historyLength).to.equal(0);
//   });
//   it('should revert history transition if there is no transition state', async () => {
//     await expect(stateMachine.getHistory(0)).to.be.reverted;
//   });
//   it('should return current state', async () => {
//     const currentState = await stateMachine.getCurrentState();
//     expect(ethers.utils.parseBytes32String(currentState)).to.equal('CHANGE_HERE_STATE_ONE');
//   });
//   it('should return all states', async () => {
//     const allStates = await stateMachine.getAllStates();
//     assert.sameMembers(
//       [
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE')}`,
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_STATE_TWO')}`,
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_STATE_THREE')}`,
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_STATE_FOUR')}`,
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_STATE_FIVE')}`,
//       ],
//       allStates,
//       'The possible states are not correct'
//     );
//   });
//   it('should return next state for initial state', async () => {
//     const nextStates = await stateMachine.getNextStates();
//     assert.sameMembers(
//       [`${ethers.utils.formatBytes32String('CHANGE_HERE_STATE_TWO')}`],
//       nextStates,
//       'The next state for the initial state is not correct'
//     );
//   });
//   it('should return empty array for the state without next state', async () => {
//     const stateInfo = await stateMachine.getState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_FOUR'));
//     const allowedRoles = stateInfo[2];
//     await stateMachine.transitionState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_TWO'), allowedRoles[0]);
//     await stateMachine.transitionState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_THREE'), allowedRoles[0]);
//     await stateMachine.transitionState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_FOUR'), allowedRoles[0]);
//     await stateMachine.transitionState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_FIVE'), allowedRoles[0]);
//     const nextState = await stateMachine.getNextStates();
//     assert.sameMembers([], nextState, `The next state is not correct`);
//   });
//   it('should return name for current state', async () => {
//     const stateInfo = await stateMachine.getState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE'));
//     const name = stateInfo[0];
//     expect(name).to.equal(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE'));
//   });
//   it('should return next state for current state', async () => {
//     const stateInfo = await stateMachine.getState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE'));
//     const nextState = stateInfo[1];
//     assert.sameMembers(
//       [`${ethers.utils.formatBytes32String('CHANGE_HERE_STATE_TWO')}`],
//       nextState,
//       'Next state is not correct'
//     );
//   });
//   it('should return all allowed roles for current state', async () => {
//     const stateInfo = await stateMachine.getState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE'));
//     const allowedRoles = stateInfo[2];
//     assert.sameMembers(
//       [
//         `${ethers.utils.formatBytes32String('ROLE_ADMIN')}`,
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_ROLE_ONE')}`,
//         `${ethers.utils.formatBytes32String('ROLE_MANUFACTURER')}`,
//       ],
//       allowedRoles,
//       'Roles are not correct'
//     );
//   });
//   it('should be able to add next state for current state', async () => {
//     const currentState = await stateMachine.getCurrentState();
//     await stateMachine.addNextStateForState(currentState, ethers.utils.formatBytes32String('CHANGE_HERE_STATE_THREE'));
//     const stateInfo = await stateMachine.getState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE'));
//     const nextStates = stateInfo[1];
//     expect(nextStates[1]).to.equal(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_THREE'));
//   });
//   it('should be possible to transition states', async () => {
//     const stateInfo = await stateMachine.getState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_TWO'));
//     const allowedRoles = stateInfo[2];
//     const currentState = await stateMachine.getCurrentState();
//     assert(ethers.utils.parseBytes32String(currentState), 'CHANGE_HERE_STATE_ONE');
//     await stateMachine.transitionState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_TWO'), allowedRoles[0]);

//     const changedState = await stateMachine.getCurrentState();
//     assert.equal(
//       ethers.utils.parseBytes32String(changedState),
//       'CHANGE_HERE_STATE_TWO',
//       'the state is not set correctly'
//     );
//   });
//   it('should not be possible to transition to the state that does not exist for the current state', async () => {
//     const stateInfo = await stateMachine.getState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE'));
//     const allowedRoles = stateInfo[2];
//     const currentState = await stateMachine.getCurrentState();
//     assert(ethers.utils.parseBytes32String(currentState), 'CHANGE_HERE_STATE_ONE');
//     await expect(
//       stateMachine.transitionState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_THREE'), allowedRoles[0])
//     ).to.be.reverted;

//     const changedState = await stateMachine.getCurrentState();
//     assert.equal(
//       ethers.utils.parseBytes32String(changedState),
//       'CHANGE_HERE_STATE_ONE',
//       'the state is not set correctly'
//     );
//   });
//   it('should be able to grant a role to an account', async () => {
//     const [userOne, userTwo] = await ethers.getSigners();
//     await stateMachine
//       .connect(userOne)
//       .grantRoleToAccount(ethers.utils.formatBytes32String('ROLE_EDITOR'), userTwo.address);
//     expect(await stateMachine.hasRole(ethers.utils.formatBytes32String('ROLE_EDITOR'), userTwo.address)).to.equal(true);
//   });
//   it('should be able to add new role for state', async () => {
//     const [userOne, userTwo] = await ethers.getSigners();
//     await stateMachine
//       .connect(userOne)
//       .addRoleForState(
//         ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE'),
//         ethers.utils.formatBytes32String('ROLE_NEW'),
//         userTwo.address
//       );
//     const stateInfo = await stateMachine.getState(ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE'));
//     const newAllowedRole = stateInfo[2];
//     expect(newAllowedRole[3]).to.equal(ethers.utils.formatBytes32String('ROLE_NEW'));
//   });
//   it('should not be able to add the same role for state', async () => {
//     const [userOne, userTwo] = await ethers.getSigners();
//     const state = ethers.utils.formatBytes32String('CHANGE_HERE_STATE_ONE');
//     const role = ethers.utils.formatBytes32String('ROLE_NEW');

//     await stateMachine.connect(userOne).addRoleForState(state, role, userTwo.address);

//     await expect(stateMachine.connect(userOne).addRoleForState(state, role, userTwo.address)).to.be.revertedWith(
//       'the role has been already added at this state'
//     );

//     const stateInfo = await stateMachine.getState(state);
//     const newAllowedRole = stateInfo[2];

//     expect(newAllowedRole[3]).to.equal(role);
//     expect(newAllowedRole[4]).to.be.undefined;
//   });
//   it('should be able to get roles', async () => {
//     const roles = await stateMachine.getRoles();
//     assert.sameMembers(
//       [
//         `${ethers.utils.formatBytes32String('ROLE_ADMIN')}`,
//         `${ethers.utils.formatBytes32String('ROLE_MANUFACTURER')}`,
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_ROLE_ONE')}`,
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_ROLE_TWO')}`,
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_ROLE_THREE')}`,
//         `${ethers.utils.formatBytes32String('CHANGE_HERE_ROLE_FOUR')}`,
//       ],
//       roles,
//       'roles are not correct'
//     );
//   });
//   it('should return true if role is allowed to transition to a next state', async () => {
//     expect(await stateMachine.checkAllowedRoles(ethers.utils.formatBytes32String('ROLE_MANUFACTURER'))).to.be.true;
//   });
//   it('should return false if role is not allowed to transition to a next state', async () => {
//     expect(await stateMachine.checkAllowedRoles(ethers.utils.formatBytes32String('ROLE_NEW'))).to.be.false;
//   });
 });