const { ethers, upgrades } = require("hardhat");

async function main() {
  const NFTMarket = await ethers.getContractFactory("NFTMarketUpgradeable");
  const nftMarket = await upgrades.deployProxy(NFTMarket, [], {
    initializer: "initialize",
  });
  await nftMarket.waitForDeployment();
  console.log("Market Place Deployed to ==>>  ", await nftMarket.getAddress());
}

main();
