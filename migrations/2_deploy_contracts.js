const StateMachine = artifacts.require("StateMachine.sol");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(StateMachine,1000,100,100,accounts[1], accounts[2],{from:accounts[0]});
};
