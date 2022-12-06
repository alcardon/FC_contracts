// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "hardhat/console.sol";

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
    AggregatorV3Interface internal priceFeed;
    // address payable owner; // contract creator's address

    address public NFT_CONTRACT_ADDRESS = 0x895E3C0C85A7593f5b4c993de546206ea1C75F52;
    address public TOKEN_CONTRACT_ADDRESS = 0x28FB2D8E2B652058e4Bc4377fA4Cb7f707eDa9dc;
    IERC20 tokenBUSD;

    uint public REWARD_PER_BLOCK = 0.1 ether;

    // Starting and stopping token claims
    bool public claimActive = false;

    uint public membership_cost = 120; //$120
    uint public membership_price_bnb;
    uint public busd_price;

    uint totalReceivedBNB; // the amount of donations
    uint public lastReceivedAmount;

    NFTCollectionMinter public nft_contract = NFTCollectionMinter(NFT_CONTRACT_ADDRESS);
    MyToken public token_contract = MyToken(TOKEN_CONTRACT_ADDRESS);
    // PriceConsumerV3 public price_consumer = new PriceConsumerV3();

    mapping(uint => uint256) public checkpoints;
    mapping(uint => bool) public is_registered;

    function priceFeedDecimals() internal view returns(uint8) {
        return priceFeed.decimals();
    }

    /**
     * Network: Mainnet
     * Aggregator: BNB/USD
     * Address: 0x14e613AC84a31f709eadbdF89C6CC390fDc9540A
     * testnet: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     */
    constructor() {
        // owner = payable(msg.sender); // setting the contract creator
        tokenBUSD = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);

        priceFeed = AggregatorV3Interface(
            // 0x14e613AC84a31f709eadbdF89C6CC390fDc9540A
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        setBUSDPrice();
        setBNBMembershipPrice(getBUSDPrice());
    }


   function GetUserTokenBalance() public view returns(uint256){ 
       return tokenBUSD.balanceOf(msg.sender);// balancdOf function is already declared in ERC20 token function
   }

    // Internal
    function donate() public payable {
        (bool success,) = owner().call{value: msg.value}("");
        totalReceivedBNB = totalReceivedBNB + msg.value;
        require(success, "Failed to send money");
    }

    function getTotalReceivedBNB() view public returns(uint) {
        return totalReceivedBNB;
    }

    function setBNBMembershipPrice(uint _price) public onlyOwner {
        // cost_in_wei / price_in_decimal
        uint price_in_wei = (membership_cost * (10**8)) / _price;
        membership_price_bnb = price_in_wei;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            ,
            /*uint80 roundID*/ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return price;
    }


    function getBUSDPrice() public view returns(uint) {
        return busd_price;
    }

    function setBUSDPrice() public onlyOwner {
        int price = getLatestPrice();
        uint8 decimals = priceFeedDecimals();
        busd_price = uint(price) / (10 ** decimals);
        // nft_contract.mint(1);
    }

    

    function payFees() external payable {
        lastReceivedAmount = msg.value;
        require(msg.value >= membership_price_bnb * (10**10), "Not Enough has been sent");
        totalReceivedBNB = totalReceivedBNB + msg.value;
        // (bool success,) = owner().call{value: msg.value}("");
        // require(success, "Failed to send money");
    }

    function setCheckpoint(uint token_id) internal
    {
        checkpoints[token_id] = block.number;
    }

    // Owner
    function setClaimActive(bool value) public onlyOwner {
        claimActive = value;
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
        // uint256 reward = calculateReward(token_id);
        // token_contract.mintReward(msg.sender, reward);
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

    // function calculateReward(uint token_id) public view returns(uint256)
    // {
    //     if(!is_registered[token_id])
    //     {
    //         return 0;
    //     }
    //     uint256 checkpoint = checkpoints[token_id];
    //     return REWARD_PER_BLOCK * (block.number-checkpoint);
    // }
}
