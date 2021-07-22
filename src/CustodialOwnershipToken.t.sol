pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./CustodialOwnershipToken.sol";

contract CustodialOwnershipTokenTest is DSTest {
    CustodialOwnershipToken token;

    function setUp() public {
        token = new CustodialOwnershipToken();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
