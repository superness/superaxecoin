// Copyright (c) 2009-2010 Axoshi Nakamoto
// Copyright (c) 2009-2021 The SuperAxeCoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef SUPERAXECOIN_CONSENSUS_AMOUNT_H
#define SUPERAXECOIN_CONSENSUS_AMOUNT_H

#include <cstdint>

/** Amount in axoshis (Can be negative) */
typedef int64_t CAmount;

/** The amount of axoshis in one AXE. */
static constexpr CAmount COIN = 100000000;

/** Maximum supply: 210 million AXE
 *
 * Note that this constant is *not* the total money supply, which in SuperAxeCoin
 * currently happens to be less than 210,000,000 AXE for various reasons, but
 * rather a sanity check. As this sanity check is used by consensus-critical
 * validation code, the exact value of the MAX_MONEY constant is consensus
 * critical; in unusual circumstances like a(nother) overflow bug that allowed
 * for the creation of coins out of thin air modification could lead to a fork.
 * */
static constexpr CAmount MAX_MONEY = 210000000 * COIN;
inline bool MoneyRange(const CAmount& nValue) { return (nValue >= 0 && nValue <= MAX_MONEY); }

#endif // SUPERAXECOIN_CONSENSUS_AMOUNT_H
