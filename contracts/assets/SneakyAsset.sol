pragma solidity ^0.7.0;

import {
    ERC20,
    ERC20Burnable
} from '@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol';

import {ISneakyAsset} from './ISneakyAsset.sol';

contract SneakyAsset is ISneakyAsset, ERC20Burnable {
    address public immutable override factory;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        factory = msg.sender;
        _setupDecimals(1);
    }

    function mint(address recipient_, uint256 amount_)
        public
        override
        returns (bool)
    {
        require(
            msg.sender == factory,
            'SneakyAsset: only factory can do this job'
        );
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);

        return balanceAfter > balanceBefore;
    }

    function burn(uint256 amount) public override(ISneakyAsset, ERC20Burnable) {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        override(ISneakyAsset, ERC20Burnable)
    {
        super.burnFrom(account, amount);
    }
}
