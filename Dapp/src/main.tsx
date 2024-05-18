import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "@rainbow-me/rainbowkit/styles.css";
import { getDefaultWallets, RainbowKitProvider, darkTheme } from "@rainbow-me/rainbowkit";
import { chain, configureChains, createClient, WagmiConfig, Chain } from "wagmi";
import { jsonRpcProvider } from "wagmi/providers/jsonRpc";
import { publicProvider } from "wagmi/providers/public";
import { ChakraProvider } from "@chakra-ui/react";


const bsc: Chain = {
  id: 56,
  name: 'Binance Smart Chain',
  network: 'bsc',
  nativeCurrency: {
    decimals: 18,
    name: 'Binance Coin',
    symbol: 'BNB',
  },
  rpcUrls: {
    default: 'https://bsc-dataseed.binance.org/',
  },
  blockExplorers: {
    default: { name: 'BscScan', url: 'https://bscscan.com/' },
  },
  testnet: false,
};

const base: Chain = {
  id: 8453,
  name: 'Base Mainnet',
  network: 'base',
  nativeCurrency: {
    decimals: 18,
    name: 'Ethereum',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: 'https://mainnet.base.org/',
  },
  blockExplorers: {
    default: { name: 'BaseScan', url: 'https://basescan.org/' },
  },
  testnet: false,
};

const cronos: Chain = {
  id: 25,
  name: 'Cronos',
  network: 'cronos',
  nativeCurrency: {
    decimals: 18,
    name: 'Cro Coin',
    symbol: 'CRO',
  },
  rpcUrls: {
    default: 'https://evm.cronos.org/',
  },
  blockExplorers: {
    default: { name: 'CroScan', url: 'https://explorer.cronos.org/' },
  },
  testnet: false,
};

const mainnet: Chain = {
  id: 1,
  name: 'Ethereum',
  network: 'mainnet',
  nativeCurrency: {
    decimals: 18,
    name: 'Ethereum',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: 'https://mainnet.infura.io/v3/',
  },
  blockExplorers: {
    default: { name: 'Etherscan', url: 'https://etherscan.io' },
  },
  testnet: false,
};
const { chains, provider } = configureChains(
  [bsc, base, cronos, mainnet],
  [
    jsonRpcProvider({
      rpc: (chain) => {
        if (chain.id === bsc.id) return { http: "https://bsc-dataseed.binance.org/" };
        if (chain.id === base.id) return { http: "https://mainnet.base.org/" };
        if (chain.id === cronos.id) return { http: "https://evm.cronos.org/" };
        if (chain.id === mainnet.id) return { http: "https://mainnet.infura.io/v3/" };
        return { http: chain.rpcUrls.default };
      },
    }),
    publicProvider(),
  ]
);

const { connectors } = getDefaultWallets({
  appName: "Fk Yeah Contracts 2024",
  chains,
});

const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
});

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <ChakraProvider>
      <WagmiConfig client={wagmiClient}>
        <RainbowKitProvider modalSize="compact" chains={chains}
        theme={darkTheme({
              accentColor: '#4b99ff',
              accentColorForeground: 'white',
              borderRadius: 'small',
              fontStack: 'system',
              overlayBlur: 'small',
            })}

        >
          <App />
        </RainbowKitProvider>
      </WagmiConfig>
    </ChakraProvider>
  </React.StrictMode>
);
