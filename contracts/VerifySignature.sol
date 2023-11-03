// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// The process of verifying signatures in solidity is in four steps
// 0. message to sign
// 1. hash(message)

// 2. sign(hash(message),private key) | offchain  // The actual signature will be done offchain and will not be done inside the smart contract
// Another thing to note is when you sign the message hash, the hash will be prefixed with some strings and then hashed again
// That would be the actual message that is signed

// 3. ecrecover (hash(message), signature) == signer //This is to verify the signature

contract VerifySig {
    // The last function input is the signature itself
    function verify(address _signer, string memory _message, bytes memory _sig) external pure returns(bool) {
        // we would use keccak256 to hash the message
        bytes32 messageHash = getMessageHash(_message);  //We would still do a keccak256 of the input(message)
        // When we sign the message offchain, the message that is signed is not messageHash, the message that is signed is also:
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(string memory _message) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            _messageHash));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns(address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v) {
        // The variable"_sig" in this function is not the actual signature like in the first function
        // It is a pointer to where the signature is stored in memory
        require(_sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte (0, mload(add(_sig, 96)))
        }
    }
}


// Note: Openzeppelin has a library that does this which is more secure so this might not be as necessary