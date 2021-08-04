## Rare Properties N.F.T. Marketplace on Ethereum BlockChain

![Header](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/pfofv47dooojerkmfgr4.png)

## +-For Testing the Successful Rare Properties N.F.T. Marketplace DEMO Deployed in the Ropsten Ethereum TestNet:\_
+-Smart Contract deployed to the Ropsten Ethereum TestNet with the account: ------------------
nftMarket deployed to: https://ropsten.etherscan.io/address/------------------
nft deployed to: https://ropsten.etherscan.io/address/------------------

+-You can get Ropsten Test Ether Here:\_
https://faucet.dimensions.network

+-How to Interact with the Deployed Smart Contract:\_
https://docs.alchemy.com/alchemy/tutorials/hello-world-smart-contract/interacting-with-a-smart-contract#step-6-update-the-message

+-Quick Project start:_
+-(1)-The first things you need to do are cloning this repository and installing its dependencies:

```sh
npm install
```

+-(2)-Start the local Hardhat node:

```sh
npx hardhat node
```

+-(3)-With the network running, deploy the contracts to the local network in a separate terminal window:

```sh
npx hardhat run scripts/deploy.js --network localhost
```

+-(4)-Start the app:

```
npm run dev
```

### Configuration

To deploy to Ethereum Test or Main Networks, update the configurations located in __hardhat.config.js__ to use a private key and, optionally, deploy to a private RPC like Infura or Alchemy.

```javascript
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
      url: `https://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [privateKey],
    },
  },
};
```

If using Infura, update __.infuraid__ with your [Infura](https://infura.io/) project ID.
