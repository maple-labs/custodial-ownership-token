// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.6.11;

import { IERC2258 } from "../../interfaces/IERC2258.sol";

contract Custodian {

    function erc2258_transferByCustodian(address token, address from, address to, uint256 amount) external {
        IERC2258(token).transferByCustodian(from, to, amount);
    }

    function try_erc2258_transferByCustodian(address token, address from, address to, uint256 amt) external returns (bool ok) {
        (ok,) = token.call(abi.encodeWithSignature("transferByCustodian(address,address,uint256)", from, to, amt));
    }

}
