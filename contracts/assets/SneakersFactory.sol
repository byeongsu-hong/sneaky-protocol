pragma solidity ^0.7.0;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {
    ERC20Burnable
} from '@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol';

import {Sneakers} from './Sneakers.sol';
import {ISneakyAsset} from './ISneakyAsset.sol';
import {ISneakersFactory} from './ISneakersFactory.sol';
import {IAuction} from '../auction/IAuction.sol';

contract SneakersFactory is ISneakersFactory, Ownable {
    event SneakersCreated(
        address indexed operator,
        address indexed sneakers,
        string name,
        uint256 size
    );

    event SneakersMinted(
        address indexed operator,
        address indexed sneakers,
        string name,
        uint256 size
    );

    uint256 public constant MAX_SIZE = 290;
    uint256 public constant MIN_SIZE = 220;

    mapping(bytes32 => address) public sneakersRegistry;
    address[] public override allSneakers;

    constructor() Ownable() {}

    function allSneakersLength() public view override returns (uint256) {
        return allSneakers.length;
    }

    function getSneakers(string memory name, uint256 size)
        public
        view
        override
        returns (address)
    {
        return sneakersRegistry[keccak256(abi.encodePacked(name, size))];
    }

    function getSneakersBytecode() public pure returns (bytes memory) {
        return type(Sneakers).creationCode;
    }

    function createSneakers(string memory name, uint256 size)
        public
        override
        returns (address)
    {
        require(size >= MIN_SIZE, 'min');
        require(size <= MAX_SIZE, 'max');
        require(size % 5 == 0, 'mod');

        bytes memory bytecode = getSneakersBytecode();
        bytes32 salt = keccak256(abi.encodePacked(name, size));

        address sneakers;

        assembly {
            sneakers := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Sneakers(sneakers).initialize(size);

        sneakersRegistry[salt] = sneakers;

        emit SneakersCreated(msg.sender, sneakers, name, size);
        return sneakers;
    }

    function makeSneakers(
        address coupon,
        uint256 size,
        uint256 amount,
        address to
    ) public override onlyOwner {
        string memory name = IAuction(coupon).sneakersName();

        address sneakers = getSneakers(name, size);
        if (sneakers == address(0x0)) {
            sneakers = createSneakers(name, size);
        }

        ERC20Burnable(coupon).burnFrom(msg.sender, amount);
        Sneakers(sneakers).mint(to, amount);
        emit SneakersMinted(msg.sender, sneakers, name, size);
    }
}
