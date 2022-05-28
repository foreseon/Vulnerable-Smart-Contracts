pragma solidity 0.7.0;

//deposit and withdraw func
//payable functions, msg.value, payable address

contract BasicBank  {

    mapping (address => uint) private userFunds;


    function deposit() external payable {
        require(msg.value >= 1); //gönderilen eth miktarı 1 den fazla olmalı
        userFunds[msg.sender] += msg.value; //işlemi yapan kullanıcının adres değeri msg.value kadar artırıldı.
    }

    function withdraw(uint _amount) external payable{
        require(userFunds[msg.sender] > _amount);
        payable (msg.sender).transfer(_amount);
        userFunds[msg.sender] -= _amount;
    }

}