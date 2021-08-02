// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.6.11;

import { IERC20 } from "../../modules/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { DSTest } from "../../modules/ds-test/src/test.sol";

import { ERC2258 } from "../ERC2258.sol";

import { Custodian }      from "./accounts/Custodian.sol";
import { ERC2258Account } from "./accounts/ERC2258Account.sol";

contract MintableERC2258 is ERC2258 {

    constructor(string memory name, string memory symbol) ERC2258(name, symbol) public { }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

}


contract ERC2258Test is DSTest {

    MintableERC2258 token;
    ERC2258Account  account;
    Custodian       custodian1;
    Custodian       custodian2;

    function setUp() public {
        token      = new MintableERC2258("Token", "TKN");
        account    = new ERC2258Account();
        custodian1 = new Custodian();
        custodian2 = new Custodian();
    }

    function test_increaseCustodyAllowance() public {
        assertTrue(!account.try_erc2258_increaseCustodyAllowance(address(token), address(custodian1), 1));  // Account doesn't have any balance

        token.mint(address(account), 500);

        assertEq(token.custodyAllowance(address(account), address(custodian1)), 0);
        assertEq(token.totalCustodyAllowance(address(account)),                 0);
        assertEq(token.balanceOf(address(account)),                             500);

        assertTrue(account.try_erc2258_increaseCustodyAllowance(address(token), address(custodian1), 100));

        assertEq(token.custodyAllowance(address(account), address(custodian1)), 100);
        assertEq(token.custodyAllowance(address(account), address(custodian2)), 0);
        assertEq(token.totalCustodyAllowance(address(account)),                 100);
        assertEq(token.balanceOf(address(account)),                             500);

        assertTrue(!account.try_erc2258_increaseCustodyAllowance(address(token), address(custodian2), 401));  // Account doesn't have enough balance
        assertTrue( account.try_erc2258_increaseCustodyAllowance(address(token), address(custodian2), 400));  // Increase the custody allowance to another custodian

        assertEq(token.custodyAllowance(address(account), address(custodian1)), 100);
        assertEq(token.custodyAllowance(address(account), address(custodian2)), 400);
        assertEq(token.totalCustodyAllowance(address(account)),                 500);
        assertEq(token.balanceOf(address(account)),                             500);
    }

    function test_transferByCustodian() public {
        token.mint(address(account), 500);

        account.erc2258_increaseCustodyAllowance(address(token), address(custodian1), 100);

        assertEq(token.custodyAllowance(address(account), address(custodian1)), 100);
        assertEq(token.custodyAllowance(address(account), address(custodian2)), 0);
        assertEq(token.totalCustodyAllowance(address(account)),                 100);
        assertEq(token.balanceOf(address(account)),                             500);

        assertTrue(!custodian1.try_erc2258_transferByCustodian(address(token), address(account), address(custodian2), 101));
        assertTrue( custodian1.try_erc2258_transferByCustodian(address(token), address(account), address(custodian2), 100));  // Transfer to custodian2

        assertEq(token.custodyAllowance(address(account), address(custodian1)), 0);
        assertEq(token.custodyAllowance(address(account), address(custodian2)), 100);
        assertEq(token.totalCustodyAllowance(address(account)),                 100);
        assertEq(token.balanceOf(address(account)),                             500);

        custodian2.erc2258_transferByCustodian(address(token), address(account), address(account), 100);  // Transfer back to account

        assertEq(token.custodyAllowance(address(account), address(custodian1)), 0);
        assertEq(token.custodyAllowance(address(account), address(custodian2)), 0);
        assertEq(token.totalCustodyAllowance(address(account)),                 0);
        assertEq(token.balanceOf(address(account)),                             500);
    }

}
