pragma solidity >=0.6.0;

// import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  event Stake(address _from, uint256 _value);

  mapping (address => uint256) public balances;
  address[] private addrList;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool private openForWithdraw = false;

  function stake() payable public {
    balances[msg.sender] += msg.value;
    addrList.push(msg.sender);
    emit Stake(msg.sender, msg.value);
  }

  function execute() public {
    require(block.timestamp > deadline);
    if (address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
      for (uint i=0; i < addrList.length ; i++){
          balances[addrList[i]] = 0;
        }
      } else {
      openForWithdraw = true;
    }
  }

  function withdraw(address payable _addr) public payable {
    require(balances[_addr] != 0);
    require(openForWithdraw == true);
    uint256 amount = balances[_addr];
    balances[_addr] = 0;
    _addr.transfer(amount);
  }

  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return uint256(deadline - block.timestamp);
    }
  }

  receive() external payable {
    stake();
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()


}
