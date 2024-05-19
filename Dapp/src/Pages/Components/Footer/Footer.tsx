import React from 'react';

import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalBody,
  ModalCloseButton,
  useDisclosure,
  Box,
  Link as ChakraLink,
  Flex,
  Container,
  SimpleGrid,
  VStack,
  Tabs,
  TabList,
  TabPanels,
  Spacer,
  Tab,
  TabPanel,
  Input,
  Button,
  Text,
  Image,
  useToast,
  Collapse,
} from "@chakra-ui/react";



const Footer: React.FC = () => {
    const currentYear = new Date().getFullYear();

        return (
          <footer style={{ backgroundColor: '#000', color: 'white', textAlign: 'center', padding: '20px 0' }}>
              <Flex direction="column" alignItems="center">


                  <Image
                      src="https://raw.githubusercontent.com/ArielRin/MericaFkYeahCa/master/Dapp/src/Pages/Launch/madcontractsTextLogo.png"
                      alt="Logo"
                      width="230px"
                  />
                  <span>&copy; {currentYear} Mad Contracts Multichain Launchpad. All rights reserved.</span>
              </Flex>
          </footer>
        );
    };

    export default Footer;

// <span>
//     Follow us on
//     <a href="https://twitter.com" target="_blank" rel="noopener noreferrer" style={{ color: 'white', margin: '0 10px' }}>Twitter</a>,
//     <a href="https://facebook.com" target="_blank" rel="noopener noreferrer" style={{ color: 'white', margin: '0 10px' }}>Facebook</a>,
//     <a href="https://instagram.com" target="_blank" rel="noopener noreferrer" style={{ color: 'white', margin: '0 10px' }}>Instagram</a>
// </span>
