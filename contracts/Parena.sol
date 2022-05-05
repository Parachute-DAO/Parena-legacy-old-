// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;
/// @notice THIS CONTRACT AND ALL PARENAS ARE BUILT FOR BOBA L2 NETWORK

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./interfaces/IParena.sol";
import "./interfaces/IFighters.sol";

contract ParenaController is IParena, IERC721Receiver, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    Counters.Counter private parenaIds;
    /// @dev minting fees for creating a fighter NFT 
    /// even though the NFT contract is separate, all minting goes through this contract
    /// that ensures fees are paid appropriately and can control treasury 
    uint256 public mintFee;
    uint256 public eMintFee;
    address payable public treasury;
    address public nftFighters;


    constructor(uint256 _mintFee, uint256 _eMintFee, address payable _treasury, address _nftFighters) {
        mintFee = _mintFee;
        eMintFee = _eMintFee;
        treasury = _treasury;
        nftFighters = _nftFighters;
    }

    struct Parena {
        address admin;
        uint256 entryFee;
        address entryToken;
        uint16 firstPayout;
        uint16 secondPayout;
        uint16 thirdPayout;
        uint16 adminPayout;
        bool burn;
        bool initalized;
        bool closed;
        uint256 firstPlace;
        uint256 secondPlace;
        uint256 thirdPlace;
        uint256[] fighters;
    }
    mapping (uint256 => Parena) public parenas;

    /// @dev maps the NFT ID of a given fighter to a ParenaID if its entered into a fight
    mapping (uint256 => uint256) public fightersEntered;
    //uint256[] private currentFighters;

    function getFightersInParena(uint256 _parenaId) internal view returns (uint256[] memory) {
        for
    }

    /// @notice this function just creates the initial struct of the parena
    function createParena(
        uint256 entryFee,
        address entryToken,
        uint16 firstPayout,
        uint16 secondPayout,
        uint16 thirdPayout,
        uint16 adminPayout,
        bool burn) public {
            parenaIds.increment();
            uint256 parenaId = parenaIds.current();
            require(firstPayout + secondPayout + thirdPayout + adminPayout == 100, "does not add up to 100");
            parenas[parenaId] = Parena(msg.sender, entryFee, entryToken, firstPayout, secondPayout, thirdPayout, adminPayout, burn, false, false, 0, 0, 0);
            // emit event here
        }

    function enterFighter(uint256 _parenaId, uint256 _fighterId) public returns (bool) {
        /// @dev require the msg.sender to be the owner of the NFT
        require(msg.sender == ownerOf(_fighterId), "youre not the owner");
        Parena memory parena = parenas[_parenaId];
        require(!parena.initalized && !parena.closed, "already initalized, or closed");
        require(fightersEntered[_fighterId] == 0, "alread in a fight");
        /// @dev pay the entry fee
        if (parena.entryFee > 0) SafeERC20.safeTransferFrom(IERC20(parena.entryToken), msg.sender, address(this));
        /// @dev pull the fighter into this contract if the _figherID is not 0, otherwise mint a new one and enter it
        if (_fighterId > 0) {
            /// @dev pulls fighter in
        } else {
            _fighterId = mintandEnter(msg.sender);
        }
        /// @dev map the fighter to the parena
        fightersEntered[_fighterId] = _parenaId;
        Parena storage _parena = parena;
        /// @dev push the fighter into fighters storage array
        _parena.fighters.push(_fighterId);
        // emit event here
    }

    function mintandEnter(address payer) internal returns (uint256 _fighterId) {
        /// @dev enforce payment of the eMintFee
        require(msg.value == eMintFee, "wrong eth amt sent");
        (bool success, ) = treasury.call{value: eMintFee}('');
        require(success, "transfer unsuccessful");
        /// @dev mint a fighter on the NFT contract
        _fighterId = IFighters(nftFighters).mintFighter(payer);
    }

    function mintFighter() public returns (uint256 _fighterId) {
        /// @dev enforce payment of the mintFee
        require(msg.value == mintFee, "wrong eth amt sent");
        (bool success, ) = treasury.call{value: mintFee}('');
        require(success, "transfer unsuccessful");
        /// @dev mint a fighter on the NFT contract
        _fighterId = IFighters(nftFighters).mintFighter(msg.sender);
    }

    function initializeParena(uint256 _parenaId) public {
        Parena memory parena = parenas[_parenaId];
        require(msg.sender == parena.admin, "only admin");
        hash seedHash = blockhash(blockNumber-1);
        /// @dev api call via Boba network to our api, includes seedHash and fighters array in the struct

    }

}