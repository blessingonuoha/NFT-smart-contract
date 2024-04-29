// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RadioNovas is ERC721, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;

    uint256 maxSupply = 10101;

    mapping(address => bool) private _isWaitListed;

    bool isPublicMintOpen;
    bool isWaitListMintOpen;

    // ipfs link for nfts
    string baseURI = "";
    // link to the prereveal URI 
    string preRevealURI = "";

    bool public isRevealed;

    string mintingIsClosedMsg = "Minting of Radionovas is closed.";
    string notEnoughFundsMsg =
        "Not enough funds in wallet for minting Radionova.";

    constructor(
        address initialOwner
    ) ERC721("Radionova", "RDN") Ownable(initialOwner) {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function addToWaitList(address _address) public {
        // checks if address is already on wait list
        require(!_isWaitListed[_address], "Already on waitlist!");

        // Add the address to the waitlist
        _isWaitListed[_address] = true;
    }

    // sets public minting to true or false
    // if true, sets wait list minting to false so only one minting btn is available
    function setIsPublicMintOpen(bool _isPublicMintOpen) public onlyOwner {
        isPublicMintOpen = _isPublicMintOpen;

        if (isPublicMintOpen) {
            setIsWaitListMintOpen(false);
        }
    }

    // sets waitlist minting to true or false
    // if true, sets public minting to false so only one minting btn is available
    function setIsWaitListMintOpen(bool _isWaitListMintOpen) public onlyOwner {
        isWaitListMintOpen = _isWaitListMintOpen;
        if (isWaitListMintOpen) {
            setIsPublicMintOpen(false);
        }
    }

    // handler for checking if address is waitlisted
    function isOnWaitList(address _address) public view returns (bool) {
        // returns true or false
        return _isWaitListed[_address];
    }

    // returns total number of minted nfts
    function totalMintedNFT() public view returns (uint256) {
        return _nextTokenId;
    }

    // minting handler
    function _proceedToMint(address _address) internal {
        uint256 _totalMintedNFT = totalMintedNFT();

        require(_totalMintedNFT < maxSupply, mintingIsClosedMsg);
        uint256 tokenId = _nextTokenId++;
        _safeMint(_address, tokenId);
    }

    // allows only address in the waitList to mint NFT
    function waitListMint(address _address) public payable {
        require(isWaitListMintOpen, mintingIsClosedMsg);

        require(_isWaitListed[_address], "Sorry you are not on waitlist!");
        // waitlisted addresses pay less
        require(msg.value == 0.001 ether, notEnoughFundsMsg);
        _proceedToMint(_address);
    }

    // allows any address to mint the NFT
    function publicMint() public payable {
        require(isPublicMintOpen, mintingIsClosedMsg);
        // value per NFT
        require(msg.value == 0.01 ether, notEnoughFundsMsg);

        _proceedToMint(msg.sender);
    }

    // handler for setting reveal and baseURI
    function setIsRevealAndBaseURI (bool _isReveal, string memory baseURI_) public onlyOwner {
        isRevealed = _isReveal;
        baseURI = baseURI_;
    }

    // handler that returns the baseURI + tokenId of the minted nft if isRevealed is set to true
    // else it returns the generic preReveal URI
    function tokenURI(uint256 _tokenId) public view override virtual  returns (string memory) {
        _requireOwned(_tokenId);

        if(isRevealed){
            return bytes(baseURI).length >  0 ? string.concat(baseURI, Strings.toString(_tokenId)) : "";
        }else{
            return preRevealURI;
        }
    }

    // transfers wallet bal into specified address
    function withdrawEth(address _to) external onlyOwner {
        uint256 walletBal = uint256(address(this).balance);
        payable(_to).transfer(walletBal);
    }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721, ERC721Pausable) returns (address) {
        return super._update(to, tokenId, auth);
    }
}