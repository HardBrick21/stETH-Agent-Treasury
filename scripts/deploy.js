const hre = require("hardhat");

async function main() {
  console.log("Deploying stETH Agent Treasury to Ethereum Mainnet");
  console.log("Chain ID: 1\n");

  const StETHAgentTreasury = await hre.ethers.getContractFactory("StETHAgentTreasury");
  
  console.log("Deploying StETHAgentTreasury...");
  const treasury = await StETHAgentTreasury.deploy();
  await treasury.waitForDeployment();
  
  const address = await treasury.getAddress();
  console.log(`✅ StETHAgentTreasury deployed to: ${address}`);
  
  console.log("\n--- Deployment Summary ---");
  console.log(`Contract: ${address}`);
  console.log(`Network: Ethereum Mainnet`);
  console.log(`stETH Address: 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84`);
  console.log(`wstETH Address: 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0`);
  console.log(`Explorer: https://etherscan.io/address/${address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});