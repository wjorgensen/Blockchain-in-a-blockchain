pragma solidity ^0.8.13;

contract Block_maker {
    uint private constant BLOCK_TIME = 1 hours;
    uint private transaction_number = 1;
    address owner;
    bytes32 private previousHash;
    uint256 private blockNumber;

    struct Transaction {
        uint id;
        address sender;
        address reciever;
        uint amount;
        bool validated;
    }

    Transaction[] private transactions;

    event newTransaction(
        uint number,
        address sender,
        address reciever,
        uint amount
    );
    event winCoins(address winner, uint numberOfCoins, uint transactionNumber);
    event JsonBlock(string json);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        blockNumber = 0;
        previousHash = bytes32("First Block");
        Transaction memory first = Transaction(1, 0x0000000000000000000000000000000000000000, msg.sender, 5000, true);
        transactions.push(first);
        createBlock();
    }

    function createBlock() public onlyOwner {
        // Initialize an empty JSON array
        string[] memory jsonElements = new string[](transactions.length);

        // Add the previous hash to the JSON block
        jsonElements[0] = string(abi.encodePacked('{"previous_hash":"', previousHash, '",'));

        // Add the block number to the JSON block
        jsonElements[1] = string(abi.encodePacked('"block_number":', toString(blockNumber), ','));

        // Add the timestamp to the JSON block
        jsonElements[2] = string(abi.encodePacked('"timestamp":', toString(block.timestamp), ','));

        uint validCount = 3; // Count of validated transactions

        for (uint i = 0; i < transactions.length; i++) {
            if (transactions[i].validated == true) {
                // Construct a JSON object for each validated transaction
                string memory jsonString = string(
                    abi.encodePacked(
                        "{",
                        '"number":"',
                        toString(transactions[i].id),
                        '",',
                        '"sender":"',
                        transactions[i].sender,
                        '",',
                        '"receiver":"',
                        transactions[i].reciever,
                        '",', // Corrected field name
                        '"amount":"',
                        toString(transactions[i].amount),
                        '"', // Removed extra comma
                        "}"
                    )
                );
                jsonElements[validCount] = jsonString;
                validCount++;
            }
        }

        // Create the JSON block
        string memory jsonArray = string(
            abi.encodePacked("[", stringJoin(jsonElements, ","), "]")
        );

        // Emit the JSON block as an event
        emit JsonBlock(jsonArray);
        previousHash = keccak256(abi.encodePacked(jsonArray));
        blockNumber++;
    }

    function send_scam_coins(uint amount, address reciever) public {
        Transaction memory newTrans = Transaction(
            transaction_number,
            msg.sender,
            reciever,
            amount,
            false
        );
        transactions.push(newTrans);
        emit newTransaction(transaction_number, msg.sender, reciever, amount);
        transaction_number += 1;
    }

    function validate(uint transaction_id) public onlyOwner {
        transactions[transaction_id - 1].validated = true;
    }


    //Randomly generates a number and assigns new coins based upon result
    function newSpin() public {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    string.concat(
                        string(abi.encodePacked(msg.sender)),
                        string(abi.encodePacked(block.timestamp))
                    )
                )
            )
        );
        uint16 amount;
        if (randomNumber % 100 == 0) {
            amount = 1000;
        } else if (randomNumber % 10 == 0) {
            amount = 200;
        } else if (randomNumber % 2 == 0) {
            amount = 50;
        } else {
            amount = 25;
        }

        Transaction memory newTrans = Transaction(
            transaction_number,
            0x0000000000000000000000000000000000000000,
            msg.sender,
            amount,
            true
        );
        transactions.push(newTrans);
        emit winCoins(msg.sender, amount, transaction_number);
        transaction_number += 1;
    }


    //Method provided by chatGPT
    function toString(uint256 _value) internal pure returns (string memory) {
        // Convert a uint256 to a string
        if (_value == 0) {
            return "0";
        }
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_value % 10)));
            _value /= 10;
        }
        return string(buffer);
    }

    //Method provided by chatGPT
    function stringJoin(
        string[] memory _strings,
        string memory _delimiter
    ) internal pure returns (string memory) {
        // Join an array of strings with a delimiter
        if (_strings.length == 0) {
            return "";
        }
        string memory result = _strings[0];
        for (uint i = 1; i < _strings.length; i++) {
            result = string(abi.encodePacked(result, _delimiter, _strings[i]));
        }
        return result;
    }
}
