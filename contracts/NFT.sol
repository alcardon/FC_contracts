// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MinterNFT {
    function register(uint token_id) public
    {
    }
}

contract NFTCollection is ERC721Enumerable, Ownable {
    using Address for address;
    using Counters for Counters.Counter;

    string public baseTokenURI = "ipfs://QmSWSp5WupP9D53gL3cFFga9Sobc4riqkDpFQqshL7k5mv"; // The base link that leads to the image / video of the token

    // Minter Settings
    address minter_contract_address; // We store the minter contract address
    MinterNFT minter; // We store the minter contract 
    Counters.Counter private _tokenIdCounter;


    // Maximum limit of tokens that can ever exist
    // uint256 public constant MAX_SUPPLY = type(uint256).max;

    constructor () ERC721 ("Friendcoin Bronze Membership Card", "BFRND") {
        // price = initial_price;
    }

    modifier onlyMinter() {
        require(msg.sender == minter_contract_address, "Only the minter can mint"); _;
    }

    // See which address owns which tokens
    function tokensOfOwner(address addr) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(addr);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(addr, i);
        }
        return tokensId;
    }

    // Standard mint function
    function mint(address to) public onlyMinter { //onlyMinter
        uint256 tokenId = _tokenIdCounter.current();
        // require( saleActive, "Sale isn't active" );
        // require( balanceOf(msg.sender) + _amount <= MAX_MINT_PER_WALLET, "Max mint per wallet exceeded!");
        // require( supply + 1 <= MAX_SUPPLY, "Can't mint more than max supply" );
        // require( msg.value == price * _amount, "Wrong amount of BNB sent" );
        _safeMint(address(to), tokenId);
        minter.register(tokenId);
        _tokenIdCounter.increment();
    }
    
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721: invalid token ID");

        return "ipfs://QmSWSp5WupP9D53gL3cFFga9Sobc4riqkDpFQqshL7k5mv";
    }

    // Set Minter contract address
    function setMinter(address contract_address) public onlyOwner {
        minter = MinterNFT(contract_address);
        minter_contract_address = contract_address;
    }
}
