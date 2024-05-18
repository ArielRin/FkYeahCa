import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Link as RouterLink, useParams,  Routes, Route } from 'react-router-dom';

import { ConnectButton } from '@rainbow-me/rainbowkit';

import {
  Box,
  Container,
  Flex,
  Link,
  Tabs,
  TabList,
  TabPanels,
  Tab,
  TabPanel,
  Text,
  useToast,
  Button,
  Input,
} from '@chakra-ui/react';




import Web3 from 'web3';
import { ethers } from 'ethers';
import { useAccount, useContractRead, useContractWrite } from 'wagmi';

function App() {

  return (
    <>

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


      <Text fontSize="2xl" mb={4}>Some shit hot front page or just have launch here</Text>


          <Container maxW="container.md" mt={10}>

            <Flex color="white" direction="column" p={5} bg="rgba(0, 0, 0, 0.6)" borderRadius="md" boxShadow="md">

              <Box        padding={4}>
              <RouterLink style={{ fontWeight: 'bold' }} to="/launch"> Go to LaunchPad</RouterLink>
              </Box>
              <Box        padding={4}>
              <RouterLink style={{ fontWeight: 'bold' }} to="/list"> Deployed Tokens List</RouterLink>

              </Box>
            </Flex>
         </Container>
      <div
        className="wrapper"
        style={{
          backgroundColor: 'black',
          color: 'white',
          backgroundSize: 'cover',
        }}
      >
      </div>
    </>
  );
}

export default App;


// ***
