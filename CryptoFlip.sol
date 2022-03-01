// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract CryptoFlip is VRFConsumerBase {

  using SafeMath for uint;
  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;
  address public owner;
  address payable dev_wallet;

  // map that stores last flip result for a given address
  mapping(address => bool) lastFlip;

  constructor() 
    VRFConsumerBase(
      0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
      0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
      ) {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18;
        owner = msg.sender;
  }

  // events
  event lastGameOutcome(string outcome, uint bet);
  event resGameEvent(uint z);
    
  /** 
  * Requests randomness 
  **/
  function getRandomNumber() public returns (bytes32 requestId) {
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee);
  }

  /**
   * Callback function used by VRF Coordinator
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    randomResult = (randomness % 105) + 1;
  }

  // function that recevies initial deposit of contrat to have cash to start the game
  function initialDeposit() payable external {
  }

  // function that set the dev_wallet
  function setDev(address payable _dev) public {
    require(msg.sender == owner, "Only the owner can set the dev wallet");
    dev_wallet = _dev;
  }

  // function that get the dev_wallet
  function getDevWallet()  public view returns (address){
    require(msg.sender == owner, "Only the owner can get the dev wallet");
    return  dev_wallet;
  }

  // function that get balance of contract address
  function getBalance()  public view returns (uint){
    return  address(this).balance;
  }

  // function that gets the last flip result for an address
  function getLastFlip(address player)  public view returns (bool){
    return lastFlip[player];
  }

  //Get random number from Chainlink
  function random() private {
    getRandomNumber();
  }

  // function that actually performs the flip
  function flip() payable public {
    require(msg.value <= 15 ether, "Bet must be below 15 ETH");
    require(msg.value >=  0.01 ether, "Bet must be above 0.01 ETH");
    random();
    uint bet = msg.value;
    string memory outcome;

    //Get 1% fees for dev_wallet
    dev_wallet.transfer(bet.mul(1).div(100));

    uint z=randomResult;

    if(z <= 49) {
      payable(msg.sender).transfer(bet*2);
      lastFlip[msg.sender] = true;
      outcome ="win";
      emit resGameEvent(z);
      z=0;
    } else {
      lastFlip[msg.sender] = false;
      outcome = "lose";
      emit resGameEvent(z);
      z=0;
    }
    assert(z==0);
    emit lastGameOutcome(outcome,bet);
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}
