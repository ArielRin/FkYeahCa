// @CMH. added chainlist for launchpad contracts to be per chain......

export type ContractAddresses = {
  [key: number]: {
    launchpad: string;
  };
};

export const contractAddresses: ContractAddresses = {
  // bsc
  56: {
    launchpad: "0xd625b812E7799E330292C324F5f478F3122f0728",
  },
  // base chain
  8453: {
    launchpad: "0xd625b812E7799E330292C324F5f478F3122f0728",
  },
  // cro chain
  25: {
    launchpad: "0xd625b812E7799E330292C324F5f478F3122f0728",
  },
  // ethmainnet
  1: {
    launchpad: "0xd625b812E7799E330292C324F5f478F3122f0728",
  },

};
