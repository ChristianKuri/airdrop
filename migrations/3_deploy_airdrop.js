const AToken = artifacts.require('AToken.sol');
const Airdrop = artifacts.require('Airdrop.sol');

module.exports = async function (deployer) {
  const token = await AToken.deployed();
  const airdropAmount = web3.utils.toWei('100000');
  await deployer.deploy(Airdrop, token.address, airdropAmount);
  const airdrop = await Airdrop.deployed();
  await token.transfer(airdrop.address, airdropAmount);
};