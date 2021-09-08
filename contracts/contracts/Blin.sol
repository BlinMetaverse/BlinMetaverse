// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/access/Ownable.sol";

contract Blin is ERC20, ERC20Burnable, Ownable {
    mapping(address => bool) private _miners;

    constructor() ERC20("Blin Metaverse", "BLIN") {
        _mint(0xd811e77Be6607aa12B5DC889f54C09b8bf940eCB, 420_0000 * 1e8);
        _mint(0x57d2f802580182F0691EbEBE8D9ade80628c617F, 210_0000 * 1e8);
        _mint(0x9fd126f42D5fD007b28c8497824FcDc4FC25a3E2, 210_0000 * 1e8);
    }

    function decimals() public pure override returns (uint8) {
        return 8;
    }

    function mint(address to, uint256 amount) public {
        require(
            msg.sender == owner() || _miners[msg.sender],
            "caller must be a miner"
        );
        _mint(to, amount);
    }

    function setMiner(address account, bool allow) public onlyOwner {
        _miners[account] = allow;
    }

    function getMiner(address account) public view returns (bool) {
        return _miners[account];
    }
}
