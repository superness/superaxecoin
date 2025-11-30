// Copyright (c) 2023 SuperAxeCoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "logprintf.h"

#include <clang-tidy/ClangTidyModule.h>
#include <clang-tidy/ClangTidyModuleRegistry.h>

class SuperAxeCoinModule final : public clang::tidy::ClangTidyModule
{
public:
    void addCheckFactories(clang::tidy::ClangTidyCheckFactories& CheckFactories) override
    {
        CheckFactories.registerCheck<superaxecoin::LogPrintfCheck>("superaxecoin-unterminated-logprintf");
    }
};

static clang::tidy::ClangTidyModuleRegistry::Add<SuperAxeCoinModule>
    X("superaxecoin-module", "Adds superaxecoin checks.");

volatile int SuperAxeCoinModuleAnchorSource = 0;
