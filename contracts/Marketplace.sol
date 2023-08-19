// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

struct NFTListing {
    uint256 price;
    address seller;
}

contract NFTMarketUpgradeable is Initializable, ERC721URIStorageUpgradeable,OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMathUpgradeable for uint256;

    CountersUpgradeable.Counter public _tokenIDs;
    mapping(uint256 => NFTListing) private _listings;

    // if tokenURI is not an empty string => an NFT was created
    // if price is not 0 => an NFT was listed
    // if price is 0 && tokenURI is an empty string => NFT was transferred (either bought, or the listing was canceled)
    event NFTTransfer(uint256 tokenID, address from, address to, string tokenURI, uint256 price);

    // constructor() ERC721("Abdou's NFTs", "ANFT") {}

    function initialize() external initializer{
        __ERC721_init("URKS TOKEN","URK");
        __Ownable_init();
    }


    function createNFT(string calldata tokenURI) public {
        _tokenIDs.increment();
        uint256 currentID = _tokenIDs.current();
        _safeMint(msg.sender, currentID);
        _setTokenURI(currentID, tokenURI);
        emit NFTTransfer(currentID, address(0), msg.sender, tokenURI, 0);
    }

    function listNFT(uint256 tokenID, uint256 price) public {
        require(price > 0, "NFTMarket: price must be greater than 0");
        transferFrom(msg.sender, address(this), tokenID);
        _listings[tokenID] = NFTListing(price, msg.sender);
        emit NFTTransfer(tokenID, msg.sender, address(this), "", price);
    }

    function buyNFT(uint256 tokenID) public payable {
        NFTListing memory listing = _listings[tokenID];
        require(listing.price > 0, "NFTMarket: nft not listed for sale");
        require(msg.value == listing.price, "NFTMarket: incorrect price");
        ERC721Upgradeable(address(this)).transferFrom(address(this), msg.sender, tokenID);
        clearListing(tokenID);

        // transfer funds k function per error hai.......
        //  payable(listing.seller).transfer(listing.price.mul(95).div(100));
        uint256 balance = listing.price.mul(95).div(100);
        (bool sent,) = listing.seller.call{value : balance}("");
        require(sent, "Failed to send Ether");
        emit NFTTransfer(tokenID, address(this), msg.sender, "", 0);
    }

    function cancelListing(uint256 tokenID) public {
        NFTListing memory listing = _listings[tokenID];
        require(listing.price > 0, "NFTMarket: nft not listed for sale");
        require(listing.seller == msg.sender, "NFTMarket: you're not the seller");
        ERC721Upgradeable(address(this)).transferFrom(address(this), msg.sender, tokenID);
        clearListing(tokenID);
        emit NFTTransfer(tokenID, address(this), msg.sender, "", 0);
    }

    function withdrawFunds() public {
        uint256 balance = address(this).balance;
        require(balance > 0, "NFTMarket: balance is zero");
        // payable(msg.sender).transfer(balance);
        (bool sent,) = msg.sender.call{value : balance}("");
        require(sent,"Failed to send Ether");
    }

    function clearListing(uint256 tokenID) private {
        _listings[tokenID].price = 0;
        _listings[tokenID].seller = address(0);
    }
}