// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract StatesOfMind is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct FeelingAttribute {
        uint256 happy;
        uint256 excited;
        uint256 surprised;
        uint256 silly;
    }

    FeelingAttribute feeling;
    mapping(uint256 => FeelingAttribute) public statesOfMind;

    constructor() ERC721("Feeling Status", "FST") {}

    /**
     * @dev returns Feeling states of mind for a given token ID
     * @param tokenId: the token ID of the character
     */
    function getStateOfMind(uint256 tokenId) public view returns (FeelingAttribute memory) {
        FeelingAttribute memory stats = statesOfMind[tokenId];
        return stats;
    }

    function generateCharacter(uint256 tokenId) public view returns (string memory) {

        FeelingAttribute memory stats = getStateOfMind(tokenId);

        bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"States of Mind",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Happy: ",stats.happy.toString(),'</text>',
        '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "excited: ",stats.excited.toString(),'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "surprised: ",stats.surprised.toString(),'</text>',
        '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "silly: ",stats.silly.toString(),'</text>',
        '</svg>'
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "States Of Mind',
            tokenId.toString(),
            '",',
            '"description": "Feeling",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        uint256 randNum = newItemId;
        FeelingAttribute memory stats;
        stats.happy = randomNumGenerator(randNum++);
        stats.excited = randomNumGenerator(randNum++);
        stats.surprised = randomNumGenerator(randNum++);
        stats.silly = randomNumGenerator(randNum++);

        statesOfMind[newItemId] = stats;

         // Generate NFT
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function randomNumGenerator(uint256 randNum) public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNum)
                )
            ) % 100;
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");
        uint256 randNum = tokenId;
        feeling.happy = randomNumGenerator( randNum++ );
        feeling.excited = randomNumGenerator(randNum++);
        feeling.surprised = randomNumGenerator(randNum++);
        feeling.silly = randomNumGenerator(randNum++);
        statesOfMind[tokenId] = feeling;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
