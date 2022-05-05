// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";





interface IFighter {
    function createFighter(address _fighter, string memory _class, string memory _weapon, uint16 _intelligence, uint16 _attack,uint16 _defense) external;
    function fight(uint _fighter1, uint _fighter2) external returns (uint _winner);
    function ownerOf(uint _id) external view returns (address);
    function enterIntoFight(uint _id) external;
}

interface IWeapon {
    function getWeaponDetails(uint _id) external view returns (string _name, uint _attackBonus, bool _isEquipped);
    function ownerOf(uint _id) external view returns (address);
    function equip(uint _id) external;
    function unEquip(uint _id) external;
}

interface IHero {
    function getHeroDetails(uint _id) external view returns (string _name, uint _intelligenceBonus, bool _isEquipped);
    function ownerOf(uint _id) external view returns (address);
    function equip(uint _id) external;
    function unEquip(uint _id) external;
}

interface IArmor {
    function getArmorDetails(uint _id) external view returns (string _name, uint _defenseBonus, bool _isEquipped);
    function ownerOf(uint _id) external view returns (address);
    function equip(uint _id) external;
    function unEquip(uint _id) external;
}

contract ParenaController is ReentrancyGuard, Ownable {
     using SafeERC20 for IERC20;
     using Counters for Counters.Counter;
     Counters.Counter private _parenaIds;


     address public treasury;
     uint public parenaFee;
     uint public fighterFee;
     bool on;
     address public fighterContract; //address of the NFT contract producing fighters
     address public weaponContract;
     address public heroContract;
     address public armorContract;
     uint private maxFighters = 10000;
     address public par;
     

     
    constructor(address _par) {
        par = _par;
    }


    modifier isOn() {
        require(on, "not on");
        _;
    }

    function initialize(
        address _treasury, 
        uint _parenaFee, 
        uint _fighterFee, 
        address _fighterContract, 
        address _weaponContract, 
        address _heroContract,
        address _armorContract
    ) external onlyOwner returns (bool) {
        treasury = _treasury;
        parenaFee = _parenaFee;
        fighterFee = _fighterFee;
        fighterContract = _fighterContract;
        weaponContract = _weaponContract;
        heroContract = _heroContract;
        armorContract = _armorContract;
        on = true;
        return on;
    }

    //struct for all of the game details
    struct Parena {
        address paymentToken;
        uint entryFee;
        uint[] rewardRates; //rates in percentages for payouts to 1st, second third...
        address[] winners; //in rank of 1st, second, third...
        uint startTime;
        uint totalFighters;
        bool singleEntry;
        bool started;
        bool ended;
        mapping(address => bool) entered;
        mapping(uint => bool) alive;
    }

    mapping (uint => Parena) public parenas;


    function depositEntryFee(address _token, address from, uint _amount) internal {
        require(IERC20(_token).balanceOf(from) >= _amount, "insufficient funds");
        uint fee = (_amount * parenaFee) / 100;
        uint entryFee = _amount - fee;
        SafeERC20.safeTransferFrom(IERC20(_token), from, address(this), entryFee);
        SafeERC20.safeTransferFrom(IERC20(_token), from, treasury, fee);
    }


    function createFighter(uint weaponID, uint heroID, uint armorID) public isOn {
        require(IWeapon(weaponContract).ownerOf(weaponID) == msg.sender || weaponID == 0, "not the weapon owner");
        require(IHero(heroContract).ownerOf(heroID) == msg.sender || heroID == 0, "not the hero owner");
        //pull in the details only if they are not 0 index
        if (weaponID > 0) {
            (string _weapon, uint _attackBonus, bool _isEquipped) = IWeapon(weaponContract).getWeaponDetails(weaponID);
            require(!_isEquipped, "already equipped");
            //equip the weapon
            IWeapon(weaponContract).equip(weaponID);
        }
        if (heroID > 0) {
            (string _hero, uint _intelligenceBonus, bool _isEquipped) = IHero(heroContract).getHeroDetails(heroID);
            require(!_isEquipped, "already equipped");
            //equip the hero
            IHero(heroContract).equip(heroID);
        }
        if (armorID > 0) {
            (string _armor, uint _armorBonus, bool _isEquipped) = IArmor(armorContract).getArmorDetails(armorID);
            require(!_isEquipped, "already equipped");
            //equip the hero
            IArmor(armorContract).equip(armorID);
        }
        //pay the fighter fee
        SafeERC20.safeTransferFrom(IERC20(par), from, treasury, fighterFee);
        //generate random hasing stuffs and code here
        //in and at get the bonus if they are equipping a weapon / hero
        //at the end generate and mint to the msg.sender our NFT Fighter!!!
        IFighter(fighterContract).createFighter(msg.sender, _hero, _weapon, _intelligence, _attack, _defense);
    }
    

    //does this need to have a whitelist of ppl who can start a parena?
    function prepParena(address _paymentToken, uint _entryFee, uint[] memory _rewardRates, uint _startTime, bool _singleEntry) public isOn {
        require(_startTime > block.timestamp);
        //need to sum up the reward rates to ensure they equal rewardSum
        uint totalRewards;
        for (uint16 i; i < _rewardRates.length; i++) {
            totalRewards += _rewardRates[i];
        }
        require(totalRewards == 100, "incorrect reward rates");
        _parenaIds.increment();
        uint _id = _parenaIds.current();
        parenas[_id] = Parena(_paymentToken, _entryFee, _rewardRates, [], _startTime, 0, _singleEntry, false, false);
        //emit event

    }


    //function for someone to actual enter their fighter into the parena
    function enterFighter(uint _parenaId, uint _figherId) public isOn {
        require(IFighter(fighterContract).ownerOf(_figherId) == msg.sender);
        Parena storage parena = parenas[_parenaId];
        require(parena.startTime >= block.timestamp, "already started");
        require(parena.fighters < maxFighters, "too many fighters");
        if (parena.singleEntry) {
            //check if this person has already entered
            require(!parena.entered[msg.sender], "already entered");
        }
        //pay the entry fee
        depositEntryFee(parena.paymentToken, msg.sender, parena.entryFee);
        parena.totalFighters++;
        parena.entered[msg.sender] = true; //this person has entered
        parena.alive[_figherId] = true; //this fighter has entered - mapped to the fighter NFT
        IFighter(fighterContract).enterIntoFight(_figherId);
        //emit event
    }

    function startParena(uint _parenaId) public isOn returns (uint _winner) {
        Parena storage parena = parenas[_parenaId];
        require(parena.startTime <= block.timestamp, "not yet time");
        require(parena.totalFighters % 2 == 0, "need even number of fighters");
        parena.started = true;
        //magic happens here somehow
    }

   


}
