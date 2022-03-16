// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Airdrop is Ownable {
    mapping(address => bool) public processedAirdrops;
    IERC20 public token;
    uint256 public currentAirdropAmount;
    uint256 public maxAirdropAmount;

    event AirdropProcessed(address recipient, uint256 amount, uint256 date);

    constructor(address _token, uint256 _maxAirdropAmount) {
        token = IERC20(_token);
        maxAirdropAmount = _maxAirdropAmount;
    }

    function claimTokens(
        address recipient,
        uint256 amount,
        bytes calldata signature
    ) external {
        bytes32 message = prefixed(
            keccak256(abi.encodePacked(recipient, amount))
        );
        require(
            recoverSigner(message, signature) == owner(),
            "wrong signature"
        );
        require(
            processedAirdrops[recipient] == false,
            "airdrop already processed"
        );
        require(
            currentAirdropAmount + amount <= maxAirdropAmount,
            "airdropped 100% of the tokens"
        );
        processedAirdrops[recipient] = true;
        currentAirdropAmount += amount;
        token.transfer(recipient, amount);
        emit AirdropProcessed(recipient, amount, block.timestamp);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function recoverSigner(bytes32 message, bytes memory signature)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(signature);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory signature)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(signature, 32))
            // second 32 bytes
            s := mload(add(signature, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(signature, 96)))
        }

        return (v, r, s);
    }
}
