import { ConnectButton } from '@rainbow-me/rainbowkit';
import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import { ethers } from 'ethers';
import {
  Box,
  Input,
  Button,
  Text,
  useToast,
  Flex,
  Container,
  Image
} from "@chakra-ui/react";

import launchpadAbi from './launchpadABI.json';


import headerLogoImage from "./fkyeah.png";
import mainbackgroundImage from "./madz.png";


// this is the test one before chat decided chains to go on...
// const LAUNCHPAD_CONTRACT_ADDRESS = "0xd625b812E7799E330292C324F5f478F3122f0728";
// end test ca now use external code with contract fr the chain on.
// import { contractAddresses } from './launchMemeContractAddresses';

import { contractAddresses, ContractAddresses } from './launchMemeContractAddresses';

const LaunchPad: React.FC = () => {
  const [web3, setWeb3] = useState<Web3 | null>(null);
  const [contract, setContract] = useState<ethers.Contract | null>(null);
  const [treasuryAddress, setTreasuryAddress] = useState<string>('');
  const [account, setAccount] = useState<string>('');
  const [chainId, setChainId] = useState<number | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    symbol: '',
    initialSupply: '',
    buyTax: '',
    sellTax: '',
    transferTax: ''
  });
  const toast = useToast();

  useEffect(() => {
    const initializeWeb3 = async () => {
      if (window.ethereum) {
        const web3Instance = new Web3(window.ethereum);
        setWeb3(web3Instance);
        const provider = new ethers.providers.Web3Provider(window.ethereum as any);
        const signer = provider.getSigner();
        const accounts = await provider.listAccounts();
        setAccount(accounts[0]);

        const network = await provider.getNetwork();
        setChainId(network.chainId);

        const launchpadAddress = (contractAddresses as ContractAddresses)[network.chainId]?.launchpad;
        if (!launchpadAddress) {
          toast({
            title: "Unsupported network",
            description: "Please connect to a supported network.",
            status: "error",
            duration: 9000,
            isClosable: true,
          });
          return;
        }

        const contractInstance = new ethers.Contract(launchpadAddress, launchpadAbi, signer);
        setContract(contractInstance);
        const treasury = await contractInstance.treasuryAddress();
        setTreasuryAddress(treasury);
      } else {
        toast({
          title: "No EVM provider detected",
          description: "Please install MetaMask, use injected or another wallet extension.",
          status: "error",
          duration: 9000,
          isClosable: true,
        });
      }
    };

    initializeWeb3();
  }, [toast]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  const deployToken = async () => {
    if (contract) {
      try {
        const tx = await contract.deployMemeToken(
          formData.name,
          formData.symbol,
          ethers.utils.parseUnits(formData.initialSupply, 18),
          formData.buyTax,
          formData.sellTax,
          formData.transferTax,
          account,
          treasuryAddress
        );
        await tx.wait();
        toast({
          title: "Token deployed successfully",
          description: `Token deployed at address: ${tx.to}`,
          status: "success",
          duration: 9000,
          isClosable: true,
        });
      } catch (error) {
        const errorMessage = (error as Error).message;
        console.error("Error deploying token:", errorMessage);
        toast({
          title: "Error deploying token",
          description: errorMessage,
          status: "error",
          duration: 9000,
          isClosable: true,
        });
      }
    }
  };


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
        <Image src={headerLogoImage} alt="Header Logo" width="75%" margin="0 auto" display="block" mt={4} />
        <ConnectButton />

        <Box padding={4}>
          <Text color="white" fontSize="2xl" mb={4} mt={4}>Welcome to FuckYeah Contracts ERC20 LaunchPad</Text>
          <Text color="white" fontSize="xl" mb={4}>Create your own Meme token with us. Choose up to 10% Buy/Sell taxes. Just pay the gas fees to deploy.</Text>
          <Text color="white" fontSize="xl" mb={4}>We make it easy for you to launch with "FuckYeah Contracts"</Text>
          <Text color="white" fontSize="md" mb={4}>Small Transaction fee of 0.5% will be added to the tokenomics of your token as a deployer fee.</Text>
        </Box>


        <Container maxW="container.md" mt={10}>

          <Flex color="white" direction="column" p={5} bg="rgba(0, 0, 0, 0.6)" borderRadius="md" boxShadow="md">

        <Text fontSize="2xl" mb={4}>Deploy Your Own Meme Token</Text>

            <Input
              placeholder="Name"
              name="name"
              color="white"
              value={formData.name}
              onChange={handleInputChange}
              mb={3}
            />
            <Input
              placeholder="Symbol"
              name="symbol"
              color="white"
              value={formData.symbol}
              onChange={handleInputChange}
              mb={3}
            />
            <Input
              placeholder="Initial Supply"
              name="initialSupply"
              color="white"
              value={formData.initialSupply}
              onChange={handleInputChange}
              mb={3}
            />
            <Input
              placeholder="Buy Tax"
              name="buyTax"
              color="white"
              value={formData.buyTax}
              onChange={handleInputChange}
              mb={3}
            />
              <Input
                placeholder="Sell Tax"
                name="sellTax"
                color="white"
                value={formData.sellTax}
                onChange={handleInputChange}
                mb={3}
                />
              <Input
                placeholder="Transfer Tax"
                name="transferTax"
                color="white"
                value={formData.transferTax}
                onChange={handleInputChange}
                mb={3}
              />
            <Button colorScheme="blue" onClick={deployToken}>Deploy Token</Button>
          </Flex>
        </Container>
      </Box>
    </Box>
  );
};

export default LaunchPad;
