const { artifacts } = require('truffle');
const Voting = artifacts.require("Voting");

module.exports=function (deployer) {
    deployer.deploy(Voting);
};