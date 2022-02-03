pragma solidity >= 0.5.0;

contract MultiSignitureWallet{
    
    address[] public owners;
    uint public required;
    uint public transactionCount;

    mapping (address => bool) public isOwner;
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping(address => bool)) public confirmations;

    struct Transaction {
        uint value;
        address destination;
        bytes data;
        bool executed;
    }


    

    fallback() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    // A MODIFIER FOR CONSTRUCTOR //
    modifier validRequire(uint numberOfOwners, uint _required) {
        if (_required > numberOfOwners || required == 0 || numberOfOwners == 0){
            revert("The conditions have not met");
        }
        _;
    }
//----------------------------------------///*EVENTS*///-------------------------------------------//
    event Deposit(address indexed sender, uint value);
    event Submission(uint indexed transactionID);
    event Confirmation(address indexed _owner, uint indexed _transactionId);
    event Execution(uint indexed _transactionId);
    event ExecutionFailure(uint indexed _transactionId);

//----------------------------------///*PUBLIC FUNCTIONS*///---------------------------------------//
    constructor(address[] memory _owners, uint _required)
    validRequire(_owners.length, _required) {
        for (uint i = 0; i<_owners.length; i++){
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    function submitTransaction(address _destinaiton, uint _value, bytes memory _data)
    public
    returns(uint transactionID){
        require(isOwner[msg.sender]);
        transactionID = addTransaction(_destinaiton, _value, _data);
        confirmTransaction(transactionID);
    }

    function confirmTransaction(uint _transactionId)
    public {
        require(isOwner[msg.sender]);
        require(transactions[_transactionId].destination != address(0));
        require(confirmations[_transactionId][msg.sender] == false);
        confirmations[_transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, _transactionId);
        executeTransaction(_transactionId);
    }

    function executeTransaction(uint _transactionId)
    public{
        require(transactions[_transactionId].executed == false);
        if (isConfirmed(_transactionId)){
            Transaction storage t = transactions[_transactionId];
            t.executed = true;
            emit Execution(_transactionId);
            (bool success,) = t.destination.call{value:t.value}(t.data);
            if (success){
                emit Execution(_transactionId);
            }
            else{
                emit ExecutionFailure(_transactionId);
                t.executed = false;
            }
        }
    }
    
//---------------------------------///*INTERNAL FUNCTIONS*///------------------------------------//
    function addTransaction(address _destination, uint _value, bytes memory _data)
    internal
    returns(uint transactionID){
        transactionID = transactionCount;
        transactions[transactionID] = Transaction({
            destination : _destination,
            value : _value,
            data : _data,
            executed : false
        });
        transactionCount += 1;
        emit Submission(transactionID);
    }

    function isConfirmed(uint _transactionId)
    internal
    view
    returns(bool){
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[_transactionId][owners[i]] == true){
                count += 1;
            }
            if (count == required) {
                return true;
            }
        }
        return false;
    }

}