//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {

    address public CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 public CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [PROOF_ONE, PROOF_TWO];
    bytes private SIGNATURE = hex"12e145324b60cd4d302bfad59f72946d45ffad8b9fd608e672fd7f02029de7c438cfa0b8251ea803f361522da811406d441df04ee99c3dc7d65f8550e12be2ca1c";

    function claimAirdrop(address _airdrop) public {
        vm.startBroadcast();
        (uint8 V, bytes32 R, bytes32 S) = splitSignature(SIGNATURE);
        MerkleAirdrop(_airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, PROOF, V, R, S);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory _signature) public pure returns (uint8 V, bytes32 R, bytes32 S) {
        require(_signature.length == 65, "Invalid signature length");
        assembly {
            R := mload(add(_signature, 32))
            S := mload(add(_signature, 64))
            V := byte(0, mload(add(_signature, 96)))
        }
        
    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        ClaimAirdrop(mostRecentlyDeployed);
    }
}
