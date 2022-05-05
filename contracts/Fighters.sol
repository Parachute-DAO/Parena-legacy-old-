pragma solidity ^0.8.13;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import "@openzeppelin/contracts/token/ERC721/extentions/ERC721Enumerable.sol";

interface Helper {
  function TuringRandom() external returns (uint256);
}


contract ParenaFighters is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _fighterIds;

    address private turing;

    constructor(string memory uri, string memory name, string memory symbol, address _turing) ERC721(name, symbol) {
        baseURI = uri;
        api = _api;
        turing = _turing;
    }

    struct Fighter {
        uint16 initiative;
        uint16 attack;
        uint16 parry;
    }
    mapping (uint256 => Figther) private fighters;

    function getFighter(uint256 _fighterId) public view returns (Fighter memory fighter) {
        fighter = fighters[_fighterId];
    }

    function mintFighter(address manager) onlyOwner public returns (uint256) {
        _fighterIds.increment();
        uint256 currentFighter = _fighterIds.current();
        /// @dev gets random attributes for each fighter
        uint16 _initiative = turing.TuringRandom();
        uint16 _attack = turing.TuringRandom();
        uint16 _parry = turing.TuringRandom();
        fighters[currentFighter] = Fighter(_initiative, _attack, _parry);
        safeMint(manager, currentFighter);
        return currentFighter;
    }
}