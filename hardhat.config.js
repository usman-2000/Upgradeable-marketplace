// require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY} `,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY,
    },
  },
};

// Market Place Deployed to ==>>   0xa1BC65DBCE3AccBDB8dc94c9349cE534dD8D077c
// Implementation Contract ==>>  0x0D4F1EB05f56e318F87965Ba4E1589F6028e8675
// Proxy Admin ==>>   0x0b0c1B14BD75daFB8E27A4731a09138060B1A74A
// TransparentUpgradeableProxy ==>>   0xa1BC65DBCE3AccBDB8dc94c9349cE534dD8D077c
