const { getNamedAccounts, deployments, network } = require("hardhat");
require("dotenv").config();
const { verify } = require("../utils/verify");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const deployer = (await getNamedAccounts()).deployer;
  const { deploy, log } = deployments;
  const chainId = network.config.chainId;

  const swap = await deploy("Multiswap", {
    from: deployer,
    args: [],
    log: true,
  });

  log("............................");
  if (process.env.ETHERSCAN_API_KEY) {
    console.log("Entered Verification Arena!!");
    await verify(swap.address, []);
  }
};

module.exports.tags = ["all", "swap"];
