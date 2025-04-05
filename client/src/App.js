import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import TicketNFT from './TicketNFT.json'; // ABI JSON exported from Remix
import './App.css'; // Make sure you have your CSS file for styling

const CONTRACT_ADDRESS = "YOUR_DEPLOYED_CONTRACT_ADDRESS";

function App() {
  const [account, setAccount] = useState(null);
  const [txStatus, setTxStatus] = useState("");

  // Connect to MetaMask wallet
  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setAccount(accounts[0]);
      } catch (error) {
        console.error("Error connecting wallet:", error);
      }
    } else {
      alert("Please install MetaMask.");
    }
  };

  // Mint a new NFT ticket
  const mintTicket = async () => {
    if (!account) return alert("Please connect your wallet first.");
    setTxStatus("Minting...");
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, TicketNFT.abi, signer);
      const tx = await contract.mintTicket({ value: ethers.utils.parseEther("0.01") });
      await tx.wait();
      setTxStatus("Ticket minted! Transaction hash: " + tx.hash);
    } catch (error) {
      console.error("Minting error:", error);
      setTxStatus("Minting failed");
    }
  };

  useEffect(() => {
    connectWallet();
  }, []);

  return (
    <div className="app-container">
      <h1 className="app-header">NFT Ticketing DApp</h1>
      {account ? (
        <p className="wallet-info">Connected: {account}</p>
      ) : (
        <button className="btn" onClick={connectWallet}>Connect Wallet</button>
      )}
      <button className="btn" onClick={mintTicket}>
        Mint Ticket (0.01 ETH)
      </button>
      <p className="tx-status">{txStatus}</p>
    </div>
  );
}

export default App;
