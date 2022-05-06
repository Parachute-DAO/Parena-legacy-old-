# Parena
Parena build, contracts + opensource front end and libraries

**BETA**
Before even building the full NFT on-chain Parena, the DAO is looking to build a beta version of Parena to test the on-chain / off-chain oracle and functionalities. 
This is a first importan step, and is hightlighted and summarized in the Parena Outline pdf document. 
This beta will allow us to evaluate the user experience and effectiveness of an on-chain Parena. 
It will also allow the DAO to start collect small amounts of fees to the treasury! 



**TO BE UPDATED**

From the community, the primary build for Parena will involve using the current UI files from Parena (to be uploaded shortly)
and integrate a basic smart contract system to record all of the battles on chain. 
The battles recorded on chain would really be for the winners of the battle, and to distribute payouts. 

There should be two main contracts:

1. The controller, which maintains records for each battle, receives payments, holds NFTs in escrow, and pays out to winners and fees to Parachute DAO
2. The NFT contract that mints fighters. 


Some more details: 

NFTs (probably 721 enumerable):  
The NFTs represent a single fighter with the attributes held on chain. Visuals and metadata to be stored off-chain either aws database or IPFS (tbd).  
There are two ways to mint an NFT, you can mint an NFT anytime you want to mint a fighter! 
You can collect em, trade em, and of course battle them! you can choose to enter a pre-minted fighter to a battle. 
Or if you just want to join a battle, you can 'mint & enter', where entering the parena without a fighter mints you a random NFT and enters it into that parena. 

Minting an NFT comes with an ETH fee that is paid directly to the Parachute DAO treasury. Pre-mint should cost more than a 'mint & fight' NFT, 
but both costs are governed by the Parachute DAO. 


Controller: 
The controller is ERC721receiver, plus a few other libraries
Its primary purpose is to setup parena battles, that users can then enter the battles. To enter a battle they must register their NFT fighter, 
or if they don't have a fighter they can have one minted at entry and registered. Those NFTs are held by the controller during the battle so they can't be
traded or used in any other battles. 
Some battles may also have an entrance fee. These fees are not paid to the Parachute DAO, but paid to the organizer and winners of the battles, in the payout schema determined by the organizer. 
So an organizer may suppose that for a $10 entrance fee, the winner will receive 60%, 2nd place 20%, third place 10%, and organizer 10%. 
The contoller will allow up to these four variable fee recipients, but they can be excluded or varied however chosen. 
Some fights may also burn the losing NFTs. The controller will be responsible for burning, or refunding the NFTs to the players, depending on the setup. 

The controller will take the off-chain parena battle data from a parena battle oracle, which information can be replicated on-chain from the original eth hash
so that there is proof of fairness. Based on this oracle data, the organizer then triggers the payouts and NFT transfers / burns. 


THIS IS DRAFT AND SHOULD BE CONFIRMED BY THE DAO BEFORE FINAL IMPLEMENTATION
