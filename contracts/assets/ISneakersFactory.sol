pragma solidity ^0.7.0;

interface ISneakersFactory {
    function getSneakers(string memory name, uint256 size)
        external
        view
        returns (address);

    function allSneakers(uint256 index) external view returns (address);

    function allSneakersLength() external view returns (uint256);

    function createSneakers(string memory name, uint256 size)
        external
        returns (address);

    function makeSneakers(
        address coupon,
        uint256 size,
        uint256 amount,
        address to
    ) external;
}
