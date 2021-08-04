require("@nomiclabs/hardhat-waffle");
const fs = require('fs');
const privateKey = fs.readFileSync(".secret").toString().trim() || "01234567890123456789";
const InfuraOrAlchemyEthereumTestNetKey = fs.readFileSync(".InfuraOrAlchemyEthereumTestNetKey").toString().trim() || "";
//const InfuraOrAlchemyEthereumMainNetKey = fs.readFileSync(".InfuraOrAlchemyEthereumMainNetKey").toString().trim() || "";

module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },
    hardhat: {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${InfuraOrAlchemyEthereumTestNetKey}`,
        blockNumber: 12610259,
        //chainId: 1337
      },
    },
    ropsten: {
      url: `https://eth-ropsten.alchemyapi.io/v2/${InfuraOrAlchemyEthereumTestNetKey}`,
      accounts: [privateKey],
    },
  },
};

