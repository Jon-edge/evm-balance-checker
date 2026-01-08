// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC20 contract interface
interface IERC20 {
    function balanceOf(address) external view returns (uint256);
}

contract BalanceChecker {
    /* Fallback function, don't accept any ETH */
    receive() external payable {
        revert("BalanceChecker does not accept payments");
    }

    fallback() external payable {
        revert("BalanceChecker does not accept payments");
    }

    /*
      Check the token balance of a wallet in a token contract
      Returns 0 on non-contract address or if balanceOf fails
    */
    function tokenBalance(address user, address token) public view returns (uint256) {
        uint256 tokenCode;
        assembly { tokenCode := extcodesize(token) }
      
        if (tokenCode > 0) {
            try IERC20(token).balanceOf(user) returns (uint256 balance) {
                return balance;
            } catch {
                return 0;
            }
        } else {
            return 0;
        }
    }

    /*
      Check the token balances of a wallet for multiple tokens.
      Pass 0x0 as a "token" address to get ETH balance.
    */
    function balances(address[] calldata users, address[] calldata tokens) external view returns (uint256[] memory) {
        uint256[] memory addrBalances = new uint256[](tokens.length * users.length);
        
        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 addrIdx = j + tokens.length * i;
                if (tokens[j] != address(0x0)) { 
                    addrBalances[addrIdx] = tokenBalance(users[i], tokens[j]);
                } else {
                    addrBalances[addrIdx] = users[i].balance;
                }
            }  
        }
      
        return addrBalances;
    }
}