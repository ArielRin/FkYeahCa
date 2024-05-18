import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import { Box, Text, Image, Container, List, ListItem, Flex, Link } from '@chakra-ui/react';
import { contractAddresses } from './launchMemeContractAddresses';
import { chainExplorerUrls } from './chainExplorerLinks';
import launchpadAbi from './launchpadABI.json';
import { ConnectButton } from '@rainbow-me/rainbowkit';


import headerLogoImage from "./madcontractsTextLogo.png";
import mainbackgroundImage from "./madbkg.png";


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
          const totalTokens = 10;

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

      <Box>
    <Box
      flex={1}
      p={0}
      m={0}
      display="flex"
      flexDirection="column"
      bg="rgba(0, 0, 0, 1)"

      bgImage={`url(${mainbackgroundImage})`}
      bgPosition="center"
      bgRepeat="no-repeat"
      bgSize="cover"
    >

    <Box
      flex={1}
      p={0}
      m={0}
      display="flex"
      flexDirection="column"
      bg="rgba(0, 0, 0, 0)"
      marginTop="50px"
    >
    </Box>
            <ConnectButton />
            <Image src={headerLogoImage} alt="Header Logo" width="75%" margin="0 auto" display="block" mt={4} />
            <Box
              flex={1}
              p={0}
              m={0}
              display="flex"
              flexDirection="column"
              bg="rgba(0, 0, 0, 0)"
              marginBottom="100px"
            >
            </Box>
    <Container
    bg="rgba(0, 0, 0, 0.7)" marginBottom="200px" color="white" >
      <Text fontSize="2xl" mb={4}>Latest Deployed with Mad Contracts</Text>
      <Flex justify="space-between" mb={2} fontWeight="bold">

        <Text flex="1">Symbol</Text>
        <Text flex="2">Address</Text>
      </Flex>
      <List spacing={3}>
        {tokens.map((token, index) => (
          <ListItem key={index}  p={3} >
            <Flex justify="space-between">

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
            </Flex>
          </ListItem>
        ))}
      </List>

    </Container>

    <Box
      flex={1}
      p={0}
      m={0}
      display="flex"
      flexDirection="column"
      bg="rgba(0, 0, 0, 0)"
      marginBottom="400px"
    >
    </Box>
    </Box>

      </Box>
  );
};

export default LaunchPad;
