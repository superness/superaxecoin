// Copyright (c) 2009-2010 Axoshi Nakamoto
// Copyright (c) 2009-2022 The SuperAxeCoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef SUPERAXECOIN_POLICY_FEERATE_H
#define SUPERAXECOIN_POLICY_FEERATE_H

#include <consensus/amount.h>
#include <serialize.h>


#include <cstdint>
#include <string>
#include <type_traits>

const std::string CURRENCY_UNIT = "AXE"; // One formatted unit
const std::string CURRENCY_ATOM = "sat"; // One indivisible minimum value unit

/* Used to determine type of fee estimation requested */
enum class FeeEstimateMode {
    UNSET,        //!< Use default settings based on other criteria
    ECONOMICAL,   //!< Force estimateSmartFee to use non-conservative estimates
    CONSERVATIVE, //!< Force estimateSmartFee to use conservative estimates
    AXE_KVB,      //!< Use AXE/kvB fee rate unit
    SAT_VB,       //!< Use sat/vB fee rate unit
};

/**
 * Fee rate in axoshis per kilovirtualbyte: CAmount / kvB
 */
class CFeeRate
{
private:
    /** Fee rate in sat/kvB (axoshis per 1000 virtualbytes) */
    CAmount nAxoshisPerK;

public:
    /** Fee rate of 0 axoshis per kvB */
    CFeeRate() : nAxoshisPerK(0) { }
    template<typename I>
    explicit CFeeRate(const I _nAxoshisPerK): nAxoshisPerK(_nAxoshisPerK) {
        // We've previously had bugs creep in from silent double->int conversion...
        static_assert(std::is_integral<I>::value, "CFeeRate should be used without floats");
    }

    /**
     * Construct a fee rate from a fee in axoshis and a vsize in vB.
     *
     * param@[in]   nFeePaid    The fee paid by a transaction, in axoshis
     * param@[in]   num_bytes   The vsize of a transaction, in vbytes
     */
    CFeeRate(const CAmount& nFeePaid, uint32_t num_bytes);

    /**
     * Return the fee in axoshis for the given vsize in vbytes.
     * If the calculated fee would have fractional axoshis, then the
     * returned fee will always be rounded up to the nearest axoshi.
     */
    CAmount GetFee(uint32_t num_bytes) const;

    /**
     * Return the fee in axoshis for a vsize of 1000 vbytes
     */
    CAmount GetFeePerK() const { return nAxoshisPerK; }
    friend bool operator<(const CFeeRate& a, const CFeeRate& b) { return a.nAxoshisPerK < b.nAxoshisPerK; }
    friend bool operator>(const CFeeRate& a, const CFeeRate& b) { return a.nAxoshisPerK > b.nAxoshisPerK; }
    friend bool operator==(const CFeeRate& a, const CFeeRate& b) { return a.nAxoshisPerK == b.nAxoshisPerK; }
    friend bool operator<=(const CFeeRate& a, const CFeeRate& b) { return a.nAxoshisPerK <= b.nAxoshisPerK; }
    friend bool operator>=(const CFeeRate& a, const CFeeRate& b) { return a.nAxoshisPerK >= b.nAxoshisPerK; }
    friend bool operator!=(const CFeeRate& a, const CFeeRate& b) { return a.nAxoshisPerK != b.nAxoshisPerK; }
    CFeeRate& operator+=(const CFeeRate& a) { nAxoshisPerK += a.nAxoshisPerK; return *this; }
    std::string ToString(const FeeEstimateMode& fee_estimate_mode = FeeEstimateMode::AXE_KVB) const;

    SERIALIZE_METHODS(CFeeRate, obj) { READWRITE(obj.nAxoshisPerK); }
};

#endif // SUPERAXECOIN_POLICY_FEERATE_H
