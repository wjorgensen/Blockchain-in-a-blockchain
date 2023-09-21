pragma solidity ^0.8.13;

contract Block_maker {

    uint block_num;
    uint constant private BLOCK_TIME = 1 hours;
    uint private transaction_number = 1;
    address owner;

    struct Transaction{
        uint id;
        address sender;
        address reciever;
        uint amount;
        bool validated;
    }

    Transaction[] private transactions;

    event newTransaction(uint number, address sender, address reciever, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(){

    }

    function create_block() private {
        
    }

    function send_johns_coins(uint amount, address reciever) public {
        Transaction memory newTrans = Transaction(transaction_number, msg.sender, reciever, amount, false); 
        transactions.push(newTrans);
        emit newTransaction(transaction_number, msg.sender, reciever, amount);
        transaction_number+=1;
    }

    function validate(uint transaction_id) public onlyOwner{
            transactions[transaction_id-1].validated = true;
    }

   

}