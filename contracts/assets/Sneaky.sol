pragma solidity ^0.7.0;

import {SneakyAsset} from './SneakyAsset.sol';

contract Sneaky is SneakyAsset {
    constructor() SneakyAsset('Sneaky', 'SNKY') {}
}
