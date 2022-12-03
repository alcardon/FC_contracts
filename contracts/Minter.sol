// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken {
    function mintReward(address beneficiary, uint amount) public
    {
    }
}

contract NFTCollectionMinter {  
    function tokensOfOwner(address addr) public view returns(uint256[] memory) {
    }
    function ownerOf(uint256 tokenId) public view returns (address) {
    }
}

// estiable el token (done)
// editable el reward per block (done)

contract Minter is Ownable {
    address public NFT_CONTRACT_ADDRESS = 0x895E3C0C85A7593f5b4c993de546206ea1C75F52;
    address public TOKEN_CONTRACT_ADDRESS = 0x28FB2D8E2B652058e4Bc4377fA4Cb7f707eDa9dc;

    uint public REWARD_PER_BLOCK = 0.1 ether;

    // Starting and stopping token claims
    bool public claimActive = false;

    NFTCollectionMinter public nft_contract = NFTCollectionMinter(NFT_CONTRACT_ADDRESS);
    MyToken public token_contract = MyToken(TOKEN_CONTRACT_ADDRESS);

    mapping(uint => uint256) public checkpoints;
    mapping(uint => bool) public is_registered;

    // Internal

    function setCheckpoint(uint token_id) internal
    {
        checkpoints[token_id] = block.number;
    }

    // Owner
    function setClaimActive(bool value) public onlyOwner {
        claimActive = value;
    }

    function setRewardPerBlock(uint amount) public onlyOwner
    {
        REWARD_PER_BLOCK = amount;
    }

    function setNFTContract(address nft_contract_address) public onlyOwner
    {
        NFT_CONTRACT_ADDRESS = nft_contract_address;
        nft_contract = NFTCollectionMinter(NFT_CONTRACT_ADDRESS);
    }

    function setTokenContract(address token_contract_address) public onlyOwner
    {
        TOKEN_CONTRACT_ADDRESS = token_contract_address;
        token_contract = MyToken(TOKEN_CONTRACT_ADDRESS);
    }

    // NFT contract

    function register(uint token_id) public
    {
        require(msg.sender == NFT_CONTRACT_ADDRESS);
        is_registered[token_id] = true;
        setCheckpoint(token_id);
    }

    // Public

    function claim(uint token_id) public
    {
        require(claimActive, "Claim must be active");
        require(nft_contract.ownerOf(token_id) == msg.sender, "Must be token owner");
        uint256 reward = calculateReward(token_id);
        token_contract.mintReward(msg.sender, reward);
        setCheckpoint(token_id);
    }

    function claimAll() public
    {
        require(claimActive, "Claim must be active");
        uint256[] memory sender_tokens = nft_contract.tokensOfOwner(msg.sender);
        for(uint i=0; i<sender_tokens.length; i++)
        {
            claim(sender_tokens[i]);
        }
    }

    // View

    function calculateReward(uint token_id) public view returns(uint256)
    {
        if(!is_registered[token_id])
        {
            return 0;
        }
        uint256 checkpoint = checkpoints[token_id];
        return REWARD_PER_BLOCK * (block.number-checkpoint);
    }
}
