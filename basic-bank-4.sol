pragma solidity 0.7.0;

//transfer between users

contract BasicBank4  {

    mapping (address => uint) private userFunds;
    address private commissionCollector;
    uint private collectedComission = 0;

    constructor() {
        commissionCollector = msg.sender;
    }
    
    modifier onlyCommissionCollector {
        require(msg.sender == commissionCollector);
        _;
    }

    function deposit() public payable {
        require(msg.value >= 1); //gönderilen eth miktarı 1 den fazla olmalı
        userFunds[msg.sender] += msg.value; //işlemi yapan kullanıcının adres değeri msg.value kadar artırıldı.
    }

    function withdraw(uint _amount) external payable {
        require(getBalance(msg.sender) >= _amount);
        msg.sender.call{value: _amount}("");
        userFunds[msg.sender] -= _amount;
        userFunds[commissionCollector] += _amount/100; //%1 komisyon olarak commission_taker hesabına ekleniyor.
    }   

    function getBalance(address _user) public view returns(uint) {
        return userFunds[_user];
    }

    function getCommissionCollector() public view returns(address) {
        return commissionCollector;
    }

    function transfer(address _userToSend, uint _amount) external{
        userFunds[_userToSend] += _amount;
        userFunds[msg.sender] -= _amount;
    }

    function setCommissionCollector(address _newCommissionCollector) external onlyCommissionCollector{
        commissionCollector = _newCommissionCollector;
    }

    function collectCommission() external {
        userFunds[msg.sender] += collectedComission;
        collectedComission = 0;
    }
}
