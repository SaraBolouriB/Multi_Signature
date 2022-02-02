pragma solidity ^0.5.0;

contract MultiSignitureWallet{
    
    address[] public owners;
    uint public required;
    uint public transactionCount;

    mapping (address => bool) public isOwner;
    mapping (uint => Transaction) public transacrions;

    struct Transaction {
        uint value;
        address destination;
        bytes data;
        bool executed;
    }

    event Deposit(address indexed sender, uint value);

    function() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    // It's a modifier for CONSTRUCTOR //
    modifier validRequire(unit ownerCount, uint required) {
        if (_required > ownerCount || required == 0 || ownerCount == 0){
            revert("The conditions have not met");
        }
        _;
    }

    constructor(address[] memory _owners, uint _required)
    public
    validRequire(_owners.length, _required) {
        for (uint i = 0; i<_owners.length; i++){
            isOwner[_owners[i]] = ture;
        }
        owners = _owners;
        required = _required;
    }

    function submitTransaction(address _destinaiton, uint _value, bytes memory_data)
    public
    returns(uint){
        require(isOwner[msg.sender]);
        transactionID = addTransaction();
    }

    event submission(uint indexed transactionID);
    
    function addTransaction(address _destination, uint _value, bytes memory _data)
    internal
    return(uint){
        uint transactionId = transactionCount;
        transacrions[transactionId] = Transaction({
            destination = _destination,
            value = _value,
            data = _data,
            executed = false
        });
        transactionCount += 1;
        emit submission(transactionId);
        return transactionId;
    }
}