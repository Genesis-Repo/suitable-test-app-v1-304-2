// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    mapping(uint256 => Item) private _items;

    event ItemCreated(uint256 itemId, address indexed owner, uint256 price);
    event ItemSold(uint256 itemId, address indexed buyer, uint256 price);

    struct Item {
        uint256 itemId;
        address owner;
        uint256 price;
        bool sold;
    }

    function createItem(uint256 price) external {
        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        _items[itemId] = Item(itemId, msg.sender, price, false);
        emit ItemCreated(itemId, msg.sender, price);
    }

    function buyItem(uint256 itemId) external payable {
        require(_items[itemId].owner != address(0), "Item does not exist");
        require(!_items[itemId].sold, "Item is already sold");
        require(msg.value == _items[itemId].price, "Incorrect value");

        address payable seller = payable(_items[itemId].owner);
        seller.transfer(msg.value);

        _items[itemId].owner = msg.sender;
        _items[itemId].sold = true;
        _itemsSold.increment();

        emit ItemSold(itemId, msg.sender, _items[itemId].price);
    }

    function getItem(uint256 itemId) external view returns (uint256, address, uint256, bool) {
        Item memory item = _items[itemId];
        return (item.itemId, item.owner, item.price, item.sold);
    }

    function totalItems() external view returns (uint256) {
        return _itemIds.current();
    }

    function totalItemsSold() external view returns (uint256) {
        return _itemsSold.current();
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}