pragma solidity ^0.8.13;
interface IParena {
    /// @notice function to create a new parena
    /// @notice can be setup by anyone, they become the effective administrator of the fight
    /// @param entryFee is the fee that is paid by each entrant, can be 0
    /// @param entryToken is the token or ETH that is paid to enter a fight
    /// @param firstPayout payout for the winner, can be 0
    /// @param secondPayout payout for second place, can be 0
    /// @param thirdPayout payout for third place, can be 0
    /// @param adminPayout payout for the admin, can be 0
    /// @param burn boolean that determines if the losers have their NFTs burned! this does not impact, 1st, 2nd and 3rd place
    function createParena(
        uint256 entryFee,
        address entryToken,
        uint16 firstPayout,
        uint16 secondPayout,
        uint16 thirdPayout,
        uint16 adminPayout,
        bool burn) external;
    

    /// @notice function to enter a fighter into a given parena
    /// @param _parenaId, the id that each parena is mapped to
    /// @param _fighterId, the NFT id for an individual fighter
    function enterFighter(uint256 _parenaId, uint256 _fighterId) external;

    /// @notice this actually starts the fight, setting it such that no more entrants can join
    /// @notice this sill deliver the fighter data from the parena to the offhcain api oracle
    /// @notice this will deliver the seed hash from the blockchain to be used in the parena to determine the outcomes
    function initializeParena(uint256 _parenaId) external;


    /// @notice this function pulls the off-chain oracle data from the API establishing the winners
    /// @notice the data is then stored in a mapping of the winners and places for those fighters
    /// @notice the function also will remit payments to the winners and admins in accordance to the setup params
    function finalizeParena(uint256 _parenaId) external;

    
}