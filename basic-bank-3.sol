pragma solidity 0.7.0;

//transfer between users

contract BasicBank  {

    mapping (address => uint) private userFunds;
    address private commissionCollector;
    uint private collectedComission = 0;

    constructor() {
        commission_taker = msg.sender;
    }
    
    modifier onlyCommissionCollector {
        require(msg.sender == commissionCollector);
        _;
    }

    function deposit() public payable {
        require(msg.value >= 1); //gönderilen eth miktarı 1 den fazla olmalı
        userFunds[msg.sender] += msg.value; //işlemi yapan kullanıcının adres değeri msg.value kadar artırıldı.
    }

    function withdraw(uint _amount) public payable {
        require(getBalance(msg.sender) >= _amount);
        payable (msg.sender).transfer(_amount);
        userFunds[msg.sender] -= _amount;
        collectedComission += _amount/100; //%1 komisyon olarak commission_taker hesabına ekleniyor.
    }   

    function getBalance(address _user) public view returns(uint) {
        return userFunds[_user];
    }

    function getCommissionCollector() public view returns(address) {
        return commissionCollector;
    }

    function transfer(address _userToSend, uint _amount) {
        userFunds[_userToSend] += _amount;
        userFunds[msg.sender] -= _amount;
    }

    function setCommissionCollector(address _newCommissionCollector) external {
        require(commissionCollector == msg.sender);
        commissionCollector = _newCommissionCollector;
    }

    function collectCommission() external onlyCommissionCollector{
        userFunds[msg.sender] += collectedComission;
        collectedComission = 0;
    }
}