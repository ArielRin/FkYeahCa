// @CMH. added chainlist for launchpad contracts to be per chain......
// export type ContractAddresses = {
//   [key: number]: {
//     launchpad: string;
//   };
// };
//
// export const contractAddresses: ContractAddresses = {
//
//   // binace
//   56: {
//     launchpad: "0xd625b812E7799E330292C324F5f478F3122f0728",
//   },
//   // base
//   8453: {
//     launchpad: "0xd625b812E7799E330292C324F5f478F3122f0728",
//   },
//
//
//     // cro
//   25: {
//     launchpad: "0xd625b812E7799E330292C324F5f478F3122f0728",
//   },
//
//   // main net ethereum
//   1: {
//     launchpad: "0xd625b812E7799E330292C324F5f478F3122f0728",
//   },
//
// };


//
// src/Pages/Launch/contractAddresses.ts
export type ContractAddresses = {
  [key: number]: {
    launchpad: string;
  };
};

export const contractAddresses: ContractAddresses = {
  56: {
    launchpad: "0xd625b812E7799E330292C324F5f478F3122f0728",
  },
  8453: {
    launchpad: "0xYourBaseLaunchpadAddress",
  },
  25: {
    launchpad: "0xYourCronosLaunchpadAddress",
  },
  1: {
    launchpad: "0xYourEthereumLaunchpadAddress",
  },

};
