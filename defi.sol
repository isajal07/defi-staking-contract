// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingContract {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public rewards;

    uint256 public totalStaked;

    uint256 public rewardRate;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRate
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
    }

    function setStakingToken(address _stakingToken) external {
        stakingToken = IERC20(_stakingToken);
    }

    function setRewardToken(address _rewardToken) external {
        rewardToken = IERC20(_rewardToken);
    }

    function setRewardRate(uint256 _rewardRate) external {
        rewardRate = _rewardRate;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            stakingToken.transferFrom(msg.sender, address(this), amount),
            "Failed to transfer staking tokens"
        );

        stakedAmount[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    function calculateReward(address user) public view returns (uint256) {
        return (stakedAmount[user] * rewardRate) / totalStaked;
    }

    function claimReward() external {
        uint256 reward = calculateReward(msg.sender);

        require(reward > 0, "No rewards to claim");

        rewards[msg.sender] += reward;

        require(
            rewardToken.transfer(msg.sender, reward),
            "Failed to transfer reward tokens"
        );

        emit RewardClaimed(msg.sender, reward);
    }

    function unstake() external {
        uint256 amount = stakedAmount[msg.sender];

        require(amount > 0, "No tokens staked");

        require(
            stakingToken.transfer(msg.sender, amount),
            "Failed to transfer staking tokens"
        );

        totalStaked -= amount;
        stakedAmount[msg.sender] = 0;

        emit Unstaked(msg.sender, amount);
    }
}
