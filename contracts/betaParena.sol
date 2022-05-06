/* THIS Contract will be the first iteration at Parena - not integrating NFTS
 * The point of this contract is to test out parena on-chain with the Boba Network off-chain oracle
 * and to test the hypothesis that people want to play a parena with metamask
 * and pay and entry fee to join
 * assuming this Beta works well, then the full NFT build will be completed
 */

 // SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;


//import statements
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./bobaTuring/TuringHelper.sol";
import "./interfaces/IBetaParena.sol";


contract BetaParena is Ownable, ReentrancyGuard, IBetaParena {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    Counters.Counter private parenaIds;

    address payable public treasury;
    uint256 public fee;

    constructor(address payable _treasury, uint256 _fee) {
        treasury = _treasury;
        fee = _fee;
    }
    
    enum Status {
        Open,
        Battling,
        Closed
    }

    struct Parena {
        address admin;
        uint256 entryFee;
        uint256 collectedFees;
        address entryToken;
        uint256 firstPayout;
        address firstPlace;
        uint256 secondPayout;
        address secondPlace;
        uint256 thirdPayout;
        address thirdPlace;
        uint256 adminPayout;
        Status status;
        address[] entrants;
    }

    /// @notice maps the parenaId to each Parena
    mapping (uint256 => Parena) public parenas;

    function payFees(uint256 _parenaId, address from) internal returns (bool) {
        Parena memory parena = parenas[_parenaId];
        /// @dev pay the treasury the mint fee
        require(msg.value == fee, "wrong fee amount");
        (bool success, ) = treasury.call{value: fee}('');
        require(success, "treasury not paid");
        /// @dev transfer the entry fee here
        uint256 priorBalance = IERC20(parena.entryToken).balanceOf(address(this));
        require(IERC20(parena.entryToken).balanceOf(msg.sender) >= parena.entryFee, 'not enough for entry fee');
        SafeERC20.safeTransferFrom(IERC20(parena.entryToken), from, address(this), parena.entryFee);
        uint256 postBalance = IERC20(parena.entryToken).balanceOf(address(address(this)));
        require(postBalance - priorBalance == parena.entryFee, 'deflation issue');
        /// @dev add the fee to the collection storage
        Parena storage _parena = parenas[_parenaId];
        _parena.collectedFees += parena.entryFee;
        return true;
    }

    function payoutWinnings(uint256 _parenaId) internal {
        Parena memory parena = parenas[_parenaId];
        uint256 _firstPayout = parena.collectedFees * parena.firstPayout / 100;
        uint256 _secondPayout = parena.collectedFees * parena.secondPayout / 100;
        uint256 _thirdPayout = parena.collectedFees * parena.thirdPayout / 100;
        uint256 _adminPayout = parena.collectedFees * parena.adminPayout / 100;
        SafeERC20.safeTransfer(IERC20(parena.entryToken), parena.firstPlace, _firstPayout);
        SafeERC20.safeTransfer(IERC20(parena.entryToken), parena.secondPlace, _secondPayout);
        SafeERC20.safeTransfer(IERC20(parena.entryToken), parena.thirdPlace, _thirdPayout);
        SafeERC20.safeTransfer(IERC20(parena.entryToken), parena.admin, _adminPayout);
    }

    /// @notice function for someone to create a new Parena, they become the admin
    function createParena(
        uint256 entryFee,
        address entryToken,
        uint256 firstPayout,
        uint256 secondPayout,
        uint256 thirdPayout,
        uint256 adminPayout
    ) public {
        parenaIds.increment();
        uint256 parenaId = parenaIds.current();
        require(firstPayout + secondPayout + thirdPayout + adminPayout == 100, "does not add up to 100");
        parenas[parenaId] = Parena(msg.sender, entryFee, entryToken, firstPayout, address(0), secondPayout, address(0), thirdPayout, address(0), adminPayout, Status.Open);
        emit ParenaCreated(parenaId, msg.sender, entryFee, 0, entryToken, firstPayout, secondPayout, thirdPayout, adminPayout);
    }

    /// @notice function for someone to enter, they will pay the fee to the treasury and entry fee and then wallet is entered
    function enterParena(uint256 _parenaId) public {
        Parena storage parena = parenas[_parenaId];
        require(parena.status == Status.Open, "not open");
        bool success = payFees(_parenaId, msg.sender);
        require(success, "fees aint paid");
        /// @dev add them to the list of entrants
        parena.entrants.push(msg.sender);
        FighterEntered(_parenaId, msg.sender);
    }

    function startParena(uint256 _parenaId) public {
        Parena storage parena = parenas[_parenaId];
        require(msg.sender == parena.admin, "only admin");
        require(parena.status == Status.Open, "not open");
        parena.status = Status.Battling;
        emit ParenaStarted(_parenaId);
    }

    function payoutParena(uint256 _parenaId) public {
        Parena storage parena = parenas[_parenaId];
        require(msg.sender == parena.admin);
        require(parena.status == Status.Battling);
        parena.status = Status.Closed;
        /// @dev get the winners from the api Call here
        // api call - getWinners()
       (_firstPlace, _secondPlace, _thirdPlace) = api.getWinners();
         // update winners
        parena.firstPlace = _firstPlace;
        parena.secondPlace = _secondPlace;
        parena.thirdPlace = _thirdPlace;
        payoutWinnings(_parenaId);
        emit ParenaEnded(_parenaId, _firstPlace, _secondPlace, _thirdPlace);
    }

    event ParenaCreated(
        uint256 _parenaId,
        address _admin,
        uint256 _entryFee,
        address _entryToken,
        uint256 _firstPayout,
        uint256 _secondPayout,
        uint256 _thirdPayout,
        uint256 _adminPayout
        );
    event FighterEntered(uint256 _parenaId, address _fighter);
    event ParenaStarted(uint256 _parenaId);
    event ParenaEnded(uint256 _parenaId, address _firstPlace, address _secondPlace, address _thirdPlace);
}