// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';

contract WBANToken is ERC20PausableUpgradeable, AccessControlUpgradeable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    mapping(bytes32 => bool) private _receipts;

    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');
    bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');

    function initialize() public initializer {
        __Ownable_init();
        __ERC20_init('Wrapped Banano', 'wBAN');
        __AccessControl_init();
        // setup roles
        _setupRole(MINTER_ROLE, owner());
        _setupRole(PAUSER_ROLE, owner());
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
    }

    function mintWithReceipt(
        address recipient,
        uint256 amount,
        uint256 uuid,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(!paused(), 'BEP20Pausable: transfer paused');

        bytes32 payloadHash = keccak256(abi.encode(recipient, amount, uuid));
        bytes32 hash = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', payloadHash));

        require(!_receipts[hash], 'Receipt already used');

        _checkSignature(hash, v, r, s);

        _mint(recipient, amount);
        _receipts[hash] = true;
    }

    function swapToBan(string memory bananoAddress, uint256 amount) external {
        require(!paused(), 'BEP20Pausable: transfer paused');
        require(balanceOf(_msgSender()) >= amount, 'Insufficient wBAN');
        require(bytes(bananoAddress).length == 64, 'Not a Banano address');
        _burn(_msgSender(), amount);
        emit SwapToBan(_msgSender(), bananoAddress, amount);
    }

    function pause() external whenNotPaused onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external whenPaused onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Returns the bep token owner.
     * Extra method added in IBEP20 that is not present in IERC20!
     * Better be safe than sorry.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    function _checkSignature(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        address signer = ecrecover(hash, v, r, s);
        require(hasRole(MINTER_ROLE, signer), 'Signature invalid');
    }

    /**
     * @dev Emitted when a swap is done for `amount` wBAN from `from` to Banano address `ban_address`
     */
    event SwapToBan(address indexed from, string banAddress, uint256 amount);
}
