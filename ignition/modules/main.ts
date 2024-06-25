import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("DeployGeneric", (m) => {
  // Define the constructor parameters for the Generic contract.
  const entityId = 1;  // example ID, adjust as necessary
  const ipfsHash = "your_ipfs_hash_here";  // replace with actual IPFS hash
  const baseURI = "https://yourapi.com/baseuri";  // replace with your base URI

  // Deploy the Generic contract
  const generic = m.contract("Generic", [entityId, ipfsHash, baseURI]);

  return { generic };
});
