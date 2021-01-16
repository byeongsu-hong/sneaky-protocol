pragma solidity ^0.7.0;

interface IAuction {
    function maker() external view returns (address);

    function beneficiary() external view returns (address);

    function sneakersName() external view returns (string memory);

    function token() external view returns (address);

    function maxcap() external view returns (uint256);

    function remains() external view returns (uint256);

    function startTime() external view returns (uint256);

    function endTime() external view returns (uint256);

    function startPrice() external view returns (uint256);

    function endPrice() external view returns (uint256);

    function currentPrice() external view returns (uint256);

    function purchase() external;
}
