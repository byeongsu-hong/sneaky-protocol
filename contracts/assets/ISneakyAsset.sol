pragma solidity ^0.7.0;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface ISneakyAsset is IERC20 {
    function mint(address recipient, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;

    function factory() external view returns (address);
}
