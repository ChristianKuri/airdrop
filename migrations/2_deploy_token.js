const AToken = artifacts.require('AToken.sol');

module.exports = function (deployer) {
  deployer.deploy(AToken);
};