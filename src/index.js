import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import { WagmiConfig, createClient, chain, configureChains } from 'wagmi';
import { jsonRpcProvider } from 'wagmi/providers/jsonRpc'
import { publicProvider } from "wagmi/providers/public";
import { MetaMaskConnector } from "wagmi/connectors/metaMask";

const root = ReactDOM.createRoot(document.getElementById('root'));

const { chains, provider, webSocketProvider } = configureChains(
  [chain.localhost],
  [
    jsonRpcProvider({
      rpc: (chain) => ({
        http: `http://localhost:8545`,
      }),
    }),
    publicProvider(),
  ],
)

const client = createClient({
  autoConnect: true,
  connectors: [
    new MetaMaskConnector({ chains }),
  ],
  provider,
  webSocketProvider,
});

root.render(
  <React.StrictMode>
    <WagmiConfig client={client}>
    <App />
    </WagmiConfig>
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
