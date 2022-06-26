// SPDX-License-Identifier:MIT

// Within each liquidity pools value of tokens added is equal. The count of tokens might not be equal but the total value is same.

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Multiswap {
    mapping(string => mapping(string => uint256[])) public liquidityPools;
    mapping(string => address) public tokens;
    uint256 private symbol_to_return;
    uint256 private symbol2_to_return;
    uint256 private symbol3_to_return;
    string eth = "ETH";

    struct LocalVariables {
        uint256 eth1_supply;
        uint256 eth2_supply;
        uint256 eth3_supply;
        uint256 symbol1_supply;
        uint256 symbol2_supply;
        uint256 symbol3_supply;
    }

    function getSymbolValue() public view returns (uint256) {
        return symbol_to_return;
    }

    function getSymbolsValue() public view returns (uint256[2] memory) {
        uint256[2] memory l1;
        l1[0] = symbol2_to_return;
        l1[1] = symbol3_to_return;
        return l1;
    }

    function addEthereumLiquidity() public payable {}

    function addLiquidity(
        address token2,
        uint256 amount1,
        uint256 amount2,
        string memory symbol2
    ) external {
        require(amount1 > 0, "Cannot create a pool with 0 tokens");

        IERC20 _token2 = IERC20(token2);

        _token2.transferFrom(msg.sender, address(this), amount2);

        liquidityPools[eth][symbol2].push(amount1);
        liquidityPools[eth][symbol2].push(amount2);

        liquidityPools[symbol2][eth].push(amount2);
        liquidityPools[symbol2][eth].push(amount1);

        tokens[symbol2] = token2;
    }

    // trying to swap symbol1 with symbol2 :

    function checkTokensYouGetForSingleSwap(
        string memory symbol1,
        string memory symbol2,
        uint256 amount1
    ) external {
        if (
            keccak256(abi.encodePacked(symbol1)) !=
            keccak256(abi.encodePacked(eth))
        ) {
            require(
                liquidityPools[symbol1][eth].length > 0,
                "Liquidity for this token not present"
            );
            IERC20 _token = IERC20(tokens[symbol1]);
            _token.transferFrom(msg.sender, address(this), amount1);

            if (
                keccak256(abi.encodePacked(symbol2)) !=
                keccak256(abi.encodePacked(eth))
            ) {
                require(
                    liquidityPools[symbol2][eth].length > 0,
                    "Liquidity for this token not present"
                );

                // Let's route :
                uint256 symbol1_supply = liquidityPools[symbol1][eth][0];
                uint256 eth1_supply = liquidityPools[symbol1][eth][1];

                uint256 symbol2_supply = liquidityPools[symbol2][eth][0];
                uint256 eth2_supply = liquidityPools[symbol2][eth][1];

                uint256 symbol2_to_be_given = (eth1_supply *
                    amount1 *
                    symbol2_supply) / (symbol1_supply * eth2_supply);

                liquidityPools[symbol1][eth][0] += (amount1);
                liquidityPools[symbol2][eth][0] -= (symbol2_to_be_given);

                liquidityPools[eth][symbol1][1] += (amount1);
                liquidityPools[eth][symbol2][1] -= (symbol2_to_be_given);

                symbol_to_return = symbol2_to_be_given;
            } else {
                // Getting ETH in return for some ERC20 Token :
                uint256 symbol1_supply = liquidityPools[symbol1][eth][0];
                uint256 symbol2_supply = liquidityPools[symbol1][eth][1];

                uint256 eth_to_be_given = (symbol2_supply * amount1) /
                    (symbol1_supply);

                liquidityPools[symbol1][eth][0] += (amount1);
                liquidityPools[symbol1][eth][1] -= eth_to_be_given;

                liquidityPools[eth][symbol1][0] -= eth_to_be_given;
                liquidityPools[eth][symbol1][1] += (amount1);

                symbol_to_return = eth_to_be_given;
            }
        } else {
            require(
                liquidityPools[symbol2][eth].length > 0,
                "Liquidity for this token is not present"
            );

            uint256 symbol1_supply = liquidityPools[symbol1][symbol2][0];
            uint256 symbol2_supply = liquidityPools[symbol1][symbol2][1];

            uint256 symbol2_to_be_given = (symbol2_supply * amount1) /
                (symbol1_supply);

            liquidityPools[eth][symbol2][0] += (amount1);
            liquidityPools[eth][symbol2][1] -= symbol2_to_be_given;

            liquidityPools[symbol2][eth][0] -= symbol2_to_be_given;
            liquidityPools[symbol2][eth][1] += (amount1);

            symbol_to_return = symbol2_to_be_given;
        }
    }

    function update(
        string memory s1,
        string memory s2,
        uint256 amount,
        uint256 ind,
        string memory operation
    ) internal {
        if (
            keccak256(abi.encodePacked(operation)) ==
            keccak256(abi.encodePacked("add"))
        ) {
            liquidityPools[s1][s2][ind] += amount;
        } else {
            liquidityPools[s1][s2][ind] -= amount;
        }
    }

    function checkTokensYouGetForMultipleSwap(
        string memory symbol1,
        string memory symbol2,
        string memory symbol3,
        uint256 amount1,
        uint256 per1,
        uint256 per2
    ) external {
        LocalVariables memory local;
        // we need percentage 1 amount of total cost of symbol1 to be covered by symbol2 and remaining by symbol3

        if (
            keccak256(abi.encodePacked(symbol1)) ==
            keccak256(abi.encodePacked(eth))
        ) {
            local.eth1_supply = liquidityPools[eth][symbol2][0];
            local.symbol2_supply = liquidityPools[eth][symbol2][1];

            local.eth2_supply = liquidityPools[eth][symbol3][0];
            local.symbol3_supply = liquidityPools[eth][symbol3][1];

            uint256 symbol2_to_be_given = (local.symbol2_supply *
                amount1 *
                per1) / (local.eth1_supply * 100);
            uint256 symbol3_to_be_given = (local.symbol3_supply *
                amount1 *
                per2) / (local.eth2_supply * 100);

            liquidityPools[eth][symbol2][0] += ((amount1 * per1) / 100);
            liquidityPools[eth][symbol2][1] -= symbol2_to_be_given;

            liquidityPools[symbol2][eth][0] -= symbol2_to_be_given;
            liquidityPools[symbol2][eth][1] += ((amount1 * per1) / 100);

            liquidityPools[eth][symbol3][0] += ((amount1 * per2) / 100);
            liquidityPools[eth][symbol3][1] -= symbol3_to_be_given;

            liquidityPools[symbol3][eth][0] -= symbol3_to_be_given;
            liquidityPools[symbol3][eth][1] += ((amount1 * per2) / 100);

            symbol2_to_return = symbol2_to_be_given;
            symbol3_to_return = symbol3_to_be_given;
        } else {
            IERC20 __token = IERC20(tokens[symbol1]);
            __token.transferFrom(msg.sender, address(this), amount1);

            if (
                keccak256(abi.encodePacked(symbol2)) ==
                keccak256(abi.encodePacked(eth))
            ) {
                local.eth1_supply = liquidityPools[eth][symbol1][0];
                local.symbol1_supply = liquidityPools[eth][symbol1][1];

                local.eth2_supply = liquidityPools[eth][symbol3][0];
                local.symbol3_supply = liquidityPools[eth][symbol3][1];

                uint256 eth_to_be_given = (local.eth1_supply * per1 * amount1) /
                    (100 * local.symbol1_supply);
                uint256 symbol3_to_be_given = (local.eth1_supply *
                    local.symbol3_supply *
                    per2 *
                    amount1) / (100 * local.symbol1_supply * local.eth2_supply);

                liquidityPools[eth][symbol1][0] -= eth_to_be_given;
                liquidityPools[eth][symbol1][1] += (amount1);

                liquidityPools[symbol1][eth][0] += (amount1);
                liquidityPools[symbol1][eth][1] -= eth_to_be_given;

                liquidityPools[eth][symbol3][1] -= symbol3_to_be_given;

                liquidityPools[symbol3][eth][0] -= symbol3_to_be_given;

                symbol2_to_return = eth_to_be_given;
                symbol3_to_return = symbol3_to_be_given;
            } else if (
                keccak256(abi.encodePacked(symbol3)) ==
                keccak256(abi.encodePacked(eth))
            ) {
                local.eth1_supply = liquidityPools[eth][symbol1][0];
                local.symbol1_supply = liquidityPools[eth][symbol1][1];

                uint256 eth2_supply = liquidityPools[eth][symbol2][0];
                uint256 symbol2_supply = liquidityPools[eth][symbol2][1];

                uint256 eth_to_be_given = (local.eth1_supply * per2 * amount1) /
                    (100 * local.symbol1_supply);
                uint256 symbol2_to_be_given = (local.eth1_supply *
                    symbol2_supply *
                    per1 *
                    amount1) / (100 * local.symbol1_supply * eth2_supply);

                liquidityPools[eth][symbol1][0] -= eth_to_be_given;
                liquidityPools[eth][symbol1][1] += (amount1);

                liquidityPools[symbol1][eth][0] += (amount1);
                liquidityPools[symbol1][eth][1] -= eth_to_be_given;

                liquidityPools[eth][symbol2][1] -= symbol2_to_be_given;

                liquidityPools[symbol2][eth][0] -= symbol2_to_be_given;

                symbol2_to_return = symbol2_to_be_given;
                symbol3_to_return = eth_to_be_given;
            } else {
                local.eth1_supply = liquidityPools[eth][symbol1][0];
                local.symbol1_supply = liquidityPools[eth][symbol1][1];

                local.eth2_supply = liquidityPools[eth][symbol2][0];
                local.symbol2_supply = liquidityPools[eth][symbol2][1];

                local.eth3_supply = liquidityPools[eth][symbol3][0];
                local.symbol3_supply = liquidityPools[eth][symbol3][1];

                uint256 symbol2_to_be_given = (amount1 *
                    per1 *
                    local.eth1_supply);
                symbol2_to_be_given =
                    (symbol2_to_be_given * local.symbol2_supply) /
                    (100 * local.symbol1_supply * local.eth2_supply);
                uint256 symbol3_to_be_given = (amount1 *
                    per2 *
                    local.eth1_supply);
                symbol3_to_be_given =
                    (symbol3_to_be_given * local.symbol3_supply) /
                    (100 * local.symbol1_supply * local.eth3_supply);

                uint256 val = (amount1);
                update(eth, symbol1, val, 1, "add");
                update(symbol1, eth, val, 0, "add");

                update(eth, symbol2, symbol2_to_be_given, 1, "sub");
                update(symbol2, eth, symbol2_to_be_given, 0, "sub");

                update(eth, symbol3, symbol3_to_be_given, 1, "sub");
                update(symbol3, eth, symbol3_to_be_given, 0, "sub");

                symbol2_to_return = symbol2_to_be_given;
                symbol3_to_return = symbol3_to_be_given;
            }
        }
    }

    function payEther(uint256 amount) public {
        (bool succ, ) = payable(msg.sender).call{value: amount}("");
    }

    function payToken(string memory symbol, uint256 amount) public {
        IERC20(tokens[symbol]).transferFrom(address(this), msg.sender, amount);
    }

    function getAddress(string memory token) public view returns (address) {
        return tokens[token];
    }
}
