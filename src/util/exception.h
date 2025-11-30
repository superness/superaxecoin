// Copyright (c) 2009-2010 Axoshi Nakamoto
// Copyright (c) 2009-2023 The SuperAxeCoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef SUPERAXECOIN_UTIL_EXCEPTION_H
#define SUPERAXECOIN_UTIL_EXCEPTION_H

#include <exception>
#include <string_view>

void PrintExceptionContinue(const std::exception* pex, std::string_view thread_name);

#endif // SUPERAXECOIN_UTIL_EXCEPTION_H
