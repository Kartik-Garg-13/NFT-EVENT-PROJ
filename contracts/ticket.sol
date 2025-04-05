// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "base64-sol/base64.sol";

contract TicketNFT is ERC721Enumerable, Ownable {
    uint256 private _tokenIds;
    uint256 public constant TICKET_PRICE = 0.01 ether;
    uint256 public constant MAX_SUPPLY = 1000;

    constructor() ERC721("EventTicket", "ETKT") Ownable(msg.sender) {}

    modifier canMint() {
        require(totalSupply() < MAX_SUPPLY, "All tickets minted");
        require(msg.value == TICKET_PRICE, "Incorrect ETH amount");
        _;
    }

    function mintTicket() public payable canMint returns (uint256) {
        _tokenIds++;
        uint256 newItemId = _tokenIds;
        _safeMint(msg.sender, newItemId);
        return newItemId;
    }

    // Generates on-chain metadata with a simple SVG image
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // Instead of _exists(tokenId), we check that tokenId is within minted range
        require(tokenId > 0 && tokenId <= _tokenIds, "Nonexistent token");

        string memory svg = "<svg xmlns='http://www.w3.org/2000/svg' width='300' height='300'><rect width='300' height='300' fill='black'/><text x='50%' y='50%' fill='white' font-size='24' text-anchor='middle'>Ticket #";
        svg = string(abi.encodePacked(svg, toString(tokenId), "</text></svg>"));
        string memory image = Base64.encode(bytes(svg));
        string memory json = Base64.encode(bytes(abi.encodePacked(
            '{"name": "Ticket #', toString(tokenId),
            '", "description": "An NFT Ticket for the Event", "image": "data:image/svg+xml;base64,', image, '"}'
        )));
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    // Helper function to convert uint to string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
