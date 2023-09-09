// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract MultipleWinnersLottery {
    address public owner;
    mapping(address => uint256) public participants;
    address[] public participantAddresses;
    bool public isLotteryOpen;
    address public latestParticipant;
    uint256 public totalTickets;

    // Event to announce the winners
    event Winners(address[] indexed winners);

    constructor() {
        owner = msg.sender;
        isLotteryOpen = true;
        totalTickets = 0;
    }

    // Modifier to require that the caller is the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Function to buy tickets and participate in the lottery
    function buyTickets(uint256 numTickets) external payable {
        require(isLotteryOpen, "Lottery is not open");
        require(msg.value == numTickets * 1 ether, "Each ticket costs 1 ether");
        require(numTickets > 0, "Must buy at least one ticket");

        if (participants[msg.sender] == 0) {
            participantAddresses.push(msg.sender);
        }

        participants[msg.sender] += numTickets;
        totalTickets += numTickets;

        // Give an extra 10 tickets to the latest participant
        latestParticipant = msg.sender;
        participants[latestParticipant] += 10;
        totalTickets += 10;
    }

    // Function to draw winners
    function drawWinners() external onlyOwner {
        require(isLotteryOpen, "Lottery is not open");
        require(participantAddresses.length > 0, "No participants");

        // Close the lottery
        isLotteryOpen = false;

        address[] memory winners;

        // Loop over participants to check winners
        for (uint256 i = 0; i < participantAddresses.length; i++) {
            address participant = participantAddresses[i];
            uint256 numTickets = participants[participant];

            // Generate a "random" number to decide the winner
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, participant))) % totalTickets;

            // If the random number is less than the number of tickets, this participant wins
            if (randomNumber < numTickets) {
                winners[winners.length] = participant;
            }
        }

        // If there are winners, distribute the prize equally
        if (winners.length > 0) {
            uint256 prizePerWinner = address(this).balance / winners.length;

            for (uint256 i = 0; i < winners.length; i++) {
                payable(winners[i]).transfer(prizePerWinner);
            }
        }

        // Emit the winners event
        emit Winners(winners);

        // Reset the lottery
        delete participantAddresses;
        totalTickets = 0;
        isLotteryOpen = true;
    }

    // Function to get the balance of the contract
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Function to get the number of tickets for a specific address
    function getNumberOfTickets(address participant) external view returns (uint256) {
        return participants[participant];
    }
}

