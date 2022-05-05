pragma solidity ^0.8.13;

interface IFighters {
    function mintFighter(address manager) external returns (uint256);

    function enterToFight() external;
}