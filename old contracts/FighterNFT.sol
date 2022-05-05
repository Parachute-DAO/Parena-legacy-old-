// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract ParenaFighter is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseURI;


    constructor(string memory _baseURI) ERC721("Parena_Figher", "FIGHT") {
        baseURI = _baseURI;
    }

    struct Fighter {
        string hero;
        string weapon;
        string armor;
        uint16 intelligence;
        uint16 attack;
        uint16 defense;
        bool isFighting;
    }

    mapping (uint => Fighter) public fighters;

    
    function createFighter(
        address _fighter, 
        string memory _class, 
        string memory _weapon,
        string memory _armor, 
        uint16 _intelligence, 
        uint16 _attack,
        uint16 _defense
        ) external onlyOwner {
        _tokenIds.increment();
        uint newItemId = _tokenIds.current();
        _safeMint(_fighter, newItemId);

        fighters[newItemId] = Fighter(_class, _weapon, _armor, _intelligence, _attack, _defense, false);
        //emit event
    }


    function enterIntoFight(uint _id) external onlyOwner {
        Fighter storage fighter = fighters[_id];
        require(!fighter.isFighting, "already fighting");
        fighter.isFighting = true;
    }

    function fight(uint _1, uint _2, uint winner, bool lastFight) external onlyOwner {
        Fighter storage fighter1 = fighters[_1];
        Fighter storage fighter2 = fighters[_2];
        require(fighter1.isFighting && fighter2.isFighting, "not fighting");
        if (_1 == winner) {
            if (lastFight) win(_1);
            kill(_2);
        } else {
            if (lastFight) win(_2);
            kill(_1);
        }
    }

    function kill(uint _id) internal {
        Fighter storage fighter = fighters[_id];
        _burn(_id);
        delete fighter;
    }

    function win(uint _id) internal {
        Fighter storage fighter = fighters[_id];
        fighter.isFighting = false;
    }


    function getFighterDetails(uint _id) external view returns (
        string _class,
        string _weapon,
        string _armor,
        uint16 _intelligence,
        uint16 _attack,
        uint16 _defense,
        bool _isFighting
    ) {
        Fighter storage fighter = fighters[_id];
        _class = fighter.class;
        _weapon = fighter.weapon;
        _armor = fighter.armor;
        _intelligence = fighter.intelligence;
        _attack = fighter.attack;
        _defense = fighter.defense;
        _isFighting = fighter.isFighting;
    }
    
    
    function baseTokenURI() public view returns (string memory) {
        return baseURI;
    }


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        Fighter storage f = fighters[tokenId];
        require(!f.isFighting, "currently fighting");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }


}
