var web3 = new Web3(Web3.givenProvider);
console.log("Web3 :", web3);
var contractInstance;

$(document).ready(function() {
    window.ethereum.enable().then(function(accounts){
      contractInstance = new web3.eth.Contract(abi,
        "0x82a4Ea519855C5622F8e1300e9F9111871DA1C4e",
        {from: accounts[0]}
      );
      console.log(contractInstance);
      $("#submit").click(sendFlip);
      contractInstance.methods.getBalance().call().then(function(res){
        const ethValue = Web3.utils.fromWei(res, 'ether');
        $("#balance").text(ethValue);
      });
    });
});

function sendFlip(){
  var bet=$("#bet").val();
  const weiValue = Web3.utils.toWei(bet, 'ether');
  var config = {
    value: weiValue
  }
  
  contractInstance.methods.flip().send(config).then(function(out){
    console.log(out.events.lastGameOutcome.returnValues.outcome);
    console.log("Res game:",out.events.resGameEvent.returnValues.z);
    console.log("OUT:",out);
    $("#result").text(out.events.lastGameOutcome.returnValues.outcome);
    $("#res").text(out.events.resGameEvent.returnValues.z);
    contractInstance.methods.getBalance().call().then(function(res){
      const ethValue = Web3.utils.fromWei(res, 'ether');
      $("#balance").text(ethValue);
  });
});
}
