## Rare Properties N.F.T. Marketplace on Ethereum BlockChain

## +-For Testing the Successful Rare Properties N.F.T. Marketplace DEMO Deployed in the Ropsten Ethereum TestNet:\_
+-Smart Contract deployed to the Ropsten Ethereum TestNet with the account: ------------------
nftMarket deployed to: https://ropsten.etherscan.io/address/------------------
nft deployed to: https://ropsten.etherscan.io/address/------------------

+-You can get Ropsten Test Ether Here:\_
https://faucet.dimensions.network

## +-Quick Project start:_

+-(1)-The first things you need to do are cloning this repository and installing its dependencies:

```sh
npm install
```

+-(2-A)-Duplicate the ".example.InfuraOrAlchemyEthereumTestNetKey" and Rename it deleting the part of ".example" so the Final Result is ".InfuraOrAlchemyEthereumTestNetKey". Here you will have to write your Alchemy (or Infura) Ropsten TestNet Key (NOT the entire URL) within 2 quotes(" ... ").

+-(2-B)-Duplicate the ".example.secret" and Rename it deleting the part of ".example" so the Final Result is ".secret". Here you will have to write your Wallet Private Key WITHOUT quotes. Your wallet needs to have enough Ropsten Test Ether in order to Deploy the Smart Contract.

+-(2-C)-Duplicate the ".example.InfuraOrAlchemyEthereumMainNetKey" and Rename it deleting the part of ".example" so the Final Result is ".InfuraOrAlchemyEthereumMainNetKey". Here you will have to write your Alchemy (or Infura) Ethereum MainNet Key (NOT the entire URL) within 2 quotes(" ... "). You can use the same Wallet(and the same Private Key) that you used to Deploy the Ropsten TestNet Smart Contract. Your wallet needs to have enough Ether in order to Deploy the Smart Contract.

## +-Testing the Project in a Local Node:_

+-(3)-Now open a 1st Terminal and let's Test your Project in Local Hardhat Node:\_

```sh
npx hardhat node
```

+-(4)-With the network running, Open a 2nd Terminal and Deploy the Smart Contracts to the Local Hardhat Node:\_

```sh
npx hardhat run scripts/deploy.js --network localhost
```

+-(5)-Now in that same Terminal you can Execute the Tests:\_

```sh
npx hardhat test
```

## +-Deploying the Project to the Ropsten TestNet:_

+-(6)-Deploy the Smart Contract to the Ropsten Ethereum Test Network(https://hardhat.org/tutorial/deploying-to-a-live-network.html):\_

```sh
npx hardhat run scripts/deploy.js --network ropsten
```

## +-Deploying the Project to the Ethereum MainNet:_

+-(7)-Deploy the Smart Contract to the Ethereum Main Network(https://hardhat.org/tutorial/deploying-to-a-live-network.html):\_

```sh
npx hardhat run scripts/deploy.js --network mainnet
```