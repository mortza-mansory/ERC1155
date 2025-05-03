// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


/*
The items can have Levels and diffrent power.
GAME_MASTER_ROLE  ( who play it ) can mint burn or upgrade it..
this is for RPG base games...
*/
contract GameItemERC1155 is ERC1155, ERC1155Supply, AccessControl {
    using Strings for uint256;

    string public name = "Game Items";
    string public symbol = "GMI";
    string private baseURI;

    bytes32 public constant GAME_MASTER_ROLE = keccak256("GAME_MASTER_ROLE");

//For example..
    // // Sstruct for tracking upgrades 
    // struct ItemAttributes {
    //     uint256 level;
    //     uint256 power;
    // }

    mapping(uint256 => ItemAttributes) public attributes;

    event Minted(address indexed to, uint256 indexed id, uint256 amount);
    event Burned(address indexed from, uint256 indexed id, uint256 amount);
    event Upgraded(uint256 indexed id, uint256 newLevel, uint256 newPower);

    constructor(string memory _uri) ERC1155(_uri) {
        baseURI = _uri;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GAME_MASTER_ROLE, msg.sender);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function setBaseURI(string memory newURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = newURI;
    }

    function mintItem(address to, uint256 id, uint256 amount, bytes memory data) external onlyRole(GAME_MASTER_ROLE) {
        _mint(to, id, amount, data);
        emit Minted(to, id, amount);
    }

    function mintBatchItems(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external onlyRole(GAME_MASTER_ROLE) {
        _mintBatch(to, ids, amounts, data);
    }

    function burnItem(address from, uint256 id, uint256 amount) external onlyRole(GAME_MASTER_ROLE) {
        _burn(from, id, amount);
        emit Burned(from, id, amount);
    }

    function upgradeItem(uint256 id, uint256 newLevel, uint256 newPower) external onlyRole(GAME_MASTER_ROLE) {
        require(exists(id), "Item doesn't exist");
        attributes[id].level = newLevel;
        attributes[id].power = newPower;
        emit Upgraded(id, newLevel, newPower);
    }

    function getItemAttributes(uint256 id) external view returns (uint256 level, uint256 power) {
        level = attributes[id].level;
        power = attributes[id].power;
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    receive() external payable {}
}
