// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ParenaHeroes is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseURI;

    constructor(string memory _baseURI) ERC721("Parena_Heroes", "HERO") {
        baseURI = _baseURI;
    }

    struct Hero {
        string name;
        uint intelligenceBonus;
        bool isEquipped;
    }

    mapping (uint => Hero) public heroes;

    function mintWeapon(address _fighter, string memory _name, string memory _intelligenceBonus) external onlyOwner {
         _tokenIds.increment();
        uint newItemId = _tokenIds.current();
        _safeMint(_fighter, newItemId);

        heroes[newItemId] = Hero(_name, _intelligenceBonus, false);
        //emit event
    }

    function getHeroDetails(uint _id) public view returns (string _name, uint _intelligenceBonus, bool _isEquipped) {
        Hero storage hero = heroes[_id];
        _name = hero.name;
        _intelligenceBonus = hero.intelligenceBonus;
        _isEquipped = hero.isEquipped;
    }


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        Hero storage h = heroes[tokenId];
        require(!h.isEquipped, "currently equipped");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

}
