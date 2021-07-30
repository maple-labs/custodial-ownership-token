// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.6.11;

import { ERC2258 } from "../ERC2258.sol";
import { DSTest } from "../../modules/ds-test/src/test.sol";
import { Custodian } from "./accounts/Custodian.sol";
import { ERC2258Account } from "./accounts/ERC2258Account.sol";

import { IERC20 } from "../../modules/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface Hevm {

    function warp(uint256) external;
    function store(address,bytes32,bytes32) external;

}

contract ERC2258Test is DSTest {

    ERC2258     erc2258;
    Custodian       cus;
    Custodian      cus2;
    ERC2258Account  act;
    ERC2258Account act2;
    Hevm           hevm;
    

     uint256 constant WAD = 10 ** 18;

    function setUp() public {
        erc2258 = new ERC2258("Token", "TKN");
        cus     = new Custodian();
        cus2    = new Custodian();
        act     = new ERC2258Account();
        act2    = new ERC2258Account();
    }

    function test_increaseCustodyAllowance() public {
        assertTrue(!act.try_erc2258_increaseCustodyAllowance(address(erc2258), address(cus), 1000 * WAD)); // act doesn't has the balance.

        mint(address(erc2258), address(act), 5000 * WAD);
        assertTrue(act.try_erc2258_increaseCustodyAllowance(address(erc2258), address(cus), 1000 * WAD));
        assertEq(erc2258.custodyAllowance(address(act), address(cus)), 1000 * WAD);
        assertEq(erc2258.totalCustodyAllowance(address(act)), 1000 * WAD);
        assertEq(erc2258.balanceOf(address(act)), 5000 * WAD);

        // Increase the custody allowance again.
        assertTrue(act.try_erc2258_increaseCustodyAllowance(address(erc2258), address(cus2), 2000 * WAD));
        assertEq(erc2258.custodyAllowance(address(act), address(cus2)), 2000 * WAD);
        assertEq(erc2258.totalCustodyAllowance(address(act)), 3000 * WAD);
        assertEq(erc2258.balanceOf(address(act)), 5000 * WAD);
    }

    function test_transferByCustodian() public {
        mint(address(erc2258), address(act), 5000 * WAD);
        assertTrue(act.try_erc2258_increaseCustodyAllowance(address(erc2258), address(cus), 1000 * WAD));
        assertTrue(cus.try_erc2258_transferByCustodian(address(erc2258), address(act), address(act2), amt));

        assertEq(erc2258.balanceOf(address(act)),  4000 * WAD);
        assertEq(erc2258.balanceOf(address(act2)), 1000 * WAD);

        assertEq(erc2258.custodyAllowance(address(act), address(cus2)), 0);
        assertEq(erc2258.totalCustodyAllowance(address(act)), 0);
    }


    // Manipulate mainnet ERC20 balance
    function mint(address addr, address account, uint256 amt) public {
        uint256 slot  = 0;
        uint256 bal = IERC20(addr).balanceOf(account);

        hevm.store(
            addr,
            keccak256(abi.encode(account, slot)), // Mint tokens
            bytes32(bal + amt)
        );

        assertEq(IERC20(addr).balanceOf(account), bal + amt);  // Assert new balance
    }
}