// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC20/IERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/ISwapRouter.sol";

contract NFT is ERC721, ERC721Burnable, Ownable {
    event MintOfKind(uint256 token, uint256 kind);
    event MintGlobal(uint256 token, uint256 kind);

    struct Kind {
        uint256 next;
        uint256 limit;
        uint256 minted;
        uint256 price;
    }

    address private _blin;
    address private _swap;
    address private _recipient;
    uint256 private _globalNext;
    mapping(uint256 => Kind) private _kinds;
    mapping(uint256 => uint256) private _tokenToKind;
    mapping(uint256 => bool) private _nonces;
    mapping(address => bool) private _miners;

    constructor(
        address blin_,
        address swap_,
        address recipient_,
        uint256 globalNext_,
        uint256[] memory ids,
        uint256[] memory from,
        uint256[] memory limits,
        uint256[] memory prices
    ) ERC721("Metaverse NFT", "NFT") {
        _blin = blin_;
        _swap = swap_;
        _recipient = recipient_;
        _globalNext = globalNext_;

        for (uint256 i = 0; i < ids.length; i++) {
            Kind storage kind = _kinds[ids[i]];
            kind.next = from[i];
            kind.limit = limits[i];
            kind.price = prices[i];
        }
    }

    function setKind(
        uint256 id,
        uint256 from,
        uint256 limit,
        uint256 price
    ) public onlyOwner {
        require(id > 0, "requires id > 0");
        require(price > 0, "price must larger than 0");

        Kind storage kind = _kinds[id];
        require(limit >= kind.minted, "limit must larger than minted");
        if (kind.price == 0) {
            kind.next = from;
        }

        kind.limit = limit;
        kind.price = price;
    }

    /**
     * call this method only if you know what you do!
     */
    function setKindNext(uint256 id, uint256 next) public onlyOwner {
        Kind storage kind = _kinds[id];
        kind.next = next;
    }

    function getKind(uint256 id) public view returns (Kind memory) {
        Kind storage kind = _kinds[id];
        return kind;
    }

    function getKindByToken(uint256 token) public view returns (uint256) {
        return _tokenToKind[token];
    }

    function setBlin(address blin_) public onlyOwner {
        _blin = blin_;
    }

    function getBlin() public view returns (address) {
        return _blin;
    }

    function setSwap(address swap_) public onlyOwner {
        _swap = swap_;
    }

    function getSwap() public view returns (address) {
        return _swap;
    }

    function setRecipient(address recipient_) public onlyOwner {
        require(recipient_ != address(0), "cannot be zero address");
        _recipient = recipient_;
    }

    function getRecipient() public view returns (address) {
        return _recipient;
    }

    function setMiner(address account, bool allow) public onlyOwner {
        _miners[account] = allow;
    }

    function getMiner(address account) public view returns (bool) {
        return _miners[account];
    }

    function _seekId(uint256 next) internal returns (uint256) {
        for (uint256 i = 0; i < 100; i++) {
            if (_tokenToKind[next] == 0) {
                break;
            }
            next += 1;
        }
        return next;
    }

    function mint(address to, uint256 kindID) public payable {
        mint(to, kindID, 1);
    }

    function mint(
        address to,
        uint256 kindID,
        uint256 amount
    ) public payable {
        require(amount > 0, "amount must larger than 0");

        Kind storage kind = _kinds[kindID];
        uint256 minted = kind.minted + amount;
        require(minted <= kind.limit, "kind limit reached");
        kind.minted = minted;

        if (msg.sender != owner() && !_miners[msg.sender]) {
            require(msg.value >= kind.price * amount, "insufficient value");
            payable(owner()).transfer(msg.value);
        }

        uint256 next = kind.next == 0 ? _globalNext : kind.next;

        for (uint256 i = 0; i < amount; i++) {
            next = _seekId(next);
            _safeMint(to, next);
            emit MintOfKind(next, kindID);

            _tokenToKind[next] = kindID;
            next += 1;
        }

        if (kind.next == 0) {
            _globalNext = next;
        } else {
            kind.next = next;
        }
    }

    function mintBeauty(
        address to,
        uint256 kindID,
        uint256 id
    ) public onlyOwner {
        Kind storage kind = _kinds[kindID];
        require(kind.minted < kind.limit, "kind limit reached");
        if (kind.next > 0) {
            require(
                id >= kind.next && id < kind.next - kind.minted + kind.limit,
                "id out of range"
            );
        }
        require(_tokenToKind[id] == 0, "id exists");
        kind.minted += 1;

        _safeMint(to, id);
        emit MintOfKind(id, kindID);

        _tokenToKind[id] = kindID;
    }

    /**
     * mints normal NFT
     */
    function mint(
        address to,
        uint256 kind,
        uint256 amount,
        uint256 deadline,
        uint256 nonce,
        bytes memory signature
    ) public {
        require(deadline >= block.timestamp, "parameters expired");
        require(!_nonces[nonce], "nonce not available");
        _nonces[nonce] = true;

        _checkSignature(
            abi.encodePacked(msg.sender, to, kind, amount, deadline, nonce),
            signature
        );

        for (uint256 i = 0; i < amount; i++) {
            _mintGlobal(to, kind);
        }
    }

    function openBlindBox(
        address to,
        uint256 id,
        uint256 toKind,
        uint256 deadline,
        bytes memory signature
    ) public {
        require(deadline >= block.timestamp, "parameters expired");
        _checkSignature(abi.encodePacked(to, id, toKind, deadline), signature);

        require(
            _isApprovedOrOwner(msg.sender, id),
            "caller is not owner nor approved"
        );
        _burn(id);

        _mintGlobal(to, toKind);
    }

    function upgradeNFT(
        address to,
        uint256 id,
        uint256 toKind,
        uint256 deadline,
        bytes memory signature
    ) public {
        require(deadline >= block.timestamp, "parameters expired");
        _checkSignature(abi.encodePacked(to, id, toKind, deadline), signature);

        Kind storage kind = _kinds[toKind];
        require(kind.price > 0, "requirs price > 0");

        // pay
        uint256 expect = (kind.price * 7) / 10;
        address[] memory path = new address[](2);
        path[0] = ISwapRouter(_swap).WETH();
        path[1] = _blin;
        uint256[] memory amounts =
            ISwapRouter(_swap).getAmountsOut(expect, path);
        IERC20(_blin).transferFrom(msg.sender, _recipient, amounts[1]);

        require(
            _isApprovedOrOwner(msg.sender, id),
            "caller is not owner nor approved"
        );
        _burn(id);

        _mintGlobal(to, toKind);
    }

    function compound(
        address to,
        uint256[] memory ids,
        uint256 toKind,
        uint256 deadline,
        bytes memory signature
    ) public {
        require(deadline >= block.timestamp, "parameters expired");
        _checkSignature(abi.encodePacked(to, ids, toKind, deadline), signature);

        for (uint256 i = 0; i < ids.length; i++) {
            require(
                _isApprovedOrOwner(msg.sender, ids[i]),
                "caller is not owner nor approved"
            );
            _burn(ids[i]);
        }

        _mintGlobal(to, toKind);
    }

    function _mintGlobal(address to, uint256 kind) internal {
        _globalNext = _seekId(_globalNext);
        _tokenToKind[_globalNext] = kind;
        _safeMint(to, _globalNext);
        emit MintGlobal(_globalNext, kind);

        _globalNext += 1;
    }

    function _checkSignature(bytes memory packed, bytes memory signature)
        internal
        view
    {
        // this recreates the message that was signed on the client
        bytes32 message = ECDSA.toEthSignedMessageHash(keccak256(packed));
        require(
            ECDSA.recover(message, signature) == owner(),
            "signature invalid"
        );
    }
}
