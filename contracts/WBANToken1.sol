// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

/**
 * Old wBAN smart-contract.
 */
contract WBANToken1 is ERC20PausableUpgradeable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) private _bnbBalances;

    function initialize() public initializer {
        __Ownable_init();
        __ERC20_init('Wrapped Banano', 'wBAN');
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `recipient`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `recipient` must have deposited enough BNB through `bnbDeposit`
     */
    function mintTo(
        address recipient,
        uint256 amount,
        uint256 gaslimit
    ) public onlyOwner {
        require(!paused(), 'BEP20Pausable: transfer paused');
        require(gaslimit > 0, "Gas limit can't be zero");
        // check if recipient has deposited enough BNB to cover for gas costs
        uint256 _gasCost = gaslimit * tx.gasprice;
        require(_bnbBalances[recipient] > _gasCost, 'Insufficient BNB deposited');
        // enough BNB were deposited, let's mint!
        _bnbBalances[recipient] = _bnbBalances[recipient].sub(_gasCost);
        _mint(recipient, amount);
        emit Fee(recipient, _gasCost);
    }

    function swapToBan(string memory bananoAddress, uint256 amount) external {
        require(!paused(), 'BEP20Pausable: transfer paused');
        require(balanceOf(_msgSender()) >= amount, 'Insufficient wBAN');
        require(bytes(bananoAddress).length == 64, 'Not a Banano address');
        _burn(_msgSender(), amount);
        emit SwapToBan(_msgSender(), bananoAddress, amount);
    }

    /**
     * @dev Keep track of users BNB deposits in order to pay for later owner initiated transactions.
     */
    function bnbDeposit() external payable {
        _bnbBalances[_msgSender()] = _bnbBalances[_msgSender()].add(msg.value);
        // solhint-disable-next-line indent
        payable(owner()).transfer(msg.value);
        emit BNBDeposit(_msgSender(), msg.value);
    }

    /**
     * @dev Returns the amount of BNB deposited in order to pay for owner initiated transactions.
     */
    function bnbBalanceOf(address account) external view returns (uint256) {
        return _bnbBalances[account];
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Emitted when `value` BNB are deposited.
     */
    event BNBDeposit(address indexed from, uint256 value);

    /**
     * @dev Emitted when a fee is needed from `bnbBalance` in order to compensate
     *      for owner transactions costs on behalf of the user
     */
    event Fee(address indexed from, uint256 value);

    /**
     * @dev Emitted when a swap is done for wBAN from `from` to Banano address
     *      `ban_address`
     */
    event SwapToBan(address indexed from, string banAddress, uint256 amount);
}
