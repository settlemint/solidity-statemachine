import { Bytes } from '@graphprotocol/graph-ts';
import { StateTransition } from '../../generated/schema';
import { Transition } from '../../generated/statemachinemetadata/StateMachineMetadata';
import { fetchStateMachine } from '../fetch/statemachinedata';

export function handleTransitions(event: Transition): void {
  const contract = fetchStateMachine(event.address);
  const evt = new StateTransition(event.address.toHexString());
  evt.actor = Bytes.fromHexString(event.params.sender.toHexString());
  evt.contract = contract.id;
  evt.timestamp = event.block.timestamp;
  evt.fromState = event.params.fromState;
  evt.toState = event.params.toState;
  contract.currentState = evt.toState;

  contract.save();
  evt.save();
}