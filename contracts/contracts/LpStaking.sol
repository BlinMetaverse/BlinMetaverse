// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IMinable.sol";
import "../interfaces/IScStaking.sol";

contract LpStaking is Ownable {
    struct Pool {
        string name;
        address addr;
        uint256 totalRate;
        uint256 accUP;
        uint256 totalStakes;
        uint256 last;
    }

    struct User {
        uint256 stakes;
        uint256 accUP;
        uint256 cache;
        uint256 got;
    }

    address private _blin;
    address private _scStaking;
    mapping(uint256 => Pool) private _pools;
    uint256[] private _poolIndexes;
    mapping(uint256 => mapping(address => User)) private _users;
    uint256 private _started;
    bool private _emergency;
    uint256[11] private _points;
    uint256[11] private _profits = [
        24142500,
        21728250,
        19555424,
        17599882,
        15839894,
        14255904,
        12830314,
        11547282,
        10392554,
        9353298,
        8417968
    ];

    constructor(
        address blin_,
        address scStaking_,
        uint256[] memory indexes,
        string[] memory names,
        address[] memory addresses,
        uint256[] memory totalRates,
        uint256[11] memory points
    ) {
        _points = points;

        _blin = blin_;
        _scStaking = scStaking_;

        for (uint256 i = 0; i < indexes.length; i++) {
            uint256 index = indexes[i];
            _poolIndexes.push(index);

            Pool storage pool = _pools[index];
            pool.name = names[i];
            pool.addr = addresses[i];
            pool.totalRate = totalRates[i];
        }
    }

    function syncStarted() public onlyOwner {
        require(_started == 0, "already started");

        (uint256 startBlock, uint256 timestamp) =
            IScStaking(_scStaking).normal();
        require(startBlock > 0, "unable to sync");

        _started = startBlock;

        for (uint256 i = 0; i < _points.length; i++) {
            _points[i] += _started;
        }
    }

    function started() public view returns (uint256) {
        return _started;
    }

    function setPool(
        uint256 index,
        string memory name,
        address addr
    ) public onlyOwner {
        require(index > 0, "require index > 0");
        require(bytes(name).length > 0, "name required");

        Pool storage pool = _pools[index];
        pool.name = name;
        pool.addr = addr;

        for (uint256 i = 0; i < _poolIndexes.length; i++) {
            if (_poolIndexes[i] == index) {
                return;
            }
        }
        _poolIndexes.push(index);
    }

    function setPoolRates(uint256[] memory indexes, uint256[] memory totalRate)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < indexes.length; i++) {
            Pool storage pool = _pools[indexes[i]];
            if (pool.totalRate == totalRate[i]) {
                continue;
            }

            pool.accUP = _nowAccUP(pool);
            pool.last = block.number;
            pool.totalRate = totalRate[i];
        }
    }

    function setProfits(uint256[11] memory profits_) public onlyOwner {
        for (uint256 i = 0; i < _poolIndexes.length; i++) {
            uint256 index = _poolIndexes[i];
            if (index == 0) {
                continue;
            }
            Pool storage pool = _pools[index];
            pool.accUP = _nowAccUP(pool);
            pool.last = block.number;
        }

        _profits = profits_;
    }

    function delPool(uint256 index) public onlyOwner {
        Pool storage pool = _pools[index];
        require(bytes(pool.name).length > 0, "pool not exists");

        delete _pools[index];
        for (uint256 i = 0; i < _poolIndexes.length; i++) {
            if (_poolIndexes[i] == index) {
                delete _poolIndexes[i];
            }
        }
    }

    function getPoolIndexes() public view returns (uint256[] memory) {
        return _poolIndexes;
    }

    function getPools(uint256[] memory indexes)
        public
        view
        returns (Pool[] memory)
    {
        Pool[] memory pools = new Pool[](indexes.length);
        for (uint256 i = 0; i < indexes.length; i++) {
            pools[i] = _pools[indexes[i]];
        }
        return pools;
    }

    function getPool(uint256 index) public view returns (Pool memory) {
        return _pools[index];
    }

    function stake(uint256 index, uint256 value) public {
        require(_started > 0, "pending start");
        require(value > 0, "requires value > 0");

        Pool storage pool = _pools[index];
        require(bytes(pool.name).length > 0, "pool not exists");

        IERC20(pool.addr).transferFrom(msg.sender, address(this), value);

        uint256 accUP = _nowAccUP(pool);
        User storage user = _users[index][msg.sender];
        user.cache += (user.stakes * (accUP - user.accUP)) / 10**24;
        user.stakes += value;
        user.accUP = accUP;

        pool.totalStakes += value;
        pool.accUP = accUP;
        pool.last = block.number;
    }

    function getUser(uint256 index, address account)
        public
        view
        returns (
            uint256 stakes,
            uint256 got,
            uint256 newReward
        )
    {
        User storage user = _users[index][account];
        Pool storage pool = _pools[index];
        stakes = user.stakes;
        got = user.got;
        newReward = _emergency
            ? 0
            : (user.stakes * (_nowAccUP(pool) - user.accUP)) /
                10**24 +
                user.cache;
    }

    function _nowAccUP(Pool storage pool) private view returns (uint256) {
        if (pool.totalStakes == 0) {
            return 0;
        }

        uint256 last = pool.last;
        uint256 stop = _points[_points.length - 1];
        if (stop > block.number) {
            stop = block.number;
        }

        uint256 profit = 0;
        for (uint256 i = 0; i < _points.length; i++) {
            uint256 point = _points[i];
            if (point <= last) {
                continue;
            }

            if (point >= stop) {
                profit += ((stop - last) * _profits[i] * pool.totalRate) / 100;
                break;
            }

            profit += ((point - last) * _profits[i] * pool.totalRate) / 100;
            last = point;
        }

        return pool.accUP + (profit * 10**24) / pool.totalStakes;
    }

    function reward(uint256 index) public {
        require(!_emergency, "in emergency");

        User storage user = _users[index][msg.sender];
        Pool storage pool = _pools[index];
        uint256 accUP = _nowAccUP(pool);
        uint256 amount =
            (user.stakes * (accUP - user.accUP)) / 10**24 + user.cache;
        require(amount > 0, "no reward");

        user.got += amount;
        user.cache = 0;
        user.accUP = accUP;

        pool.accUP = accUP;
        pool.last = block.number;

        IMinable(_blin).mint(msg.sender, amount);
    }

    function redeem(uint256 index) public {
        User storage user = _users[index][msg.sender];
        require(user.stakes > 0, "no stake");

        Pool storage pool = _pools[index];

        if (!_emergency) {
            uint256 accUP = _nowAccUP(pool);

            uint256 amount =
                (user.stakes * (accUP - user.accUP)) / 10**24 + user.cache;
            if (amount > 0) {
                IMinable(_blin).mint(msg.sender, amount);
            }
            pool.accUP = accUP;
            pool.last = block.number;
        }

        pool.totalStakes -= user.stakes;

        IERC20(pool.addr).transfer(msg.sender, user.stakes);

        delete _users[index][msg.sender];
    }

    function setBlin(address blin_) public onlyOwner {
        _blin = blin_;
    }

    function getBlin() public view returns (address) {
        return _blin;
    }

    function setEmergency(bool value) public onlyOwner {
        _emergency = value;
    }

    function getEmergency() public view returns (bool) {
        return _emergency;
    }
}
