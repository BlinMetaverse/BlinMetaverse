// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IMinable.sol";

contract SimpleCoinStaking is Ownable {
    struct Pool {
        string name;
        address addr;
        uint256 totalRate;
        uint256 totalRate7th;
        uint256 threshold; // for dropping blind box
        uint256 boxKind;
        uint256 accUP;
        uint256 totalStakes;
        uint256 last;
    }

    struct User {
        uint256 stakes;
        uint256 accUP;
        uint256 cache;
        uint256 got;
        uint256 started; // effective started for dropping
    }

    address private _blin;
    address private _nft;
    mapping(uint256 => Pool) private _pools;
    uint256[] private _poolIndexes;
    mapping(uint256 => mapping(address => User)) private _users;
    uint256 private _secPerDrop;
    uint256 private _normal;
    uint256 private _normalTimestamp;
    uint256 private _block7th;
    bool private _emergency;
    uint256[11] private _points;
    uint256[11] private _profits = [
        3607500,
        3246750,
        2922075,
        2629867,
        2366880,
        2130192,
        1917173,
        1725456,
        1552910,
        1397619,
        1257857
    ];

    constructor(
        address blin_,
        address nft_,
        uint256 secPerDrop_,
        uint256[] memory indexes,
        string[] memory names,
        address[] memory addresses,
        uint256[] memory totalRates,
        uint256[] memory totalRate7ths,
        uint256[] memory thresholds,
        uint256[] memory boxes,
        uint256[11] memory points
    ) {
        require(blin_ != address(0), "blin_ cannot be zero address");
        require(nft_ != address(0), "nft_ cannot be zero address");
        require(
            (indexes.length == names.length) &&
                (names.length == addresses.length) &&
                (addresses.length == totalRates.length) &&
                (totalRates.length == totalRate7ths.length) &&
                (totalRate7ths.length == thresholds.length) &&
                (thresholds.length == boxes.length) &&
                (boxes.length == points.length)
        );

        _blin = blin_;
        _nft = nft_;
        _secPerDrop = secPerDrop_;
        _points = points;

        uint256 sumOfTotalRate = 0;
        uint256 sumOfTotalRate7ths = 0;

        for (uint256 i = 0; i < indexes.length; i++) {
            uint256 index = indexes[i];
            _poolIndexes.push(index);

            Pool storage pool = _pools[index];
            pool.name = names[i];
            pool.addr = addresses[i];
            pool.totalRate = totalRates[i];
            pool.totalRate7th = totalRate7ths[i];
            pool.threshold = thresholds[i];
            pool.boxKind = boxes[i];

            sumOfTotalRate += totalRates[i];
            sumOfTotalRate7ths += totalRate7ths[i];
        }

        require(sumOfTotalRate == 100 && sumOfTotalRate7ths == 100);
    }

    function startNormal() public onlyOwner {
        require(_normal == 0, "already in normal");
        _normal = block.number;
        _normalTimestamp = block.timestamp;
        _block7th = _normal + 28800 * 7;

        for (uint256 i = 0; i < _points.length; i++) {
            _points[i] += _normal;
        }

        require(
            _block7th <= _points[0],
            "_block7th should not greater than _points[0]"
        );
    }

    function normal() public view returns (uint256, uint256) {
        return (_normal, _normalTimestamp);
    }

    function setPool(
        uint256 index,
        string memory name,
        address addr,
        uint256 threshold,
        uint256 boxKind
    ) public onlyOwner {
        require(index > 0, "require index > 0");
        require(bytes(name).length > 0, "name required");

        Pool storage pool = _pools[index];
        pool.name = name;
        pool.addr = addr;
        pool.threshold = threshold;
        pool.boxKind = boxKind;

        for (uint256 i = 0; i < _poolIndexes.length; i++) {
            if (_poolIndexes[i] == index) {
                return;
            }
        }
        _poolIndexes.push(index);
    }

    function setPoolRates(
        uint256[] memory indexes,
        uint256[] memory totalRate,
        uint256[] memory totalRate7th
    ) external onlyOwner {
        require(
            (indexes.length == totalRate.length) &&
                (totalRate.length == totalRate7th.length)
        );

        for (uint256 i = 0; i < indexes.length; i++) {
            Pool storage pool = _pools[indexes[i]];
            if (
                pool.totalRate == totalRate[i] &&
                pool.totalRate7th == totalRate7th[i]
            ) {
                continue;
            }

            pool.accUP = _nowAccUP(pool);
            pool.last = block.number;
            pool.totalRate = totalRate[i];
            pool.totalRate7th = totalRate7th[i];
        }
    }

    function setProfits(uint256[11] memory profits_) external onlyOwner {
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

    function stake(uint256 index, uint256 value) public payable {
        Pool storage pool = _pools[index];
        require(bytes(pool.name).length > 0, "pool not exists");

        if (pool.addr == address(0)) {
            value = msg.value;
        } else {
            require(
                IERC20(pool.addr).transferFrom(
                    msg.sender,
                    address(this),
                    value
                ),
                "fails to transfer token"
            );
        }

        require(value > 0, "requires value > 0");

        uint256 accUP = _nowAccUP(pool);
        User storage user = _users[index][msg.sender];
        user.cache += (user.stakes * (accUP - user.accUP)) / 10**24;
        user.stakes += value;
        user.accUP = accUP;

        pool.totalStakes += value;
        pool.accUP = accUP;
        pool.last = block.number;

        // for dropping
        if (
            _normal == 0 &&
            user.started == 0 &&
            pool.threshold > 0 &&
            pool.boxKind > 0 &&
            user.stakes >= pool.threshold
        ) {
            user.started = block.timestamp;
        }
    }

    function getUser(uint256 index, address account)
        public
        view
        returns (
            uint256 stakes,
            uint256 got,
            uint256 newReward,
            uint256 boxes
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
        boxes = user.started == 0
            ? 0
            : ((_normal == 0 ? block.timestamp : _normalTimestamp) -
                user.started) / _secPerDrop;
    }

    function claimBoxes(uint256 index, uint256 n) public {
        User storage user = _users[index][msg.sender];
        Pool storage pool = _pools[index];
        require(pool.boxKind > 0, "no box associated");

        uint256 boxes = user.started == 0
            ? 0
            : ((_normal == 0 ? block.timestamp : _normalTimestamp) -
                user.started) / _secPerDrop;
        require(n > 0 && n <= boxes, "param invalid");

        user.started += n * _secPerDrop;
        for (uint256 i = 0; i < n; i++) {
            IMinable(_nft).mint(msg.sender, pool.boxKind);
        }
    }

    function _nowAccUP(Pool storage pool) private view returns (uint256) {
        if (_normal == 0 || pool.totalStakes == 0) {
            return 0;
        }

        uint256 last = _normal > pool.last ? _normal : pool.last;
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
            if (i == 0) {
                if (last < _block7th) {
                    if (stop <= _block7th) {
                        profit =
                            ((stop - last) * _profits[i] * pool.totalRate) /
                            100;
                        break;
                    } else {
                        profit =
                            ((_block7th - last) *
                                _profits[i] *
                                pool.totalRate) /
                            100;
                        last = _block7th;
                    }
                }
            }

            if (point >= stop) {
                profit +=
                    ((stop - last) * _profits[i] * pool.totalRate7th) /
                    100;
                break;
            }

            profit += ((point - last) * _profits[i] * pool.totalRate7th) / 100;
            last = point;
        }

        return pool.accUP + (profit * 10**24) / pool.totalStakes;
    }

    function reward(uint256 index) public {
        require(!_emergency, "in emergency");

        User storage user = _users[index][msg.sender];
        Pool storage pool = _pools[index];
        uint256 accUP = _nowAccUP(pool);
        uint256 amount = (user.stakes * (accUP - user.accUP)) /
            10**24 +
            user.cache;
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

            uint256 amount = (user.stakes * (accUP - user.accUP)) /
                10**24 +
                user.cache;
            if (amount > 0) {
                IMinable(_blin).mint(msg.sender, amount);
            }
            pool.accUP = accUP;
            pool.last = block.number;
        }

        pool.totalStakes -= user.stakes;
        uint256 userStakes = user.stakes;
        delete _users[index][msg.sender];

        if (pool.addr == address(0)) {
            payable(msg.sender).transfer(userStakes);
        } else {
            require(
                IERC20(pool.addr).transfer(msg.sender, userStakes),
                "fails to transfer token"
            );
        }
    }

    function setBlin(address blin_) public onlyOwner {
        _blin = blin_;
    }

    function getBlin() public view returns (address) {
        return _blin;
    }

    function setNFT(address nft_) public onlyOwner {
        _nft = nft_;
    }

    function getNFT() public view returns (address) {
        return _nft;
    }

    function setEmergency(bool value) public onlyOwner {
        _emergency = value;
    }

    function getEmergency() public view returns (bool) {
        return _emergency;
    }
}
