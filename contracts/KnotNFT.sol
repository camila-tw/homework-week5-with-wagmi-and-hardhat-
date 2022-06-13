// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//發行總量
uint256 constant MAX_MINT_COUNT = 10000;

uint256 constant KNFT_SELL_PRICE = 0.05 ether;

contract KnotNFT is ERC721, ERC721Enumerable, Ownable, ERC721Burnable{

    //---------------
    //initialize
    //---------------
    
    uint256 _currentMintCount = 0;  //當前已經mint的數量
    uint256 public sellPrice;       //NFT售價
    uint256 public saleStartTime;   //開始販售時間
    
    //鑄造指定NFT
    constructor() ERC721("Knot NFT", "KNFT") {
        sellPrice = KNFT_SELL_PRICE;

    }

    //------------
    //override
    //------------

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //------------
    // private functions
    //------------
    
    /**
    * @dev 鑄造, 只有合約擁有者可以使用此方法。
    * @param to 指定地址
    * @param tokenId NFT ID
    */
    function safeMint(address to, uint256 tokenId) private {
        _safeMint(to, tokenId);
    }

    /**
    * @dev 剩餘可鑄造數量是否可以再接受新的鑄造數量
    * @return result 是否可鑄造
    */
    function isMintable(uint256 amount) view private returns (bool result){
       return mintableCount() > amount;
    }

    /**
    * @dev 發行NFT, 設置總量, 只有合約擁有者可以使用此方法。
    * @param amount 發行量
    */
    function publishKnotNFT(uint256 amount) private {
        publishKnotNFT(amount, msg.sender);
    }

    /**
    * @dev 發行NFT, 設置總量, 只有合約擁有者可以使用此方法。
    * @param amount 指定接收者
    * @param amount 發行量
    */
    function publishKnotNFT(uint256 amount, address receiver) private {
        require(amount > 0, unicode"KnotNFT: 鑄造需大於0");
        require(receiver != address(0), "KnotNFT: mint to the zero address");

        //檢查是否可以鑄造
        require(isMintable(amount), unicode"KnotNFT: 發行總量超過上限");

        for(uint256 i = 0; i < amount; i++) {
            uint256 tokenID = _currentMintCount++;
            safeMint(receiver, tokenID);
        }
    }
    
    //------------
    // public functions
    //------------

    /**
    * @dev 鑄造單一NFT
    */
    function mint() public payable{
        require(msg.value >= sellPrice, "Not enough ETH sent, please check the price.");
        require(block.timestamp >= saleStartTime, "It's not on sale yet.");
        publishKnotNFT(1);
    }

    /**
    * @dev 查詢剩餘可鑄造數量
    */
    function mintableCount() public view returns (uint256 count){
        return MAX_MINT_COUNT - _currentMintCount;
    }

    /**
    * @dev 查詢總發行上限
    */
    function maxMintCount() public pure returns (uint256 count){
        return MAX_MINT_COUNT;
    }

    /**
    * @dev 設定NFT售價
    * @param price 銷售價格
    */
    function setSellPrice(uint256 price) public onlyOwner{
        sellPrice = price;
    }

    /**
    * @dev 設置銷售時間
    */
    function setSaleStartTime(uint256 startTime) public onlyOwner{
        saleStartTime = startTime;
    }
}