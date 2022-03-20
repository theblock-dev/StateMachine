// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StateMachine {

  enum State {
    PENDING,
    ACTIVE,
    CLOSED
  }

  State public state = State.PENDING;
  uint public amount;
  uint public interest;
  uint public endTime;

  address payable borrower;
  address payable lender;


  constructor(uint _amount, uint _interest, uint _duration, address payable _borrower, address payable _lender) {
    amount = _amount;
    interest = _interest;
    endTime = block.timestamp+_duration;
    borrower = _borrower;
    lender = _lender;
  }

  function fund() payable external {
    require(msg.sender == lender,'only lender can lend');
    require(address(this).balance == amount, 'can only lend the exact amount');
    _transitionTo(State.ACTIVE);
    borrower.transfer(amount);    
  }

  function reimburse() payable external {
    require(msg.sender == borrower,'only borrower can reimburse');
    require(msg.value == interest+amount, 'need to reimburse the correct amount plus interest');
    _transitionTo(State.CLOSED);
    lender.transfer(amount+interest);    
  }

  function _transitionTo(State to) private {
    require(to != State.PENDING, 'can not go back to pending status');
    require(to != state, 'can not transition to the same state');

    if(to == State.ACTIVE) {
      require(state == State.PENDING, 'can only transition from pending state to active');
      state = State.ACTIVE;      
    }
    if(to == State.CLOSED){
      require(state == State.ACTIVE, 'can only transition to closed from active state');
      require(block.timestamp >= endTime,'loan hasnt matured yet');
      state = State.CLOSED;
    }
  }


}
