// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRewardHook {
    function onReward(address user, uint256 amount) external;
}

/// @title Vault
/// @notice ETH vault with deposits, transfers, and a rewards system.
/// @dev Rewards are credited by the owner and claimed by users. An optional
///      reward hook is notified when users claim.
contract Vault {
    address public owner;
    address public rewardHook;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public rewards;
    uint256 public totalDeposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        require(msg.value > 0, "zero deposit");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        emit Withdraw(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function setRewardHook(address hook) external {
        rewardHook = hook;
    }

    function setRewards(address user, uint256 amount) external onlyOwner {
        rewards[user] = amount;
    }

    function claimRewards() external {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "no rewards");

        if (rewardHook != address(0)) {
            IRewardHook(rewardHook).onReward(msg.sender, reward);
        }

        balances[msg.sender] += reward;
        rewards[msg.sender] = 0;
        emit RewardClaimed(msg.sender, reward);
    }

    function emergencyWithdraw(address payable to) external onlyOwner {
        uint256 bal = address(this).balance;
        (bool ok, ) = to.call{value: bal}("");
        require(ok, "emergency transfer failed");
    }
}
