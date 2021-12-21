// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ParenaArmory is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseURI;

    constructor(string memory _baseURI) ERC721("Parena_Armory", "ARMOR") {
        baseURI = _baseURI;
    }

    struct Armor {
        string name;
        uint defenseBonus;
        bool isEquipped;
    }

    mapping (uint => Armor) public armory;

    function mintWeapon(address _fighter, string memory _name, string memory _defenseBonus) external onlyOwner {
         _tokenIds.increment();
        uint newItemId = _tokenIds.current();
        _safeMint(_fighter, newItemId);

        armory[newItemId] = Armor(_name, _defenseBonus, false);
        //emit event
    }

    function getHeroDetails(uint _id) public view returns (string _name, uint _defenseBonus, bool _isEquipped) {
        Armor storage armor = armory[_id];
        _name = armor.name;
        _defenseBonus = armor.defenseBonus;
        _isEquipped = armor.isEquipped;
    }


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        Armor storage a = armory[tokenId];
        require(!a.isEquipped, "currently equipped");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

}
