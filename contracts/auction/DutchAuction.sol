pragma solidity ^0.7.0;

import {Math} from '@openzeppelin/contracts/math/Math.sol';
import {SafeMath} from '@openzeppelin/contracts/math/SafeMath.sol';
import {
    ERC20,
    ERC20Burnable
} from '@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';

import {IAuction} from './IAuction.sol';

contract DutchAuction is IAuction, ERC20Burnable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event SneakersPurchased(
        address indexed buyer,
        uint256 amount,
        uint256 price
    );

    event BeneficiaryChanged(
        address indexed operator,
        address oldBeneficiary,
        address newBeneficiary
    );

    address public factory;
    address public immutable override maker;
    address public override beneficiary;

    string public override sneakersName;
    address public immutable override token;
    uint256 public override maxcap;
    uint256 public override remains;

    uint256 public immutable override startTime;
    uint256 public immutable override auctionEnds;
    uint256 public immutable override tradingEnds;
    uint256 public immutable override startPrice;
    uint256 public immutable override endPrice;

    constructor(
        address _factory,
        address _maker,
        address _beneficiary,
        string memory _sneakersName,
        address _token,
        uint256 _amount,
        uint256 _startTime,
        uint256 _auctionPeriod,
        uint256 _tradingPeriod,
        uint256 _startPrice,
        uint256 _endPrice
    ) ERC20('Sneaky Coupon', 'SNKC') {
        factory = _factory;
        maker = _maker;
        beneficiary = _beneficiary;

        // reserve
        sneakersName = _sneakersName;
        token = _token;
        maxcap = _amount;
        remains = _amount;

        // params
        require(
            _startTime > block.timestamp,
            'DutchAuction: _startTime > block.timestamp'
        );
        startTime = _startTime;
        auctionEnds = _startTime.add(_auctionPeriod);
        tradingEnds = _startTime.add(_auctionPeriod).add(_tradingPeriod);

        require(
            _startPrice > _endPrice,
            'DutchAuction: _startPrice > _endPrice'
        );
        startPrice = _startPrice;
        endPrice = _endPrice;

        _setupDecimals(1);
    }

    modifier checkExpiry(address recipient) {
        if (block.timestamp > tradingEnds) {
            require(recipient == factory, 'DutchAuction: token expired');
        }

        _;
    }

    function currentPrice() public view override returns (uint256) {
        uint256 period = auctionEnds.sub(startTime);
        uint256 pricegap = startPrice.sub(endPrice);
        uint256 gradient = pricegap.mul(1e18).div(period);

        uint256 elapsed =
            block.timestamp.sub(Math.min(block.timestamp, startTime));
        return startPrice.sub(gradient.mul(elapsed).div(1e18));
    }

    function purchase() public override {
        require(block.timestamp >= startTime, 'DutchAuction: not started');
        require(block.timestamp <= auctionEnds, 'DutchAuction: finished');
        require(remains > 0, 'DutchAuction: sold out');

        remains = remains.sub(1);

        uint256 price = currentPrice();
        IERC20(token).safeTransferFrom(msg.sender, beneficiary, price);
        _mint(msg.sender, 1);

        emit SneakersPurchased(msg.sender, 1, price);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address owner,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        return super.transferFrom(owner, recipient, amount);
    }

    function changeBeneficiary(address newBeneficiary) public {
        require(msg.sender == beneficiary, 'DutchAuction: nope');
        address oldBeneficiary = beneficiary;
        beneficiary = newBeneficiary;
        emit BeneficiaryChanged(msg.sender, oldBeneficiary, newBeneficiary);
    }
}
