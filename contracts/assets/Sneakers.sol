pragma solidity ^0.7.0;

import {SneakyAsset} from './SneakyAsset.sol';

contract Sneakers is SneakyAsset {
    uint256 public size;
    bool private initialized = false;

    constructor() SneakyAsset('Sneakers', 'SNKS') {}

    function initialize(uint256 _size) public {
        require(!initialized, 'Sneakers: initialized');
        initialized = !initialized;

        size = _size;
    }
}
