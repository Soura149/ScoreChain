# 🧾 ScoreChain – Tamper-Proof Exam Result Publication (Solidity Smart Contract)

## 📘 Project Description
**ScoreChain** is a blockchain-based smart contract built with **Solidity** that enables secure, transparent, and tamper-proof publication of student exam results.  
Traditional result systems are centralized and prone to manipulation or data loss. ScoreChain uses blockchain immutability to ensure that once published, exam results cannot be altered — providing trust and transparency for both students and institutions.

---

## 🚀 What It Does
- The **exam authority (owner)** deploys the contract and becomes the only entity authorized to publish results.
- Each student’s result is published under a **hashed identifier (keccak256)** to preserve privacy.
- Once a result is published, it **cannot be modified or deleted**, guaranteeing immutability.
- Students (or anyone) can verify their results using the **hash** derived from their roll number and a secret salt.
- Anyone can read the results on-chain without needing special access.

---

## ✨ Features
✅ **Owner-only publishing** — Only the contract owner (exam authority) can add results.  
✅ **Immutable records** — Once stored, results cannot be overwritten or deleted.  
✅ **Privacy-preserving** — Uses hashed identifiers to protect student information.  
✅ **Transparent verification** — Anyone can verify results publicly via blockchain explorers.  
✅ **Lightweight & gas-efficient** — Minimal storage and simple data structures.  
✅ **Ownership control** — Ownership can be transferred securely.  

---

## 🔗 Deployed Smart Contract
**Network:** Celo Sepolia Testnet  
**Block Explorer:** [View Contract on Blockscout](https://celo-sepolia.blockscout.com/address/0x3b1509B43bd56C0638699D6579C0c46bEE2742DF)

---

## 💻 Smart Contract Code

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ScoreChain - Tamper-proof Exam Result Publication System
/// @author
/// @notice Owner can publish exam results that cannot be modified once published.
/// @dev Results are stored using a hashed student identifier for privacy.
contract ScoreChain {
    /// @notice Address of the contract owner (e.g., the exam authority)
    address public owner;

    /// @notice Emitted when ownership is transferred
    /// @param previousOwner The address of the previous owner
    /// @param newOwner The address of the new owner
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Emitted when a new exam result is published
    /// @param studentHash The hashed identifier of the student
    /// @param score The numeric score of the student
    /// @param grade The grade or remark (e.g., "A+", "Pass")
    /// @param timestamp The block timestamp when published
    /// @param examId The exam identifier (e.g., "Math2025-01")
    event ResultPublished(bytes32 indexed studentHash, uint16 score, string grade, uint256 timestamp, string examId);

    /// @notice Struct to represent a student's result
    struct Result {
        uint16 score;        // numeric score (0–65535)
        string grade;        // e.g. "A", "B+", "Pass"
        string examId;       // exam identifier (e.g. "Math2025-01")
        uint256 timestamp;   // block timestamp when published
        bool exists;         // true if record already exists
    }

    /// @notice Mapping from student hash to their exam result
    mapping(bytes32 => Result) private results;

    /// @notice Restricts functions to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "ScoreChain: caller is not the owner");
        _;
    }

    /// @notice Initializes the contract setting the deployer as the initial owner
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /// @notice Transfers contract ownership to another address
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "ScoreChain: new owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /// @notice Publishes a result for a student (identified by studentHash). Cannot overwrite existing result.
    /// @param studentHash keccak256 hash of the student's identifier (computed off-chain)
    /// @param score Numeric score (0–65535)
    /// @param grade Human-readable grade (e.g., "A")
    /// @param examId Exam identifier string (e.g., "Math2025-01")
    function publishResult(
        bytes32 studentHash,
        uint16 score,
        string calldata grade,
        string calldata examId
    ) external onlyOwner {
        require(!results[studentHash].exists, "ScoreChain: result already published for this student");
        results[studentHash] = Result({
            score: score,
            grade: grade,
            examId: examId,
            timestamp: block.timestamp,
            exists: true
        });

        emit ResultPublished(studentHash, score, grade, block.timestamp, examId);
    }

    /// @notice Reads a published result using the student's hash
    /// @param studentHash keccak256 hash used when publishing
    /// @return score The numeric score of the student
    /// @return grade The letter or descriptive grade
    /// @return examId The exam identifier string
    /// @return timestamp The block timestamp when the result was published
    /// @return exists Boolean indicating whether the result exists
    function getResult(bytes32 studentHash)
        external
        view
        returns (
            uint16 score,
            string memory grade,
            string memory examId,
            uint256 timestamp,
            bool exists
        )
    {
        Result storage r = results[studentHash];
        return (r.score, r.grade, r.examId, r.timestamp, r.exists);
    }

    /// @notice Computes a student's hash (for reference)
    /// @dev It’s safer to compute this off-chain so the salt remains secret
    /// @param studentId Public student identifier (e.g., roll number)
    /// @param salt Secret salt string known only to admin and student
    /// @return hash The keccak256 hash combining studentId and salt
    function computeStudentHash(string calldata studentId, string calldata salt)
        external
        pure
        returns (bytes32 hash)
    {
        hash = keccak256(abi.encodePacked(studentId, "|", salt));
    }
}

