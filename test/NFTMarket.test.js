describe("NFTMarket Smart Contract", function() {

  let NFTMarket;
  let nftMarketDeployed;
  let nftMarketAddress;
  let NFT;
  let nft;
  let nftContractAddress;
  let listingPrice;

  beforeEach(async function() {
    NFTMarket = await ethers.getContractFactory("NFTMarket")
    nftMarketDeployed = await NFTMarket.deploy()
    await nftMarketDeployed.deployed()
    nftMarketAddress = nftMarketDeployed.address

    NFT = await ethers.getContractFactory("NFT")
    nft = await NFT.deploy(nftMarketAddress)
    await nft.deployed()
    nftContractAddress = nft.address

    listingPrice = await nftMarketDeployed.getListingPrice()
    listingPrice = listingPrice.toString()
  })

  it("Should Create and Execute Market Sales and Auctions", async function() {
    const salePrice = ethers.utils.parseUnits('1', 'ether')

    //+-Here we simulate that we create 2 N.F.T.s with their Uniform Resource Identifiers:_
    await nft.createToken("https://www.mytokenlocation.com")
    await nft.createToken("https://www.mytokenlocation2.com")

    await nftMarketDeployed.createMarketItem(nftContractAddress, 1, salePrice, { value: listingPrice })
    await nftMarketDeployed.createMarketItem(nftContractAddress, 2, salePrice, { value: listingPrice })

    /**+-By Default if you are Deploying a Smart Contract, it will be deployed on the first available account.
     * We ignore it by using the "_", and we do that in order to have Different Addresses between the Seller
     * (The First Address that we are Ignoring) and the Buyer(The Second Address):_*/
    const [_, buyerAddress] = await ethers.getSigners()

    await nftMarketDeployed.connect(buyerAddress).createMarketSale(nftContractAddress, 1, { value: salePrice})

    items = await nftMarketDeployed.fetchMarketItems()
    //+-"Promise.all" is for doing Asychronous Mapping:_
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toNumber(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item
    }))
    console.log('items: ', items)
  })

  it("Should be able to Remove Market Sales and Auctions", async function() {
    const salePrice = ethers.utils.parseUnits('1', 'ether')

    /**+-By Default if you are Deploying a Smart Contract, it will be deployed on the first available account.
     * We ignore it by using the "_", and we do that in order to have Different Addresses between the Seller
     * (The First Address that we are Ignoring) and the Market Place Owner(The Second Address):_*/
    const [sellerAddress, marketplaceOwnerAddress] = await ethers.getSigners()

    //+-Here we simulate that we create 2 N.F.T.s with their Uniform Resource Identifiers:_
    await nft.connect(sellerAddress).createToken("https://www.mytokenlocation.com")

    await nftMarketDeployed.connect(sellerAddress).createMarketItem(nftContractAddress, 1, salePrice, { value: listingPrice })

    tokensId = await nftMarketDeployed.fetchMarketItems()
    //+-"Promise.all" is for doing Asychronous Mapping:_
    tokensId = await Promise.all(tokensId.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId)
      let itemId = {
        price: i.price.toString(),
        tokenId: i.tokenId.toNumber(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return itemId.tokenId
    }))
    console.log('items: ', items)

    await nftMarketDeployed.connect(sellerAddress).removeMarketItem(nftContractAddress, tokensId)
  })
})