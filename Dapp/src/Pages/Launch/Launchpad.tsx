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


import headerLogoImage from "./madcontractsTextLogo.png";
import mainbackgroundImage from "./madbkg.png";


// this is the test one before chat decided chains to go on...
// const LAUNCHPAD_CONTRACT_ADDRESS = "0xd625b812E7799E330292C324F5f478F3122f0728";
// end test ca now use external code with contract fr the chain on.
// import { contractAddresses } from './launchMemeContractAddresses';

import { contractAddresses, ContractAddresses } from './launchMemeContractAddresses';




const LaunchPad: React.FC = () => {
  const [web3, setWeb3] = useState<Web3 | null>(null);
  const [contract, setContract] = useState<ethers.Contract | null>(null);
  const [deployerFee1, setDeployerFee1] = useState<string>('');
  const [deployerFee2, setDeployerFee2] = useState<string>('');
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

        const deployerFee1 = await contractInstance.deployerFee1();
        const deployerFee2 = await contractInstance.deployerFee2();
        setDeployerFee1(deployerFee1);
        setDeployerFee2(deployerFee2);
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
        const initialSupply = ethers.utils.parseUnits(formData.initialSupply, 18);
        const buyTax = ethers.BigNumber.from(formData.buyTax);
        const sellTax = ethers.BigNumber.from(formData.sellTax);
        const transferTax = ethers.BigNumber.from(formData.transferTax);

        const tx = await contract.deployMemeToken(
          formData.name,
          formData.symbol,
          initialSupply,
          buyTax,
          sellTax,
          transferTax,
          account
        );

        const receipt = await tx.wait();

        toast({
          title: "Token deployed successfully",
          description: `Token deployed at address: ${receipt.to}`,
          status: "success",
          duration: 9000,
          isClosable: true,
        });
      } catch (error) {
        console.error("Error deploying token:", error);

        let errorMessage = (error as Error).message;
        if ((error as any).data?.message) {
          errorMessage = (error as any).data.message;
        } else if ((error as any).error?.message) {
          errorMessage = (error as any).error.message;
        }

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

        <Container maxW="container.md" mt={10}>
          <Flex color="white" direction="column" p={5} bg="rgba(0, 0, 0, 0.6)" borderRadius="md" boxShadow="md">
            <Box padding={4}>
              <Text color="white" fontSize="2xl" mb={4} mt={4}>Welcome to Mad Contracts ERC20 LaunchPad</Text>
              <Text color="white" fontSize="xl" mb={4}>Create your own Meme token with us. Choose up to 10% Buy/Sell taxes. Just pay the gas fees to deploy.</Text>
              <Text color="white" fontSize="xl" mb={4}>We make it easy for you to launch with "Mad Contracts"</Text>
              <Text color="white" fontSize="md" mb={4}>Small Transaction fee of 0.5% will be added to the tokenomics of your token as a deployer fee.</Text>
            </Box>
          </Flex>
        </Container>

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

        <Box
          flex={1}
          p={0}
          m={0}
          display="flex"
          flexDirection="column"
          bg="rgba(0, 0, 0, 0)"
          marginBottom="250px"
        >
        </Box>
      </Box>
    </Box>
  );
};

export default LaunchPad;
