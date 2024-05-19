// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public tokenPrice = 0.01 ether; // Price per token in ETH
    uint256 public sellFee = 1; // 1% fee on selling

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Bought(address indexed buyer, uint256 amount, uint256 cost);
    event Sold(address indexed seller, uint256 amount, uint256 revenue);
    event PriceUpdated(uint256 newPrice);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function mint(address _to, uint256 _amount) internal {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }

    function burn(address _from, uint256 _amount) internal {
        require(balanceOf[_from] >= _amount, "Insufficient balance to burn");
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
        emit Burn(_from, _amount);
        emit Transfer(_from, address(0), _amount);
    }

    function buyTokens() public payable returns (bool success) {
        uint256 amountToBuy = msg.value / tokenPrice;
        require(amountToBuy > 0, "You need to send some ETH");
        mint(msg.sender, amountToBuy);
        emit Bought(msg.sender, amountToBuy, msg.value);
        return true;
    }

    function sellTokens(uint256 amountToSell) public returns (bool success) {
        require(balanceOf[msg.sender] >= amountToSell, "Insufficient token balance");
        uint256 ethAmount = amountToSell * tokenPrice;
        uint256 fee = ethAmount * sellFee / 100;
        uint256 revenue = ethAmount - fee;
        require(address(this).balance >= revenue, "Contract has insufficient ETH balance");
        burn(msg.sender, amountToSell);
        payable(msg.sender).transfer(revenue);
        emit Sold(msg.sender, amountToSell, revenue);
        return true;
    }
function sellTokens_reentrancy(uint256 amountToSell) public returns (bool success) {
    require(balanceOf[msg.sender] >= amountToSell, "Insufficient token balance");
    uint256 ethAmount = amountToSell * tokenPrice;
    uint256 fee = ethAmount * sellFee / 100;
    uint256 revenue = ethAmount - fee;
    require(address(this).balance >= revenue, "Contract has insufficient ETH balance");
    
    // Vulnerable point: External call before state update
    (bool sent, ) = msg.sender.call{value: revenue}("");
    require(sent, "Failed to send Ether");
    
    // State update happens after the external call
    burn(msg.sender, amountToSell);
    
    emit Sold(msg.sender, amountToSell, revenue);
    return true;
}


    function setPrice(uint256 newPrice) public onlyOwner {
        tokenPrice = newPrice;
        emit PriceUpdated(newPrice);
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        buyTokens();
    }

}




