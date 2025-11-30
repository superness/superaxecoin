// Copyright (c) 2011-2020 The SuperAxeCoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef SUPERAXECOIN_QT_SUPERAXECOINADDRESSVALIDATOR_H
#define SUPERAXECOIN_QT_SUPERAXECOINADDRESSVALIDATOR_H

#include <QValidator>

/** Base58 entry widget validator, checks for valid characters and
 * removes some whitespace.
 */
class SuperAxeCoinAddressEntryValidator : public QValidator
{
    Q_OBJECT

public:
    explicit SuperAxeCoinAddressEntryValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

/** SuperAxeCoin address widget validator, checks for a valid superaxecoin address.
 */
class SuperAxeCoinAddressCheckValidator : public QValidator
{
    Q_OBJECT

public:
    explicit SuperAxeCoinAddressCheckValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

#endif // SUPERAXECOIN_QT_SUPERAXECOINADDRESSVALIDATOR_H
