// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;


interface IBetaParena {
    
    function createParena(
        uint256 entryFee,
        address entryToken,
        uint16 firstPayout,
        uint16 secondPayout,
        uint16 thirdPayout,
        uint16 adminPayout
    ) external;
}