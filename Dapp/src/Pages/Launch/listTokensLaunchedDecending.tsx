import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import { Box, Text, Container, List, ListItem, Flex, Link } from '@chakra-ui/react';
import { contractAddresses } from './launchMemeContractAddresses';
import { chainExplorerUrls } from './chainExplorerLinks';
import launchpadAbi from './launchpadABI.json';

const LaunchPad: React.FC = () => {
  const [tokens, setTokens] = useState<any[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [explorerUrl, setExplorerUrl] = useState<string | null>(null);

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

        setExplorerUrl(chainExplorerUrls[network.chainId] || null);

        const contract = new ethers.Contract(contractAddress, launchpadAbi, provider);

        try {
          const tokensList = [];
          const totalTokens = 20;

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
              });
            } catch (error) {
              console.error(`Error fetching token ID ${i}:`, error);
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
    <Container maxW="70%">
      <Text fontSize="2xl" mb={4}>Latest Deployed with Mad Contracts</Text>
      <Flex justify="space-between" mb={2} fontWeight="bold">
        <Text flex="1">Name</Text>
        <Text flex="1">Symbol</Text>
        <Text flex="2">Address</Text>
        <Text flex="1">Initial Supply</Text>
      </Flex>
      <List spacing={3}>
        {tokens.map((token, index) => (
          <ListItem key={index} border="1px solid" borderColor="gray.200" p={3} borderRadius="md">
            <Flex justify="space-between">
              <Text flex="1">{token.name}</Text>
              <Text flex="1">{token.symbol}</Text>
              <Text flex="2">
                {explorerUrl ? (
                  <Link href={`${explorerUrl}${token.address}`} isExternal>
                    {token.address}
                  </Link>
                ) : (
                  token.address
                )}
              </Text>
              <Text flex="1">{token.initialSupply}</Text>
            </Flex>
          </ListItem>
        ))}
      </List>
    </Container>
  );
};

export default LaunchPad;
