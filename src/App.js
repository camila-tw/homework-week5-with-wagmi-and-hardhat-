import './App.css';
import { useAccount, useConnect, useNetwork, chain, useDisconnect, useContractRead, useContractWrite} from "wagmi";
import React, { useEffect } from 'react';
import { contractABI, contractAddress } from "./configs/contract.js";
import {ethers} from "ethers";

function App() {
  const { connect, connectors, isConnecting, pendingConnector} = useConnect();
  const { data: account} = useAccount();
  const { activeChain, switchNetwork } = useNetwork( { chainId: chain.rinkeby.id });
  const { disconnect } = useDisconnect();

  /**
   * @dev 合約互動：查詢已鑄造數量
   */
  const { data: totalSupply} = useContractRead(
    {
      addressOrName: contractAddress,
      contractInterface: contractABI,
    },
    'totalSupply',
    { watch: true},
  );

   /**
   * @dev 合約互動：查詢帳戶餘額
   */
  const { data: accountBalance } = useContractRead(
    {
      addressOrName: contractAddress,
      contractInterface: contractABI,
    },
    "balanceOf",
    {
      args: [account?.address],
      watch: true,
    }
  );

   /**
   * @dev 合約互動：查詢剩餘可鑄造
   */
   const { data: mintableCount} = useContractRead(
    {
      addressOrName: contractAddress,
      contractInterface: contractABI,
    },
    'mintableCount',
    { watch: true},
  );

   /**
   * @dev 合約互動：查詢發行總量
   */
   const { data: maxMintCount} = useContractRead(
    {
      addressOrName: contractAddress,
      contractInterface: contractABI,
    },
    'maxMintCount'
  );

  /**
   * @dev 合約互動：查詢售價
   */
   const { data: sellPrice} = useContractRead(
    {
      addressOrName: contractAddress,
      contractInterface: contractABI,
    },
    'sellPrice'
  );

  const price = (sellPrice) ? ethers.utils.formatEther(sellPrice) : 0;

   /**
   * @dev 合約互動：鑄造NFT
   */
   const { write: mint, isLoading: isMintLoading} = useContractWrite(
    {
      addressOrName: contractAddress,
      contractInterface: contractABI,
    },
    'mint',
    {
      overrides: {
        value: price ? ethers.utils.parseEther(price?.toString()) : null,
      },
    }
  );
  const startMintNFT = () => { mint() };

  // const getSellTime = () => {
  //   let today = new Date();
  //   today.setDate(today.getSeconds() + 10); // add 10 seconds
  //   return Math.floor(today.getTime() / 1000); // unix timestamp
  // };

  // console.log("sell time: " + getSellTime());

  //  /**
  //  * @dev 合約互動：設置開始銷售時間
  //  */
  //  const { write: setSaleStartTime} = useContractWrite(
  //   {
  //     addressOrName: contractAddress,
  //     contractInterface: contractABI,
  //   },
  //   'setSaleStartTime',
  //   {
  //     overrides: {
  //       value: getSellTime(),
  //     },
  //   }
  // );
  // const setStartSellTime = () => {
  //   setSaleStartTime();
  // };

  useEffect(() => {
    if (activeChain && activeChain.id !== chain.localhost.id) {
      switchNetwork();
    }
  }, [activeChain, switchNetwork]);

  return (
    <div className="App">
      <header className="App-header">
        { account ? 
        (
          <div> 
            <button onClick={disconnect}>取消連結</button>
            <div>&nbsp;</div>
            <div> 我的錢包地址: {account.address}</div>
            <hr />
            <h2> NFT Content：</h2>
            { totalSupply && <div> 已鑄造： { totalSupply.toNumber() } </div> }
            { accountBalance && <div> 擁有數量：{ accountBalance.toNumber() } </div> }
            
            <h2> Sales Content：</h2>
            <div> 銷售金額： {price.toString()} ETH</div>
            { maxMintCount && <div> 總發行量：{ maxMintCount.toNumber() }</div> }
            { mintableCount && <div> 剩餘可售：{ mintableCount.toNumber() }</div> }
            {/* <div> 銷售倒數：</div> */}
            <div>&nbsp;</div>
            {/* <button onClick={setStartSellTime}>設置開始銷售時間為10秒後</button> */}
            <div>&nbsp;</div>
            { !isMintLoading && activeChain && <button onClick={startMintNFT}>鑄造</button> }
          </div>
        ) :     
        (
          <div> 
            {connectors.map((connector) => (
              <button disabled={!connector.ready} key={connector.id} onClick={() => connect(connector)}>
                {connector.name}
                {!connector.ready && " (不支援)"}
                {isConnecting && connector.id === pendingConnector?.id && " (連結中)"}
              </button>
            ))}
          </div>
        )
        }
      </header>
    </div>
  );
}

export default App;
