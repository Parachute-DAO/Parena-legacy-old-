// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ParenaWeapon is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseURI;

    constructor(string memory _baseURI) ERC721("Parena_Weapons", "WEAPON") {
        baseURI = _baseURI;
    }

    struct Weapon {
        string name;
        uint attackBonus;
        bool isEquipped;
    }

    mapping (uint => Weapon) public weapons;

    function mintWeapon(address _fighter, string memory _name, string memory _attackBonus) external onlyOwner {
         _tokenIds.increment();
        uint newItemId = _tokenIds.current();
        _safeMint(_fighter, newItemId);

        weapons[newItemId] = Weapon(_name, _attackBonus, false);
        //emit event
    }

    function equip(uint _id) external onlyOwner {
        Weapon storage weapon = weapons[_id];
        require(!weapon.isEquipped, "already equipped");
        weapon.isEquipped = true;
    }

    function unEquip(uint _id) external onlyOwner {
        Weapon storage weapon = weapons[_id];
        require(weapon.isEquipped, "not equipped");
        weapon.isEquipped = false;
    }

    function getWeaponDetails(uint _id) public view returns (string _name, uint _attackBonus, bool _isEquipped) {
        Weapon storage weapon = weapons[_id];
        _name = weapon.name;
        _attackBonus = weapon.attackBonus;
        _isEquipped = weapon.isEquipped;
    }


    //updated transfer function
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        Weapon storage w = weapons[tokenId];
        require(!w.isEquipped, "currently equipped");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

}
