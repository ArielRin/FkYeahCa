import { ConnectButton } from '@rainbow-me/rainbowkit';
import { BrowserRouter as Router, Link as RouterLink, useParams, Routes, Route } from 'react-router-dom';
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
  Image,
  Slider,
  SliderTrack,
  SliderFilledTrack,
  SliderThumb,
  SliderMark,
} from "@chakra-ui/react";

import launchpadAbi from './launchpadABI.json';
import headerLogoImage from "./madcontractsTextLogo.png";
import mainbackgroundImage from "./madbkg.png";
import { contractAddresses, ContractAddresses } from './launchMemeContractAddresses';
import { networkInfo } from './networks';






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
    buyTax: 0,
    sellTax: 0,
    transferTax: 0,
  });
  const toast = useToast();

  useEffect(() => {
    const initializeWeb3 = async () => {
      if ((window as any).ethereum) {
        const web3Instance = new Web3((window as any).ethereum);
        setWeb3(web3Instance);
        const provider = new ethers.providers.Web3Provider((window as any).ethereum);
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

    const handleChainChanged = () => {
      window.location.reload();
    };

    const handleAccountsChanged = (accounts: string[]) => {
      setAccount(accounts[0] || '');
      window.location.reload();
    };

    if ((window as any).ethereum) {
      (window as any).ethereum.on('chainChanged', handleChainChanged);
      (window as any).ethereum.on('accountsChanged', handleAccountsChanged);
    }

    return () => {
      if ((window as any).ethereum) {
        (window as any).ethereum.removeListener('chainChanged', handleChainChanged);
        (window as any).ethereum.removeListener('accountsChanged', handleAccountsChanged);
      }
    };
  }, [toast]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  const handleSliderChange = (value: number, field: string) => {
    setFormData((prevData) => ({
      ...prevData,
      [field]: value,
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

        window.location.reload();
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

  const getNetworkInfo = () => {
    if (chainId && networkInfo[chainId]) {
      return networkInfo[chainId];
    }
    return null;
  };

  const network = getNetworkInfo();

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
          bg="rgba(0, 0, 0, 0.5)"
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
          />
          <ConnectButton />
          <Image src={headerLogoImage} alt="Header Logo" width="75%" margin="0 auto" display="block" mt={4} />

          <Container maxW="container.md" mt={10}>
            <Flex color="white" direction="column" p={5} bg="rgba(0, 0, 0, 0.6)" borderRadius="xl" boxShadow="xl">
              <Box padding={4}>
                <RouterLink style={{ color: 'white', fontWeight: 'bold' }} to="/">Back to Home</RouterLink>
              </Box>
              <Box padding={4}>
                <RouterLink style={{ fontWeight: 'bold' }} to="/list">Deployed Tokens List</RouterLink>
              </Box>
            </Flex>
          </Container>

          {network && (
            <Container maxW="container.md" mt={10}>
              <Flex color="white" direction="column" p={5} bg="rgba(0, 0, 0, 0.6)" borderRadius="xl" boxShadow="xl">
                <Box padding={4}>
                  <Text color="white" fontSize="2xl" mb={4} mt={4}>Welcome to Mad Contracts {network.name} LaunchPad</Text>
                  <Image src={network.icon} alt={network.name} width="50px" height="50px" margin="0 auto" display="block" mb={2} />
                  <Text color="white" fontSize="xl" mb={4}>Create your own {network.name} Meme token with us. Choose up to 10% Buy/Sell taxes. Just pay the gas fees to deploy.</Text>
                  <Text color="white" fontSize="xl" mb={4}>We make it easy for you to launch with "Mad Contracts"</Text>
                  <Text color="white" fontSize="md" mb={4}>Small Transaction fee of 0.5% will be added to the tokenomics of your token as a deployer fee.</Text>
                </Box>
              </Flex>
            </Container>
          )}

          <Container maxW="container.md" mt={10}>
            <Flex color="white" direction="column" p={5} bg="rgba(0, 0, 0, 0.6)" borderRadius="xl" boxShadow="xl">
              <Text fontSize="2xl" mb={4}>Deploy Your Own Meme Token</Text>

              <Text mb={2}>Token Name</Text>
              <Input
                placeholder="Name"
                name="name"
                color="white"
                value={formData.name}
                onChange={handleInputChange}
                mb={3}
              />
              <Text mb={2}>Token Symbol</Text>
              <Input
                placeholder="Symbol"
                name="symbol"
                color="white"
                value={formData.symbol}
                onChange={handleInputChange}
                mb={3}
              />
              <Text mb={2}>Token Total Supply</Text>
              <Input
                placeholder="Initial Supply"
                name="initialSupply"
                color="white"
                value={formData.initialSupply}
                onChange={handleInputChange}
                mb={3}
              />

              <Box mb={4}>
                <Text mb={2}>Buy Tax: {formData.buyTax}%</Text>
                <Slider
                  defaultValue={formData.buyTax}
                  min={0}
                  max={9.5}
                  step={1}
                  onChange={(val) => handleSliderChange(val, 'buyTax')}
                >
                  <SliderTrack>
                    <SliderFilledTrack />
                  </SliderTrack>
                  <SliderThumb boxSize={6}>
                    <Box color="tomato" />
                  </SliderThumb>
                </Slider>
              </Box>

              <Box mb={4}>
                <Text mb={2}>Sell Tax: {formData.sellTax}%</Text>
                <Slider
                  defaultValue={formData.sellTax}
                  min={0}
                  max={9.5}
                  step={1}
                  onChange={(val) => handleSliderChange(val, 'sellTax')}
                >
                  <SliderTrack>
                    <SliderFilledTrack />
                  </SliderTrack>
                  <SliderThumb boxSize={6}>
                    <Box color="tomato" />
                  </SliderThumb>
                </Slider>
              </Box>

              <Box mb={4}>
                <Text mb={2}>Transfer Tax: {formData.transferTax}%</Text>
                <Slider
                  defaultValue={formData.transferTax}
                  min={0}
                  max={9.5}
                  step={1}
                  onChange={(val) => handleSliderChange(val, 'transferTax')}
                >
                  <SliderTrack>
                    <SliderFilledTrack />
                  </SliderTrack>
                  <SliderThumb boxSize={6}>
                    <Box color="tomato" />
                  </SliderThumb>
                </Slider>
              </Box>

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
          />
        </Box>
      </Box>
    </Box>
  );
};

export default LaunchPad;
