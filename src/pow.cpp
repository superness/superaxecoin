// Copyright (c) 2009-2010 Axoshi Nakamoto
// Copyright (c) 2009-2022 The SuperAxeCoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <pow.h>

#include <arith_uint256.h>
#include <chain.h>
#include <primitives/block.h>
#include <uint256.h>
#include <consensus/params.h>

#include <algorithm>
#include <cmath>
#include <vector>

// LWMA (Linearly Weighted Moving Average) difficulty algorithm constants
static const int64_t LWMA_WINDOW = 60;           // 60 block window
static const int64_t TARGET_SPACING = 120;       // 2 minutes (120 seconds)
static const int64_t MAX_SOLVETIME = TARGET_SPACING * 6;  // 720 seconds
static const int64_t MIN_SOLVETIME = -TARGET_SPACING * 6;
static const double MAX_ADJUSTMENT = 1.25;       // +25% max
static const double MIN_ADJUSTMENT = 0.75;       // -25% max

/**
 * LWMA Difficulty Adjustment Algorithm for SuperAxeCoin
 *
 * This algorithm provides smooth difficulty adjustments by using a
 * linearly weighted moving average of solve times. Recent blocks
 * are weighted more heavily than older blocks.
 *
 * Key features:
 * - 60 block averaging window
 * - ±25% maximum adjustment per block
 * - 2 minute target block time
 * - Clamps outlier solve times to prevent gaming
 */
unsigned int GetNextWorkRequired(const CBlockIndex* pindexLast,
                                  const CBlockHeader *pblock,
                                  const Consensus::Params& params)
{
    assert(pindexLast != nullptr);

    const arith_uint256 powLimit = UintToArith256(params.powLimit);

    // First LWMA_WINDOW blocks: use minimum difficulty
    if (pindexLast->nHeight < LWMA_WINDOW) {
        return powLimit.GetCompact();
    }

    // Regtest: no retargeting
    if (params.fPowNoRetargeting) {
        return pindexLast->nBits;
    }

    // Testnet special rule: allow min difficulty if block time is > 2x target
    if (params.fPowAllowMinDifficultyBlocks) {
        if (pblock->GetBlockTime() > pindexLast->GetBlockTime() + params.nPowTargetSpacing * 2) {
            return powLimit.GetCompact();
        }
    }

    // Collect last LWMA_WINDOW + 1 blocks
    const CBlockIndex* pindex = pindexLast;
    std::vector<const CBlockIndex*> blocks;
    blocks.reserve(LWMA_WINDOW + 1);

    for (int i = 0; i <= LWMA_WINDOW && pindex != nullptr; i++) {
        blocks.push_back(pindex);
        pindex = pindex->pprev;
    }

    if (blocks.size() < static_cast<size_t>(LWMA_WINDOW + 1)) {
        return powLimit.GetCompact();
    }

    // Calculate weighted sum of solve times
    int64_t weighted_solvetimes = 0;
    int64_t weights_sum = 0;
    arith_uint256 sum_target = 0;

    for (int64_t i = 1; i <= LWMA_WINDOW; i++) {
        int64_t solvetime = blocks[i - 1]->GetBlockTime() - blocks[i]->GetBlockTime();

        // Clamp outliers to prevent gaming
        solvetime = std::max(solvetime, MIN_SOLVETIME);
        solvetime = std::min(solvetime, MAX_SOLVETIME);

        // Linear weighting: recent blocks weighted higher
        weighted_solvetimes += solvetime * i;
        weights_sum += i;

        arith_uint256 target;
        target.SetCompact(blocks[i - 1]->nBits);
        sum_target += target;
    }

    // Calculate weighted average solve time
    double avg_solvetime = static_cast<double>(weighted_solvetimes) /
                           static_cast<double>(weights_sum);

    if (avg_solvetime <= 0) {
        avg_solvetime = 1.0;
    }

    // Calculate adjustment factor
    double adjustment = static_cast<double>(TARGET_SPACING) / avg_solvetime;

    // Clamp to ±25%
    adjustment = std::max(adjustment, MIN_ADJUSTMENT);
    adjustment = std::min(adjustment, MAX_ADJUSTMENT);

    // Calculate average target and apply adjustment
    arith_uint256 avg_target = sum_target / LWMA_WINDOW;
    arith_uint256 next_target;

    if (adjustment != 1.0) {
        uint64_t adjustment_scaled = static_cast<uint64_t>(adjustment * 1000000.0);
        next_target = (avg_target * 1000000) / adjustment_scaled;
    } else {
        next_target = avg_target;
    }

    // Enforce limits
    if (next_target > powLimit) {
        next_target = powLimit;
    }
    if (next_target == 0) {
        next_target = 1;
    }

    return next_target.GetCompact();
}

unsigned int CalculateNextWorkRequired(const CBlockIndex* pindexLast, int64_t nFirstBlockTime, const Consensus::Params& params)
{
    // This function is kept for compatibility but LWMA handles everything in GetNextWorkRequired
    if (params.fPowNoRetargeting)
        return pindexLast->nBits;

    // For LWMA, we don't use the traditional two-week adjustment
    // This function is called by legacy code paths but GetNextWorkRequired handles LWMA
    const arith_uint256 bnPowLimit = UintToArith256(params.powLimit);
    arith_uint256 bnNew;
    bnNew.SetCompact(pindexLast->nBits);

    return bnNew.GetCompact();
}

// Check that on difficulty adjustments, the new difficulty does not increase
// or decrease beyond the permitted limits.
bool PermittedDifficultyTransition(const Consensus::Params& params, int64_t height, uint32_t old_nbits, uint32_t new_nbits)
{
    if (params.fPowAllowMinDifficultyBlocks) return true;

    // For LWMA, we allow ±25% adjustments per block
    const arith_uint256 pow_limit = UintToArith256(params.powLimit);

    arith_uint256 old_target;
    old_target.SetCompact(old_nbits);

    arith_uint256 new_target;
    new_target.SetCompact(new_nbits);

    // Don't allow going above pow limit
    if (new_target > pow_limit) return false;

    // Calculate max increase (target can increase by up to 33% which is 1/0.75)
    arith_uint256 max_target = old_target * 133 / 100;
    if (max_target > pow_limit) max_target = pow_limit;

    // Calculate min increase (target can decrease by up to 20% which is 1/1.25)
    arith_uint256 min_target = old_target * 80 / 100;

    // Check bounds
    if (new_target > max_target) return false;
    if (new_target < min_target) return false;

    return true;
}

bool CheckProofOfWork(uint256 hash, unsigned int nBits, const Consensus::Params& params)
{
    bool fNegative;
    bool fOverflow;
    arith_uint256 bnTarget;

    bnTarget.SetCompact(nBits, &fNegative, &fOverflow);

    // Check range
    if (fNegative || bnTarget == 0 || fOverflow || bnTarget > UintToArith256(params.powLimit))
        return false;

    // Check proof of work matches claimed amount
    if (UintToArith256(hash) > bnTarget)
        return false;

    return true;
}
