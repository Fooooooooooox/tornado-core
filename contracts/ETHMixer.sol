// https://tornado.cash
/*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/

pragma solidity ^0.5.8;

import "./Mixer.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/GSN/GSNRecipient.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/GSN/IRelayHub.sol";

contract ETHMixer is Mixer, GSNRecipient {
  constructor(
    address _verifier,
    uint256 _mixDenomination,
    uint8 _merkleTreeHeight,
    uint256 _emptyElement,
    address payable _operator
  ) Mixer(_verifier, _mixDenomination, _merkleTreeHeight, _emptyElement, _operator) public {
  }

  function _processWithdraw(address payable _receiver, address payable _relayer, uint256 _fee) internal {
    _receiver.transfer(mixDenomination - _fee);
    if (_fee > 0) {
      _relayer.transfer(_fee);
    }
  }

  function _processDeposit() internal {
    require(msg.value == mixDenomination, "Please send `mixDenomination` ETH along with transaction");
  }
}