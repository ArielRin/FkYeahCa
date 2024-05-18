import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import { Box, Text, Container, List, ListItem } from '@chakra-ui/react';
import { contractAddresses } from './launchMemeContractAddresses';
import launchpadAbi from './launchpadABI.json';

const LaunchPad: React.FC = () => {
  const [tokens, setTokens] = useState<any[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    const fetchTokens = async () => {
      if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(window.ethereum as any);
        const network = await provider.getNetwork();
        const contractAddress = contractAddresses[network.chainId]?.launchpad;

        if (!contractAddress) {
          console.error("Unsupported network");
          return;
        }

        const contract = new ethers.Contract(contractAddress, launchpadAbi, provider);

        try {
          const tokensList = [];
          const totalTokens = 20; // Assume there could be up to 50 tokens

          for (let i = totalTokens - 1; i >= 0; i--) {
            try {
              const tokenAddress = await contract.tokenById(i);
              const tokenDetails = await contract.getTokenDetailsById(i);
              tokensList.push({
                id: tokenDetails.id.toString(),
                address: tokenAddress,
                name: tokenDetails.name,
                symbol: tokenDetails.symbol,
                initialSupply: ethers.utils.formatUnits(tokenDetails.initialSupply, 18),
                buyTax: tokenDetails.buyTax.toString(),
                sellTax: tokenDetails.sellTax.toString(),
                transferTax: tokenDetails.transferTax.toString(),
                owner: tokenDetails.owner
              });
            } catch (error) {
              console.error(`Error fetching token ID ${i}:`, error);
              // Move on to the next token ID
            }
          }

          setTokens(tokensList);
          setLoading(false);
        } catch (error) {
          console.error("Error fetching tokens:", error);
        }
      }
    };

    fetchTokens();
  }, []);

  if (loading) {
    return <Text>Loading...</Text>;
  }

  return (
    <Container>
      <Text fontSize="2xl" mb={4}>List of Deployed Tokens</Text>
      <List spacing={3}>
        {tokens.map((token, index) => (
          <ListItem key={index} border="1px solid" borderColor="gray.200" p={3} borderRadius="md">
            <Text fontSize="lg"><strong>ID:</strong> {token.id}</Text>
            <Text><strong>Address:</strong> {token.address}</Text>
            <Text><strong>Name:</strong> {token.name}</Text>
            <Text><strong>Symbol:</strong> {token.symbol}</Text>
            <Text><strong>Initial Supply:</strong> {token.initialSupply}</Text>
            <Text><strong>Buy Tax:</strong> {token.buyTax}%</Text>
            <Text><strong>Sell Tax:</strong> {token.sellTax}%</Text>
            <Text><strong>Transfer Tax:</strong> {token.transferTax}%</Text>
            <Text><strong>Owner:</strong> {token.owner}</Text>
          </ListItem>
        ))}
      </List>
    </Container>
  );
};

export default LaunchPad;
