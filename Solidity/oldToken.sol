pragma solidity ^0.4.26;


// Placeholder for testnet, old ERC20 to be upgraded

import "./IERC20.sol";
import "./SafeMath.sol";

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) external;
}

contract MeridianOld is ERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowed;
  string public constant name  = "Meridian Network";
  string public constant symbol = "MRDN";
  uint8 public constant decimals = 18;

  uint256 _totalSupply = 10000000 * (10 ** 18);

  constructor() public {
    balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /*
    !!!!!!!!!!!!!!!!!!!!!!!!!

    TEST FUNCTION ONLY DO NOT DEPLOY MAINNET

    !!!!!!!!!!!!!!!!!!!!!!!!!
  */
  function _mint(address account, uint256 amount) public {
      require(account != address(0), "ERC20: mint to the zero address");
      _totalSupply = _totalSupply.add(amount);
      balances[account] = balances[account].add(amount);
      emit Transfer(address(0), account, amount);
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address user) public view returns (uint256) {
    return balances[user];
  }

  function allowance(address user, address spender) public view returns (uint256) {
    return allowed[user][spender];
  }

  function transfer(address recipient, uint256 value) public returns (bool) {
    require(value <= balances[msg.sender]);
    require(recipient != address(0));

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[recipient] = balances[recipient].add(value);

    emit Transfer(msg.sender, recipient, value);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function approveAndCall(address spender, uint256 tokens, bytes data) external returns (bool) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
    return true;
  }

  function transferFrom(address from, address recipient, uint256 value) public returns (bool) {
    require(value <= balances[from]);
    require(value <= allowed[from][msg.sender]);
    require(recipient != address(0));

    balances[from] = balances[from].sub(value);
    balances[recipient] = balances[recipient].add(value);

    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

    emit Transfer(from, recipient, value);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function burn(uint256 amount) external {
    require(amount != 0);
    require(amount <= balances[msg.sender]);
    _totalSupply = _totalSupply.sub(amount);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    emit Transfer(msg.sender, address(0), amount);
  }

}
