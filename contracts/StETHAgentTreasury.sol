// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title StETHAgentTreasury
 * @notice Yield-powered treasury for AI agents using stETH
 * @dev Agents can earn yield on stETH while maintaining principal protection
 */
contract StETHAgentTreasury is ReentrancyGuard {
    
    // stETH token address on Ethereum mainnet
    address public constant STETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    
    // WstETH for easier balance tracking
    address public constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    
    struct Treasury {
        uint256 stETHBalance;      // Principal in stETH
        uint256 yieldAccumulated;   // Accumulated yield
        uint256 lastYieldUpdate;    // Last yield calculation timestamp
        address agent;              // Agent managing this treasury
        bool isActive;
    }
    
    struct WithdrawalRequest {
        bytes32 id;
        address agent;
        uint256 amount;
        uint256 requestedAt;
        bool isYield;              // True if withdrawing yield only
        bool executed;
    }
    
    // State
    mapping(address => Treasury) public treasuries;
    mapping(bytes32 => WithdrawalRequest) public withdrawalRequests;
    mapping(address => bytes32[]) public agentWithdrawals;
    
    address public owner;
    uint256 public totalTreasuryBalance;
    uint256 public totalYieldGenerated;
    uint256 public withdrawalCount;
    
    // Yield protection: minimum principal that cannot be withdrawn
    uint256 public constant MIN_PRINCIPAL = 0.1 ether; // 0.1 stETH minimum
    
    event TreasuryCreated(address indexed agent, uint256 initialDeposit);
    event YieldAccumulated(address indexed agent, uint256 yieldAmount);
    event WithdrawalRequested(bytes32 indexed requestId, address agent, uint256 amount, bool isYield);
    event WithdrawalExecuted(bytes32 indexed requestId, address to, uint256 amount);
    event PrincipalProtected(address indexed agent, uint256 protectedAmount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier onlyAgent(address _agent) {
        require(treasuries[_agent].agent == msg.sender, "Not authorized agent");
        require(treasuries[_agent].isActive, "Treasury not active");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @notice Create a new treasury for an agent
     * @param agent Agent address
     * @param initialDeposit Initial stETH deposit
     */
    function createTreasury(
        address agent,
        uint256 initialDeposit
    ) external onlyOwner nonReentrant {
        require(agent != address(0), "Invalid agent address");
        require(treasuries[agent].agent == address(0), "Treasury exists");
        require(initialDeposit >= MIN_PRINCIPAL, "Below minimum principal");
        
        // Transfer stETH from owner
        IERC20(STETH).transferFrom(msg.sender, address(this), initialDeposit);
        
        treasuries[agent] = Treasury({
            stETHBalance: initialDeposit,
            yieldAccumulated: 0,
            lastYieldUpdate: block.timestamp,
            agent: agent,
            isActive: true
        });
        
        totalTreasuryBalance += initialDeposit;
        
        emit TreasuryCreated(agent, initialDeposit);
        emit PrincipalProtected(agent, initialDeposit);
    }
    
    /**
     * @notice Update yield for an agent's treasury
     * @dev Calculates yield based on stETH rebasing
     */
    function updateYield(address agent) public {
        require(agent != address(0), "Invalid agent address");
        
        Treasury storage treasury = treasuries[agent];
        require(treasury.isActive, "Treasury not active");
        
        // Get current stETH balance
        uint256 currentBalance = IERC20(STETH).balanceOf(address(this));
        
        // Calculate total yield (simplified - in production would track per-treasury)
        if (currentBalance > totalTreasuryBalance) {
            uint256 totalYield = currentBalance - totalTreasuryBalance;
            
            // Distribute yield proportionally
            uint256 agentShare = (totalYield * treasury.stETHBalance) / totalTreasuryBalance;
            
            treasury.yieldAccumulated += agentShare;
            totalYieldGenerated += agentShare;
        }
        
        treasury.lastYieldUpdate = block.timestamp;
        
        emit YieldAccumulated(agent, treasury.yieldAccumulated);
    }
    
    /**
     * @notice Request withdrawal of yield only (principal protected)
     * @param agent Agent address
     * @param amount Amount to withdraw
     */
    function requestYieldWithdrawal(
        address agent,
        uint256 amount
    ) external onlyAgent(agent) returns (bytes32 requestId) {
        require(agent != address(0), "Invalid agent address");
        
        Treasury storage treasury = treasuries[agent];
        
        // Update yield first
        updateYield(agent);
        
        require(treasury.yieldAccumulated >= amount, "Insufficient yield");
        
        requestId = keccak256(abi.encode(
            agent,
            amount,
            block.timestamp,
            withdrawalCount,
            msg.sender
        ));
        
        withdrawalRequests[requestId] = WithdrawalRequest({
            id: requestId,
            agent: agent,
            amount: amount,
            requestedAt: block.timestamp,
            isYield: true,
            executed: false
        });
        
        agentWithdrawals[agent].push(requestId);
        withdrawalCount++;
        
        // Deduct from accumulated yield
        treasury.yieldAccumulated -= amount;
        
        emit WithdrawalRequested(requestId, agent, amount, true);
    }
    
    /**
     * @notice Request withdrawal of principal (requires cooldown)
     * @param agent Agent address
     * @param amount Amount to withdraw
     */
    function requestPrincipalWithdrawal(
        address agent,
        uint256 amount
    ) external onlyOwner returns (bytes32 requestId) {
        require(agent != address(0), "Invalid agent address");
        
        Treasury storage treasury = treasuries[agent];
        
        require(treasury.stETHBalance - amount >= MIN_PRINCIPAL, "Would breach minimum principal");
        
        requestId = keccak256(abi.encode(
            agent,
            amount,
            block.timestamp,
            withdrawalCount,
            msg.sender
        ));
        
        withdrawalRequests[requestId] = WithdrawalRequest({
            id: requestId,
            agent: agent,
            amount: amount,
            requestedAt: block.timestamp,
            isYield: false,
            executed: false
        });
        
        agentWithdrawals[agent].push(requestId);
        withdrawalCount++;
        
        emit WithdrawalRequested(requestId, agent, amount, false);
    }
    
    /**
     * @notice Execute a withdrawal request
     * @param requestId Request ID
     * @param to Recipient address
     */
    function executeWithdrawal(
        bytes32 requestId,
        address to
    ) external onlyOwner nonReentrant {
        require(to != address(0), "Invalid to address");
        
        WithdrawalRequest storage request = withdrawalRequests[requestId];
        
        require(request.id == requestId, "Request not found");
        require(!request.executed, "Already executed");
        require(block.timestamp >= request.requestedAt + 1 days, "Cooldown not met");
        
        request.executed = true;
        
        // Transfer stETH
        IERC20(STETH).transfer(to, request.amount);
        
        // Update treasury if principal withdrawal
        if (!request.isYield) {
            Treasury storage treasury = treasuries[request.agent];
            treasury.stETHBalance -= request.amount;
            totalTreasuryBalance -= request.amount;
        }
        
        emit WithdrawalExecuted(requestId, to, request.amount);
    }
    
    /**
     * @notice Get treasury info
     */
    function getTreasuryInfo(address agent) external view returns (
        uint256 principal,
        uint256 yieldAccumulated,
        uint256 totalValue,
        bool isActive
    ) {
        require(agent != address(0), "Invalid agent address");
        
        Treasury storage treasury = treasuries[agent];
        principal = treasury.stETHBalance;
        yieldAccumulated = treasury.yieldAccumulated;
        totalValue = principal + yieldAccumulated;
        isActive = treasury.isActive;
    }
    
    /**
     * @notice Get withdrawal history for an agent
     */
    function getWithdrawalHistory(address agent) external view returns (bytes32[] memory) {
        require(agent != address(0), "Invalid agent address");
        return agentWithdrawals[agent];
    }
}