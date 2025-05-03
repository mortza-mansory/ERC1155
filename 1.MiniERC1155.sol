// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/*
Whats a ERC1155 standard?

Its a standard for making multiplate diffrent tokens in one contract
That is can be Fungible,
Non-Fungible( like ERC20 and NFT's) and 
Semi-Fungible( like ticket or game items).

Having some in features like:
meta data, 
batch mint,
batch transfer

*/
contract MiniERC1155Token is ERC1155, Ownable {
    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant SWORD = 2;

        constructor(string memory baseURI) ERC1155(baseURI) {
        // Mint initial tokens to the owner
        _mint(msg.sender, GOLD, 1000, "");
        _mint(msg.sender, SILVER, 5000, "");
        _mint(msg.sender, SWORD, 10, "");
    }

    function mint(address to, uint256 id, uint256 amount) external onlyOwner {
        _mint(to, id, amount, "");
    }

    function burn(address from, uint256 id, uint256 amount) external onlyOwner {
        _burn(from, id, amount);
    }
    function uri(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(tokenId), Strings.toString(tokenId), ".json"));
    }
}

