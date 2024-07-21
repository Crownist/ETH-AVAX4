// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DegenToken is ERC20, Ownable {
    using Strings for uint256;

    struct Item {
        uint256 cost;
        string description;
    }

    mapping(string => Item) public gameItems;
    mapping(address => string[]) public playerInventory;

    event ItemRedeemed(address indexed player, string item);

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {
        gameItems["EpicSword"] = Item(50, "A legendary sword of immense power");
        gameItems["MagicStaff"] = Item(40, "A staff imbued with arcane energies");
        gameItems["HealingPotion"] = Item(10, "Restores health to the drinker");
    }

    function mintTokens(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burnTokens(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
    }

    function transferTokens(address to, uint256 amount) public returns (bool) {
        return transfer(to, amount);
    }

    function getBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function redeemItem(string memory itemName) external {
        Item storage item = gameItems[itemName];
        require(item.cost > 0, "Item does not exist");
        require(balanceOf(msg.sender) >= item.cost, "Insufficient balance");

        _burn(msg.sender, item.cost);
        playerInventory[msg.sender].push(itemName);

        emit ItemRedeemed(msg.sender, itemName);
    }

    function getInventory() public view returns (string memory) {
        string[] memory items = playerInventory[msg.sender];
        string memory inventory = "";
        for (uint i = 0; i < items.length; i++) {
            if (i > 0) inventory = string(abi.encodePacked(inventory, ", "));
            inventory = string(abi.encodePacked(inventory, items[i]));
        }
        return inventory;
    }
}
