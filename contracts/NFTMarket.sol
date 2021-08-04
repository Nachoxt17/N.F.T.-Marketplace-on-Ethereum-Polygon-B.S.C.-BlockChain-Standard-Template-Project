// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

//+-@openzeppelin/Counters:_ Is a really Useful Utility for Incrementing Numbers to save work that otherwise you should code by Yourself:_
import "@openzeppelin/contracts/utils/Counters.sol";
/**+-ReentrancyGuard:_ This is a Security Mechanism that gives us an Utility Helper callled "non-re-entrant" that will help us to protect certain transactions
that are Talking to a Separate Smart Contract to prevent someone to hit this with multiple malicious transactions.*/
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
  //+-We enable the S.Contract to use the Struct "Counter" of the Counters Utils S.Contract:_
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner;
  //+-Listing Price:_ The Fee that the user Pays for Listing a N.F.T.
  uint256 listingPrice = 0.025 ether;

  //+-AuctionTime. By Default the time is 1 day.
  uint256 public auctionStandardTime = 1 days;
  //+-Current State of the English Auction:_
  mapping(uint256 => address) private highestBidders;
  mapping(uint256 => uint256) private highestBids;
  mapping(uint256 => uint256) private auctionEndTimes;
  mapping(uint256 => bool) private auctionEnded;
  mapping(address => uint256) private pendingReturns;

  //+-Parameters of the Dutch Auction:_
  mapping(uint256 => uint256) private dutchAuctionStartingPrices;
  mapping(uint256 => uint256) private dutchAuctionEndingPrices;
  mapping(uint256 => uint256) private dutchAuctionStartTimes;

  //+-English Auction Events:_
  event HighestBidIncrease(address bidder, uint256 amount);
  event AuctionEnded(address winner, uint256 amount);

  constructor() {
    owner = payable(msg.sender);
  }

  //+-Struct (Data Structure) of every Item in the Marketplace:_
  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

  //+-Mapping in which you Give an Item ID and you receive that Item Struct:_
  mapping(uint256 => MarketItem) private idToMarketItem;

  //+-Event that is triggered every time an Item is Created, this is useful to execute things in the Front-End:_
  event MarketItemCreated (
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
  );

  //+-Returns the listing price of the Smart Contract:_
  function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }
  
  //+-Places an item for sale on the Marketplace:_
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    uint256 price
  ) public payable nonReentrant {
    require(price > 0, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "msg.value(Fee to pay) must be equal to listing price");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();
  
    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price,
      false
    );

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      price,
      false
    );
  }

  //+-Creates the sale of a Marketplace Item:_
  //+-Transfers ownership of the item, as well as funds between parties:_
  function createMarketSale(
    address nftContract,
    uint256 itemId
    ) public payable nonReentrant {
    uint price = idToMarketItem[itemId].price;
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    idToMarketItem[itemId].seller.transfer(msg.value);
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
    idToMarketItem[itemId].owner = payable(msg.sender);
    idToMarketItem[itemId].sold = true;
    _itemsSold.increment();
    payable(owner).transfer(listingPrice);
  }

  //+-Places an item for sale in an English Auction on the Marketplace:_
  function createMarketEnglishAuction(
    address nftContract,
    uint256 tokenId,
    uint256 startingPrice,
    uint256 daysAuctionEndTime
  ) public payable nonReentrant {
    require(startingPrice > 0, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "msg.value(Fee to pay) must be equal to listing price");
    require(daysAuctionEndTime >= 1, "daysAuctionEndTime must be equal or greater than 1");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    auctionEndTimes[itemId] = block.timestamp + (daysAuctionEndTime * auctionStandardTime);
    auctionEnded[itemId] = false;
  
    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      startingPrice,
      false
    );

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      startingPrice,
      false
    );
  }

  //+-Creates a Bid for a Marketplace EnglishAuction:_
  function bidEnglishAuction(uint256 itemId) public payable nonReentrant {
    if (block.timestamp > auctionEndTimes[itemId]) {
      revert("The auction has already ended");
    }

    if (msg.value <= highestBids[itemId]) {
      revert("There is already a higher or equal bid");
    }

    //+-Automatically Returns to the former Highest Bidder its Losing Bid:_
    if (highestBids[itemId] != 0) {
      payable(highestBidders[itemId]).transfer(highestBids[itemId]);
    }

    //+-Updates New Highest Bidder and Highest Bid.
    highestBidders[itemId] = msg.sender;
    highestBids[itemId] = msg.value;
    emit HighestBidIncrease(msg.sender, msg.value);
  }

  //+-This function needs to be Manually Called when the Time of an EnglishAuction finishes to Reward The Highest Bidder and The N.F.T. Owner.
  function englishAuctionEnd(address nftContract, uint256 itemId) public nonReentrant {
    if (block.timestamp < auctionEndTimes[itemId]) {
      revert("The auction has not ended yet");
    }

    if (auctionEnded[itemId]) {
      revert("The function auctionEnded has already been called");
    }

    auctionEnded[itemId] = true;
    emit AuctionEnded(highestBidders[itemId], highestBids[itemId]);

    idToMarketItem[itemId].seller.transfer(highestBids[itemId]);
    IERC721(nftContract).transferFrom(address(this), highestBidders[itemId], idToMarketItem[itemId].tokenId);
    idToMarketItem[itemId].owner = payable(msg.sender);
    idToMarketItem[itemId].sold = true;
    idToMarketItem[itemId].price = highestBids[itemId];
    _itemsSold.increment();
    payable(owner).transfer(listingPrice);
  }

  //+-Places an item for sale in an Dutch Auction on the Marketplace:_
  function createMarketDutchAuction(
    address nftContract,
    uint256 tokenId,
    uint256 startingPrice,
    uint256 endingPrice,
    uint256 daysAuctionEndTime
  ) public payable nonReentrant {
    require(startingPrice > endingPrice, "Starting Price must be higher than Ending Price");
    require(endingPrice > 0, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "msg.value(Fee to pay) must be equal to listing price");
    require(daysAuctionEndTime >= 1, "daysAuctionEndTime must be equal or greater than 1");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    dutchAuctionStartTimes[itemId] = block.timestamp;
    auctionEndTimes[itemId] = block.timestamp + (daysAuctionEndTime * auctionStandardTime);
    auctionEnded[itemId] = false;
    dutchAuctionStartingPrices[itemId] = startingPrice;
    dutchAuctionEndingPrices[itemId] = endingPrice;

    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      startingPrice,
      false
    );

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      startingPrice,
      false
    );
  }

  function getCurrentPriceDucthAuction(uint256 itemId) public view returns (uint256) {
    if (block.timestamp > auctionEndTimes[itemId]) {
      revert("The auction has already ended");
    }

    uint256 elapsedTime = block.timestamp - dutchAuctionStartTimes[itemId];
    uint256 timeRange = auctionEndTimes[itemId] - dutchAuctionStartTimes[itemId];
    uint256 priceRange = dutchAuctionStartingPrices[itemId] - dutchAuctionEndingPrices[itemId];
    return dutchAuctionStartingPrices[itemId] - ((elapsedTime * priceRange) / timeRange);
  }

  //+-Creates the Sale for a Marketplace DutchAuction:_
  function createDutchAuctionSale(address nftContract, uint256 itemId) public  payable nonReentrant {
    if (block.timestamp < auctionEndTimes[itemId]) {
      revert("The auction has not ended yet");
    }

    if (auctionEnded[itemId]) {
      revert("The function auctionEnded has already been called");
    }

    require(msg.value > dutchAuctionEndingPrices[itemId], "The Amount payed must be Higher than the Dutch Auction Ending Price.");
    require(msg.value >= getCurrentPriceDucthAuction(itemId), "The Amount payed must be Equal or Higher than the Dutch Auction Current Price. In case of a surplus, it will be returned instantly.");

    if (msg.value > getCurrentPriceDucthAuction(itemId)) {
      payable(msg.sender).transfer(msg.value - getCurrentPriceDucthAuction(itemId));
    }

    auctionEnded[itemId] = true;
    emit AuctionEnded(msg.sender, msg.value);

    idToMarketItem[itemId].seller.transfer(msg.value);
    IERC721(nftContract).transferFrom(address(this), msg.sender, idToMarketItem[itemId].tokenId);
    idToMarketItem[itemId].owner = payable(msg.sender);
    idToMarketItem[itemId].sold = true;
    idToMarketItem[itemId].price = msg.value;
    _itemsSold.increment();
    payable(owner).transfer(listingPrice);
  }

  //+-Returns all UnSold Market Items:_
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0)) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  //+-Returns onlyl Items that an User has purchased:_
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  //+-Returns only items an User has Created:_
  function fetchItemsCreated() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
}