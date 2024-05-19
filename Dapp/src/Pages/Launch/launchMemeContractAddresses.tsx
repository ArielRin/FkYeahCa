// @CMH. added chainlist for launchpad contracts to be per chain......

export type ContractAddresses = {
  [key: number]: {
    launchpad: string;
  };
};

export const contractAddresses: ContractAddresses = {
  // bsc
  56: {
    launchpad: "",
  },
  // base chain
  8453: {
    launchpad: "",
  },
  // cro chain
  25: {
    launchpad: "",
  },
  // ethmainnet
  1: {
    launchpad: "",
  },
  // arbi
  42161: {
    launchpad: "",
  },
  // pulsechain
  369: {
    launchpad: "",
  },
  // bsctestnet
  97: {
    launchpad: "0x41f61dE90f53A50556D070B96920BE020510bFB8",
  },
  // maxxchain
  10201: {
    launchpad: "0x0b8f852C1Fa31B40C3a777F06CACdCc88fA6Bdb8",
  },
  // seppolia
  11155111: {
    launchpad: "0xD75D719ed6FD7722a6113aC2Fede3158eb72e794",
  },



};
