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
    
    uint256 _currentMintCount = 0;                  //當前已經mint的數量
    uint256 public sellPrice;                       //NFT售價
    uint256 public saleStartTime;                   //開始販售時間
    mapping(address => bool) _whitelist;            //白名單
    
    //鑄造指定NFT
    constructor() ERC721("Knot NFT", "KNFT") {
        sellPrice = KNFT_SELL_PRICE;
    }

    //------------
    //override
    //------------

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721) {
        super._afterTokenTransfer(from, to, tokenId);

        //通知白名單已鑄造
        _whitelistDidMint();
    }

    //------------
    // private functions
    //------------

    /**
    * @dev 判斷是否可鑄造
    * @param amount 鑄造數量
    * @return result 是否可鑄造
    */
    function _isMintable(uint256 amount) view private returns (bool result){
        require(amount > 0, "KnotNFT: amount can't be zero.");
        require(_isMintableAddress(msg.sender), "KnotNFT: Your not in whitelist.");
        require(msg.value >= sellPrice, "KnotNFT: Not enough ETH sent, please check the price.");
        require(block.timestamp >= saleStartTime, "KnotNFT: It's not on sale yet.");
        return mintableCount() > amount;
    }

    /**
    * @dev 發行NFT, 設置總量, 只有合約擁有者可以使用此方法。
    * @param receiver 指定接收者
    * @param amount 發行量
    */
    function _publishKnotNFT(uint256 amount, address receiver) private { 
        require(receiver != address(0), "KnotNFT: mint to the zero address.");

        //檢查是否可以鑄造
        require(_isMintable(amount), "KnotNFT: token can't mint.");

        for(uint256 i = 0; i < amount; i++) {
            uint256 tokenID = _currentMintCount++;
            _safeMint(receiver, tokenID);
        }
    }

    /**
    * @dev 鑄造後設置白名單相關參數
    */
    function _whitelistDidMint() private {
        _whitelist[msg.sender] = false;
    }

    /**
    * @dev 查詢此地址是否可鑄造
    * @param mintAddress 鑄造者
    */
    function _isMintableAddress(address mintAddress) private view returns (bool) {
        if (mintAddress == owner()) {
            return true;
        }
        return isInWhitelist(mintAddress);
    }

    //------------
    // public functions
    //------------

    /**
    * @dev 鑄造單一NFT
    */
    function mint() public payable {
        _publishKnotNFT(1, msg.sender);
    }

    /**
    * @dev 查詢剩餘可鑄造數量
    */
    function mintableCount() public view returns (uint256 count) {
        return MAX_MINT_COUNT - _currentMintCount;
    }

    /**
    * @dev 查詢總發行上限
    */
    function maxMintCount() public pure returns (uint256 count) {
        return MAX_MINT_COUNT;
    }

    /**
    * @dev 查詢是否在白名單內
    */
    function isInWhitelist(address addr) public view returns (bool){
        return _whitelist[addr];
    }

    /**
    * @dev 設定NFT售價
    * @param price 銷售價格
    */
    function setSellPrice(uint256 price) public onlyOwner {
        sellPrice = price;
    }

    /**
    * @dev 設置銷售時間
    */
    function setSaleStartTime(uint256 startTime) public onlyOwner {
        saleStartTime = startTime;
    }

    /**
    * @dev 設置白名單
    * @param whitelistAddr 白名單地址
    */
    function addToWhitelist(address whitelistAddr) public onlyOwner {
        require(whitelistAddr != address(0), "Can't add the null address.");
        require(!isInWhitelist(whitelistAddr), "You're aright in whitelist.");
        _whitelist[whitelistAddr] = true;
    }
}