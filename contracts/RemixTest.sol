// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "hardhat/console.sol";
import "contracts/Token0.sol";

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
    
        //amount of tokens we are sending in
        uint256 amountIn,
        //the minimum amount of tokens we want out of the trade
        uint256 amountOutMin,
        //list of token addresses we are going to trade in.  this is necessary to calculate amounts
        address[] calldata path,
        //this is the address we are going to send the output tokens to
        address to,
        //the last time that the trade is valid for
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}


interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

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
    function mint(address to) public {
    }
}

contract Minter is Ownable {

    using SafeERC20 for IERC20;
    AggregatorV3Interface internal priceFeed;
    // address payable owner; // contract creator's address
    IERC20 public WBNBToken;
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //testnet
    address public NFT_CONTRACT_ADDRESS = 0x895E3C0C85A7593f5b4c993de546206ea1C75F52;
    address public TOKEN_CONTRACT_ADDRESS = 0xF0F9f3653DccD295e1B2b9Bb4C15365C70Ccf706;
    uint public membership_cost = 5; //$120
    uint public membership_price_bnb;
    uint public bnb_price_in_wei;

    uint totalReceivedBNB; // the amount of donations
    uint public lastReceivedAmount;
    IDEXRouter router;

    NFTCollectionMinter public nft_contract = NFTCollectionMinter(NFT_CONTRACT_ADDRESS);
    MyToken public token_contract = MyToken(TOKEN_CONTRACT_ADDRESS);
    address public pair;

    event Mint(address to);  

    /**
     * Network: Mainnet
     * Aggregator: BNB/USD
     * Address: 0x14e613AC84a31f709eadbdF89C6CC390fDc9540A
     * testnet: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     */

    constructor(address _WBNBToken) {
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        pair = address(0xD9110498D5D61044B6F12C0D88E8AAA9c7F3dfe7);
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        //setBNBPrice();
        //setBNBMembershipPrice();
        WBNBToken = IERC20(_WBNBToken);
       
    }

    function getPriceFeedDecimals() internal view returns(uint8) {
        return priceFeed.decimals();
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


    function test() external {
        uint _amountIn = 50000000000000000; //0.05 WBNB
        WBNBToken.approve(address(this), _amountIn);  //This Minter Contract Address
        // IERC20(WBNB).approve(msg.sender, _amountIn);
        WBNBToken.safeTransferFrom(msg.sender, address(this), _amountIn);
      


        // IERC20(WBNB).approve(address(router), _amountIn);


    }

     function test2() external {
        uint _amountIn = 50000000000000000; //0.05 WBNB
        // WBNBToken.approve(address(this), _amountIn);  //This Minter Contract Address
        // IERC20(WBNB).approve(msg.sender, _amountIn);
        WBNBToken.transferFrom(msg.sender, address(this), _amountIn);
        // IERC20(WBNB).approve(address(router), _amountIn);


    }

    mapping (address => uint) balance;
    IERC20 public token;

    function getBalance() public view returns(uint) {
        return balance[msg.sender];
    }
    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }

    function transferWBNB() public {
        uint amount = 50000000000000000;
        require(msg.sender != address(0), "Sender address cannot be 0x0");
        require(amount > 0, "Transfer amount must be greater than 0");

        token = IERC20(WBNB);
        token.approve(address(this), amount);
        token.transfer(address(this), amount);
    }

   function swap() external {
        uint _amountIn = 50000000000000000;
        address _to = address(msg.sender);
        //first we need to transfer the amount in tokens from the msg.sender to this contract
        //this contract will have the amount of in tokens
        IERC20(WBNB).approve(msg.sender, _amountIn);
        IERC20(WBNB).approve(address(this), _amountIn);
        IERC20(WBNB).transferFrom(msg.sender, address(this), _amountIn);
        
        //next we need to allow the uniswapv2 router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract 
        IERC20(WBNB).approve(address(router), _amountIn);

        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;
        // if (_tokenIn == WBNB || _tokenOut == WBNB) {
            path = new address[](2);
            path[0] = WBNB; //_tokenIn;
            path[1] = address(0xF0F9f3653DccD295e1B2b9Bb4C15365C70Ccf706); //_tokenOut;
        // } else {
        //     path = new address[](3);
            // path[0] = _tokenIn;
            // path[1] = WBNB;
        //     path[2] = _tokenOut;
        // }

        uint[] memory _amountOutMin = router.getAmountsOut(_amountIn, path); // 0.05 BNB

        //then we will call swapExactTokensForTokens
        //for the deadline we will pass in block.timestamp
        //the deadline is the latest time the trade is valid for
        IDEXRouter(router).swapExactTokensForTokens(_amountIn, _amountOutMin[1], path, _to, block.timestamp);
    }


   /*  function GetUserTokenBalance() public view returns(uint256){ 
        return tokenWBNB.balanceOf(msg.sender);// balanceOf function is already declared in ERC20 token function
    }
 */
    // // Internal
    // function donate() public payable {
    //     (bool success,) = owner().call{value: msg.value}("");
    //     totalReceivedBNB = totalReceivedBNB + msg.value;
    //     require(success, "Failed to send money");
    // }

    function getTotalReceivedBNB() view public returns(uint) {
        return totalReceivedBNB;
    }

    /* ONLY OWNER FUNCTIONS */
/*     function setBNBMembershipPrice() public onlyOwner {
        uint _price = getBNBPriceInWei();
        uint membership_price_bnb = (membership_cost * (10**18)) / _price; // changed from 8 to 18
    }
 */
  /*   function setBNBPrice() public onlyOwner {
        int price = getLatestPrice();
        uint8 decimals = getPriceFeedDecimals();
        bnb_price_in_wei = uint(price) / (10 ** decimals);
    } */


 /*    function getBNBPriceInWei() public view returns(uint) {
        return bnb_price_in_wei;
    } */

    // function payMembership() external payable {
    //     lastReceivedAmount = msg.value;
    //     require(msg.value >= membership_price_bnb * (10**18), "Not Enough has been sent");
    //     // require(buyTokens(msg.sender, msg.value), "You cannot mint now due to liquidity");

    //     (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IPancakePair(pair).getReserves();
    //     (address token0) = IPancakePair(pair).token0();
    //     (address token1) = IPancakePair(pair).token1();

    //     uint112 bnbPerFRND;
    //     uint112 reservesLeft;
    //     bool swap = false;
    //     if(isWrappedBinanceCoin(token1)) {
    //         if(reserve1 >= msg.value)
    //             swap = true;
    //         bnbPerFRND = reserve0 / reserve1; // 900900 / 0.10 WBNB
    //     } else {
    //         if(reserve0 >= msg.value)
    //             swap = true;
    //         bnbPerFRND = reserve1 / reserve0; //0.10 WBNB / 900900 FRND
    //     }
        
    //     if(swap) {
    //         address[] memory path = new address[](2);
    //         path[0] = WBNB;
    //         path[1] = address(0xF0F9f3653DccD295e1B2b9Bb4C15365C70Ccf706);

    //         router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
    //             0,
    //             path,
    //             address(msg.sender),
    //             block.timestamp
    //         );
    //         totalReceivedBNB = totalReceivedBNB + msg.value;
    //         nft_contract.mint(msg.sender);
    //         emit Mint(address(msg.sender));
    //     }
    //     require(swap, "Failed to Mint NFT");

    //     // (bool success,) = owner().call{value: msg.value}("");
    //     // require(success, "Failed to send money");
    // }

    function getMembership() public view returns(uint[] memory amountsOutArray) {
        (uint reserveETH, uint reserveToken,) = IPancakePair(pair).getReserves();
        // (address token0) = IPancakePair(pair).token0();
        (address token1) = IPancakePair(pair).token1();

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(0xF0F9f3653DccD295e1B2b9Bb4C15365C70Ccf706);

        uint[] memory amountsOut = router.getAmountsOut(50000000000000000, path); // 0.05 BNB
        return amountsOut;
    } // Works returns amountsOut[1]

    function payMembershipTwo() external payable {
        (uint reserveETH, uint reserveToken,) = IPancakePair(pair).getReserves();
        // (address token0) = IPancakePair(pair).token0();
        (address token1) = IPancakePair(pair).token1();

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(0xF0F9f3653DccD295e1B2b9Bb4C15365C70Ccf706);
        uint deadline = block.timestamp + 100;

        uint[] memory amountsOut = router.getAmountsOut(50000000000000000, path); // 0.05 BNB

        // IDEXRouter(router).swapExactETHForTokens{value: msg.value}(amountsOut[1], path, msg.sender, deadline);

        // (bool success, ) = address(router).call(
        //     abi.encodeWithSignature(
        //         "swapExactETHForTokens(uint256,uint256,address,address)",
        //         msg.value,
        //         amountsOut[1],
        //         path,
        //         address(msg.sender)
        //     )
        // );

        // require(success, "Transaction failed");

    }

    function payMembership() external payable {
        lastReceivedAmount = msg.value;
        require(msg.value >= membership_price_bnb * (10**18), "Not Enough has been sent");

        (uint reserveETH, uint reserveToken,) = IPancakePair(pair).getReserves();
        // (address token0) = IPancakePair(pair).token0();
        (address token1) = IPancakePair(pair).token1();

        if(isWrappedBinanceCoin(token1)) {
            require(msg.value <= reserveToken, "Not enough liquidity in the pool");
            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = address(0xF0F9f3653DccD295e1B2b9Bb4C15365C70Ccf706);

            uint[] memory amountsOut = router.getAmountsOut(msg.value, path);

            // (bool success, ) = address(router).call(
            //     abi.encodeWithSignature(
            //         "swapExactETHForTokens(uint256,uint256,address,address)",
            //         msg.value,
            //         path,
            //         msg.sender,
            //         1674380179
            //     )
            // );

            // require(success, "Transaction failed");

        } else {
            require(msg.value <= reserveETH, "Not enough liquidity in the pool");
            // address[] memory path = new address[](2);
            // path[0] = WBNB;
            // path[1] = address(0xF0F9f3653DccD295e1B2b9Bb4C15365C70Ccf706);


            // (bool success, ) = address(router).call(
            //     abi.encodeWithSignature(
            //         "swapExactETHForTokens(uint256,uint256,address,address)",
            //         msg.value,
            //         path,
            //         msg.sender,
            //         1674380179
            //     )
            // );

            // require(success, "Transaction failed");

        }



        // (bool success,) = owner().call{value: msg.value}("");
        // require(success, "Failed to send money");
    }

    function getReserves() public view returns (uint112, uint112, uint32) {
        // router.getReserves();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IPancakePair(pair).getReserves();
        return (reserve0, reserve0, blockTimestampLast);
    }
    function getToken0() public view returns (address) {
        // router.getReserves();
        (address token0) = IPancakePair(pair).token0();
        return (token0);
    }
    function getToken1() public view returns (address) {
        // router.getReserves();
        (address token1) = IPancakePair(pair).token1();
        return (token1);
    }


    function isWrappedBinanceCoin(address token) public view returns(bool) {
        if(address(token) == 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd) {
            return true;
        }
    }

    function buyTokens(address receiver, uint amount) public view returns(bool)
    {


        // token_contract.buyFRNDTokens(receiver, amount);
        return false;
    }

    function getBNBPerFRND() public view returns(uint112)
    {
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IPancakePair(pair).getReserves();
        (address token0) = IPancakePair(pair).token0();
        (address token1) = IPancakePair(pair).token1();

        uint112 bnbPerFRND;
        if(isWrappedBinanceCoin(token1)) {
            bnbPerFRND = reserve0 / reserve1; // 900900 / 0.10 WBNB
        } else {
            bnbPerFRND = reserve1 / reserve0; //0.10 WBNB / 900900 FRND
        }

        // token_contract.buyFRNDTokens(receiver, amount);
        return bnbPerFRND;
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

    function withdrawWBNB() public onlyOwner
    {
        (bool sent, bytes memory data) = payable(owner()).call{value: address(this).balance}("");
        require(sent, "Failed to send BNB");
        data;
    }

}
