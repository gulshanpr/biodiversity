// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBioDivAndHer {
    function isVolenteerParticipated(uint _projectID, address _participant) external view returns (bool);
}

contract nftContract is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    IBioDivAndHer public bioDivAndHerContract;
    mapping(address => uint[]) public ownedNFTs;
    uint public totalTokenissue = 0; 
   

       constructor(address _bioDivAndHerAddress)
        ERC721("biodiversity and Heritage", "ECO")
        Ownable(msg.sender)
    {
        bioDivAndHerContract = IBioDivAndHer(_bioDivAndHerAddress);
    }
    
    function safeMint(address to, string memory uri, uint _projectID)
        public
        onlyOwner
    {
        require(bioDivAndHerContract.isVolenteerParticipated(_projectID, to), "User is not a participant of the project");

        totalTokenissue++;
        _safeMint(to, totalTokenissue);
        _setTokenURI(totalTokenissue, uri);
    }

    function getOwnedNFTs(address user) public view returns (uint[] memory) {
        return ownedNFTs[user];
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}