// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MinterNFT {
    function register(uint token_id) public
    {
    }
}

contract NFTCollection is ERC721Enumerable, Ownable {
    using Address for address;

    // ERC-20 Minter contract
    MinterNFT minter;

    // Starting and stopping sale and whitelist
    bool public saleActive = true;
    bool public whitelistActive = true;

    // Price of each token
    uint256 public initial_price = 0.04 ether;
    uint256 public price;

    // Maximum limit of tokens that can ever exist
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_MINT_PER_WALLET = 4;

    // The base link that leads to the image / video of the token
    string public baseTokenURI = "https://api.funkycrocs.io/";

    // List of addresses that have a number of reserved tokens for whitelist
    mapping (address => uint256) public whitelistReserved;

    constructor () ERC721 ("My NFT", "MNFT") {
        price = initial_price;
    }

    // Override so the openzeppelin tokenURI() method will use this method to create the full tokenURI instead
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
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

    // Exclusive whitelist minting
    function mintWhitelist(uint256 _amount) public payable {
        uint256 supply = totalSupply();
        uint256 reservedAmt = whitelistReserved[msg.sender];
        require( whitelistActive,                   "Whitelist isn't active" );
        require( reservedAmt > 0,                   "No tokens reserved for your address" );
        require( _amount <= reservedAmt,            "Can't mint more than reserved" );
        require( supply + _amount <= MAX_SUPPLY,    "Can't mint more than max supply" );
        require( msg.value == price * _amount,      "Wrong amount of ETH sent" );
        whitelistReserved[msg.sender] = reservedAmt - _amount;
        for(uint256 i; i < _amount; i++){
            _safeMint( msg.sender, supply + i );
            minter.register(supply + i);
        }
    }

    // Standard mint function
    function mint(uint256 _amount) public payable {
        uint256 supply = totalSupply();
        require( saleActive, "Sale isn't active" );
        require( balanceOf(msg.sender) + _amount <= MAX_MINT_PER_WALLET, "Max mint per wallet exceeded!");
        require( supply + _amount <= MAX_SUPPLY, "Can't mint more than max supply" );
        require( msg.value == price * _amount, "Wrong amount of ETH sent" );
        for(uint256 i; i < _amount; i++){
            _safeMint( msg.sender, supply + i );
            minter.register(supply + i);
        }
    }
    
    // Edit reserved whitelist spots
    function editWhitelistReserved(address[] memory _a, uint256[] memory _amount) public onlyOwner {
        for(uint256 i; i < _a.length; i++){
            whitelistReserved[_a[i]] = _amount[i];
        }
    }

    // Start and stop whitelist
    function setWhitelistActive(bool value) public onlyOwner {
        whitelistActive = value;
    }

    // Start and stop sale
    function setSaleActive(bool value) public onlyOwner {
        saleActive = value;
    }

    // Set new baseURI
    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    // Set a different price in case ETH changes drastically
    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    function withdrawETH() public onlyOwner
    {
        (bool sent, bytes memory data) = address(owner()).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
        data;
    }

    // Set Minter contract address
    function setMinter(address minter_contract_address) public onlyOwner {
        minter = MinterNFT(minter_contract_address);
    }
}
