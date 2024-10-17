// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Zorb is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 maxSupply = 2000;

    bool publicMintOpen = false;
    bool allowListMintOpen = false;

    //creating the allowlist mapping
    mapping (address => bool) public allowList;


    constructor(address initialOwner)
        ERC721("Zorb", "ZORB")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    // modity the mint windows
    function editMintWindows(
        bool _publicMintOpen, bool _allowListMintOpen
    ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    //Add publicMint and allowListMintOpen variables
    //Require only the allowlist people to mint
    function allowListMint() public payable {
        require(allowListMintOpen, "allowList closed");
        require(allowList[msg.sender], "you are not on the allow list");
        require(msg.value == 0.001 ether, "Not enough funds");
        internalMint();
    }

    //Add paynment
    function publicMint () public payable {
        require(publicMintOpen, "publicMint closed");
        require(msg.value == 0.01 ether, "Not enough funds");
        internalMint();
        
    }

    function internalMint() internal {
      require(totalSupply() < maxSupply, "we sold out");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    //populate the Allow List
    function setAllowList (address[] calldata addresses) external onlyOwner{
        //create a for loop that will go through the array and populate the mapping
        for (uint256 i = 0; i < addresses.length; i++) 
        {
          allowList[addresses[i]] = true;
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}