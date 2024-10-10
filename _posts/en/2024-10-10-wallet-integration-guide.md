---
title: "Guide for Wallets Employing Bitcoin Core 28.0 Policies"
permalink: /en/bitcoin-core-28-wallet-integration-guide/
name: 2024-10-10-bitcoin-core-28-wallet-integration-guide
type: posts
layout: post
lang: en
slug: 2024-10-10-bitcoin-core-28-wallet-integration-guide

excerpt: >
  In Bitcoin Core 28.0 contains new P2P and mempool policy features that may be useful for a number of wallets and transaction types. Here Gregory Sanders presents a high-level guide to the feature set and how they can be used individually or together.

---

{:.post-meta}
*by [Gregory Sanders][]*

In [Bitcoin Core 28.0][bc 28.0] contains new P2P and mempool policy
[features][bc 28.0 release notes] that may be useful for a number of wallets and
transaction types. Here Gregory Sanders presents a high-level guide to the
feature set and how they can be used individually or together.

## One Parent One Child (1P1C) Relay

Prior to Bitcoin Core 28.0, each transaction must meet or exceed the local
node’s dynamic mempool minimum feerate in order to even enter its mempool. This
value rises and falls roughly with transaction congestion, creating a
fluctuating floor for propagating a payment. This creates great difficulty for
wallets dealing with presigned transactions that cannot sign
[replacements][topic rbf] and have to predict what the future floor value will
be when it comes time to settle the transaction. This is hard enough over a
period of minutes, but clearly impossible over months.

[Package relay][topic package relay] has been a long sought-after feature for
the network to mitigate this risk of transactions getting stuck without
fee-bumping options. Once properly developed and deployed widely on the network,
package relay would allow wallet developers to bring fees to a transaction via
related transactions, allowing low-fee ancestors to be included in the mempool.

In Bitcoin Core 28.0, a limited variant of package relay for packages containing
1 parent and 1 child ("1P1C") was implemented. 1P1C allows a single parent into
the mempool, regardless of the dynamic mempool minimum feereate, using a single
child transaction and a simple [Child Pays For Parent (CPFP)][topic cpfp] fee
bump. If the child transaction has additional unconfirmed parents, these
transactions will not successfully propagate. This restriction simplified the
implementation greatly and allowed other mempool work, such as [cluster
mempool][topic cluster mempool], to continue unabated while still targeting a
large number of use-cases.

Unless a transaction is a [TRUC transaction][topic v3 transaction relay]
(described later), every transaction must still meet a *static* 1 satoshi per
virtual byte minimum.

One final caveat to the feature is that the propagation guarantees for this
release are also limited. If the Bitcoin Core node is connected to a
sufficiently determined adversary, they can disrupt propagation of the parent
and child transaction pair. Additional hardening of package relay continues as
an ongoing [project][package relay tracking issue].

General package relay remains a future work, to be informed by data from limited
package relay and its rollout on the network.

Here are commands for setting up a wallet demonstrating 1P1C relay in a regtest
environment:

```hack
bitcoin-cli -regtest createwallet test
{
  "name": "test"
}
```

```hack
# Get address to self-send to
bitcoin-cli -regtest -rpcwallet=test getnewaddress
bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3
```

```hack
# Create low-fee transaction above “minrelay”
bitcoin-cli -regtest -rpcwallet=test -generate 101
{
[
...
]
}

bitcoin-cli -regtest -rpcwallet=test listunspent
[
  {
    "txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b",
    "vout": 0,
    ...
    "amount": 50.00000000,
    ...
  }
]

# Mempool minfee and minrelay are same, to test this functionality more easily
# we will use TRUC transactions to allow 0-fee transactions that require 1P1C relay.
# Fullrbf is also enabled, which is the 28.0 default.
bitcoin-cli -regtest getmempoolinfo
{
  "loaded": true,
  ...
  "mempoolminfee": 0.00001000,
  "minrelaytxfee": 0.00001000,
  ...
  “fullrbf”: true,
}

# Start with v2 transaction
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "50.00000000"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# And swap out the leading 02 for 03 which is the TRUC version
03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Sign and send
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

error code: -26
error message:
min relay fee not met, 0 < 110

# We need package relay and CPFP using the single output
bitcoin-cli -regtest decoderawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

{
  "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "hash": "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
  "version": 3,
  "size": 191,
  "vsize": 110,
  ...
  "vout": [
    ...
    "scriptPubKey": {
      "hex": "001400991cdadccdf30cb5a04663b0371cb433a095b4",
    ...
}

# Leave out sats for CPFP fees
bitcoin-cli -regtest createrawtransaction '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99994375"}]'
0200000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Sign TRUC variant and send, as a 1P1C package
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 0300000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "50.00000000"}]'
{
  "hex": "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf": {
      "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
      "vsize": 110,
      "fees": {
        "base": 0.00000000,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    },
    "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55": {
      "txid": "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de",
      "vsize": 110,
      "fees": {
        "base": 0.00005625,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    }
  },
  "replaced-transactions": [
  ]
}
```

The 1P1C package has entered into the local mempool at an effective feerate of
25.568 sats per vB even though the parent transaction is below minrelay feerate.
Success!

## TRUC Transactions

Topologically Restricted Until Confirmation (TRUC) transactions, also known as
v3 transactions, is a new, opt-in [mempool policy][policy series] aimed at
allowing robust replace-by-fee (RBF) of transactions, mitigating both
fee-related transaction [pinning][topic transaction pinning] as well as package
limit pinning. Its central philosophy is: **while many features are infeasible
for all transactions, we can implement them for packages with a limited
topology**. TRUC creates a way to opt-in to this more robust set of policies in
addition to the topological restrictions.

In short, a TRUC transaction is a transaction with an nVersion of 3, which
restricts the transaction to either a singleton of up to 10kvB, or the child of
exactly one TRUC transaction capped at 1kvB. A TRUC transaction cannot spend a
non-TRUC transaction, and vice versa. All TRUC transactions are considered
opt-in RBF regardless of [BIP125][] signaling. If another non-conflicting TRUC
child is added to the parent TRUC transaction, it will be treated as a
[conflict][topic kindred rbf] with the original child, and normal RBF resolution
rules apply, including feerate and total fee checks.

TRUC transactions are also allowed to be 0-fee, provided a child transaction
bumps the overall package feerate sufficiently.

The limited topology also neatly falls within the 1P1C relay paradigm,
regardless of what transaction counterparties do, assuming all versions of
signed transactions are TRUC.

TRUC payments are replaceable, so any transactions with inputs not owned at
least in part by the transactor can be double-spent. In other words, receiving
zero-conf TRUC payments is not safer than receiving non-TRUC ones.

## 1P1C-topology Package RBF

Sometimes the 1P1C package’s parent conflicts with the in-mempool parent. This
can happen when there are multiple versions of the parent transaction presigned.
Previously the new parent would be considered for RBF alone, and discarded if
the fee was too low.

With 1P1C topology package RBF, the new child will also be included for
consideration in the RBF checks, allowing a wallet developer to get robust
transmission of 1P1C packages through the P2P network, regardless of what
versions of transactions have hit their local mempool.

Note that, currently, the conflicted transactions all must be singletons
themselves or 1P1C transaction packages with no other dependencies. Otherwise
the replacement will be rejected. Any number of such clusters can be conflicted.
This will be relaxed in a future release as a result of cluster mempool.

Continuing our running 1P1C example, we are going to execute a package RBF
against the existing 1P1C package, this time with a non-TRUC transaction
package:

```hack
# Parent and child TRUC pair
bitcoin-cli -regtest getrawmempool
[
  "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
]

# Double-spend the parent with a new v2 1P1C package
# where parent fees are above minrelay but not enough to RBF the package
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99999"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Sign and (fail to) send
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

error code: -26
error message:
insufficient fee, rejecting replacement f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59, less fees than conflicting txs; 0.00001 < 0.00005625

# Bring additional fees to new package via child to beat old package
bitcoin-cli -regtest createrawtransaction '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99234375"}]'

020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Sign and send as package
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "49.99999"}]'
{
  "hex": "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313": {
      "txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59",
      "vsize": 110,
      "fees": {
        "base": 0.00001000,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    },
    "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c": {
      "txid": "858fe07b01bc7c1c1dda50ba16a33b164c0bc03d0eff8f9546558c088e087f60",
      "vsize": 110,
      "fees": {
        "base": 0.00764625,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    }
  },
  "replaced-transactions": [
    "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
    "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
  ]
}

```

## Pay To Anchor (P2A)

[Anchors][topic anchor outputs] are defined as an output that is added solely to
allow a child transaction to CPFP that transaction. Since these outputs are not
payments, they have low, close to “dust” satoshi values, and are immediately
spent.

A new output script type, [Pay To Anchor (P2A)][topic ephemeral anchors], has
been added, which allows for an optimized “keyless” version of anchors. The
output script is “OP_1 <4e73>”, which requires no witness data to spend, meaning
a fee reduction compared to existing anchor outputs. It also allows anyone to
create the CPFP transaction.

P2A can be used independently from TRUC transactions or 1P1C packages. A
transaction with a P2A output but no child can be broadcast, though the output
is trivially spendable. Similarly, packages and TRUC transactions do not need to
have P2A outputs in order to use the new fee-bumping features.

This new output type has a dust limit of 240 satoshis. P2A outputs below this
dust threshold do not propagate, even if they are spent in a package, as the
[dust][topic uneconomical outputs] limit is still fully enforced in policy.
While this proposal was previously linked with ephemeral dust, this is no longer
the case.

Example P2A creation and spend:

```hack
# Regtest address for P2A is “bcrt1pfeesnyr2tx” in regtest, “bc1pfeessrawgf” in mainnet
bitcoin-cli -regtest getaddressinfo bcrt1pfeesnyr2tx
{
  "address": "bcrt1pfeesnyr2tx",
  "scriptPubKey": "51024e73",
  "ismine": false,
  "solvable": false,
  "iswatchonly": false,
  "isscript": true,
  "iswitness": true,
  "ischange": false,
  "labels": [
  ]
}

# Segwit output, type “anchor”
bitcoin-cli -regtest decodescript 51024e73
{
  "asm": "1 29518",
  "desc": "addr(bcrt1pfeesnyr2tx)#swxgse0y",
  "address": "bcrt1pfeesnyr2tx",
  "type": "anchor"
}

# Minimum satoshi value P2WPKH and P2A outputs
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "0.00000294"}, {"bcrt1pfeesnyr2tx": "0.00000240"}]'
02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000

# Sign and send transaction with P2A output
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true

# Turns off sanity fee check
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000 "0"
fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b

# Replaced prior package
bitcoin-cli -regtest getrawmempool
[
  "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b"
]

# For child, burn value to fees, make 65vbyte tx with OP_RETURN to avoid tx-size-small error
bitcoin-cli -regtest createrawtransaction '[{"txid": "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b", "vout": 1}]' '[{"data": "feeeee"}]'
02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000

# No signing required; it’s witness-free segwit
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000
8d092b61ef3c1a58c24915671b91fbc6a89962912264afabc071a4dbfd1a484e

```

## User Stories

Moving on from the more general release notes level feature description, we will
describe a few common wallet patterns and how they can benefit from these
updates, with or without the wallets making active changes.

### Simple Payments

One problem users have is that they can't RBF with confidence that the receivers
of bitcoin would not be able to create arbitrary chains of transactions off of
the payment, pinning the user. If users wish to have more predictable RBF
behavior, one way would be to opt-in to TRUC transactions. Incoming payments
could also be robustly bumped via an up to 1kvB spend of the incoming deposit
output.

If adapted, wallets should:

- set version to 3
- only use confirmed outputs
- stay within 10kvB (as opposed to the 100kvB non-TRUC limit)
  - This restricted limit still supports larger batch payments.
  - If a wallet has no choice but to spend an unconfirmed input, the input must
    come from a TRUC transaction, and this new transaction needs to be below
    1kvB.

### Coinjoins

In the [coinjoin][topic coinjoin] scenario where privacy is the focus but the
coinjoin is not attempting to be covert, TRUC transactions for the coinjoin
itself may be worthwhile. The coinjoin may have insufficient feerate for
inclusion in the blockchain, thus requiring a fee bump.

Along with TRUC transactions, a P2A output could be added allowing for a
segregated wallet like a watchtower to pay for the transaction fees alone.

If other participants spend their unconfirmed outputs, TRUC sibling eviction may
occur. Sibling eviction preserves TRUC topology limits, but allows a higher
feerate CPFP to be added - a new child is allowed to "replace" the previous one
without spending conflicting inputs. Thus, all participants of the coinjoin are
always able to CPFP the transaction.

Pinning caveat: Participants in the coinjoin may still economically grief the
transaction by double-spending their own input to the coinjoin, requiring the
coinjoin to RBF the griefer’s first transaction.

### Lightning Network

Transactions generated in the Lightning Network protocol consist of a few main
types:

1. Funding transactions: Single-party funded or dual-party funded transactions
to set up the contract. Less time sensitivity to confirm.
2. Commitment transactions: The transaction that commits to the latest state of
the payment channel. These transactions are asymmetrical, and currently require
a “update_fee” message bi-directionally to update how much of the funding output
value is given to fees. The fees must be enough to propagate the latest version
of the commitment transaction into miners’ mempools.
3. HTLC presigned transactions

With 1P1C relay and package RBF, upgrading Bitcoin Core nodes significantly
increases the security of the Lightning Network. Lightning unilateral closes can
be accomplished with commitment transactions with below mempool minfee feerates,
or conflicting with another low-fee commitment transaction package that wouldn’t
be promptly included in a block.

To take the maximal advantage of this upgrade, wallets and backends should
integrate with the **submitpackage** Bitcoin Core RPC command:

```hack
bitcoin-cli submitpackage ‘[“<commitment_tx_hex>”, “<anchor_spend_hex>”]’
```

Wallet implementations should integrate their software with the command using
the commitment transaction as well as an anchor child spend to ensure inclusion
into miners’ mempools with the appropriate feerate.

Note: The RPC endpoint will return success if you submit a many-child,
single-parent package, but these will not propagate under the 1P1C relay update.

After a sufficient number of nodes upgrade on the network, the LN protocol may
be updated to drop the “update_fee” message, which has been a source of
unnecessary force closes during fee spikes for years now. With removal of this
protocol message, commitment transactions could be set to a static 1 sat/vbyte
feerate. With TRUC transactions, we can ensure that competing commitment
transactions with anchor spends are allowed to RBF each other over the network,
and if there are competing output spends from the same commitment transaction,
that RBF can occur no matter which output is being spent. TRUC transactions are
also allowed to be 0-fee, allowing reduction in spec complexity. With TRUC’s
sibling eviction, we can also drop the 1 block CSV locktimes, since we are no
longer overly concerned with what unconfirmed outputs are being spent, as long
as each party can spend a single output themselves.

With TRUC + P2A Anchors, we can reduce the blockspace usage of the current two
anchors down to a single keyless anchor. This anchor requires no commitment to a
public key or  signatures, saving additional blockspace. The fee bumping can
also be outsourced to other agents that have no privileged key material. Anchors
could also consist of a single output with shared key material between the
counterparties rather than P2A, at the cost of additional vbytes in the benign
unilateral close case.

Similar strategies can be pursued when implementing advanced features such as
splicing, to reduce the risk of RBF pinning. For example, a TRUC channel splice
that is less than 1kvB in size could CPFP another channel's unilateral close,
without exposing the bumper to RBF pins. Subsequent bumps can be done in series
by replacing just the channel splice transaction. This comes at the cost of
revealing the TRUC transaction type during splices.

As you can see, significant complexity can be avoided and savings achieved with
the updated features, provided each transaction can fit into the 1P1C paradigm.

### Ark

Not all transaction patterns fit into the 1P1C paradigm. A prime example of this
is [Ark][topic ark] outputs, which commit to a tree of presigned (or
covenant-committed) transactions to unroll a shared UTXO.

If an Ark Service Provider (ASP) goes offline or processes a transaction, the
user can choose to do a unilateral exit, which involves the user submitting a
series of transactions to unroll their branch place in the transaction tree.
This requires O(logn) transactions. Difficulty can arise if other clients are
also attempting to leave the tree, exceeding mempool chain limits, or creating
conflicting transactions with insufficient fees for timely inclusion in a block.
If a particularly long time window elapses without inclusion, the ASP is able to
recoup all the funds unilaterally, resulting in user funds loss.

Ideally the initial unilateral close of an Ark tree would be:

1. The publication of an entire merkle branch to the underlying virtual
UTXO (vUTXO)
2. Each of these transactions are 0-fee, to avoid fee prediction or the
requirement to decide who pays fees a priori
3. The ultimate leaf transaction has a 0-value anchor spend where the CPFP pays
for the entire merkle tree’s publication to a miner’s mempool and inclusion in a
block

To execute this ideal properly, we are missing a few things:

1. General package relay. We have no method currently of propagating these
chains of fee-less transactions over the P2P network robustly.
2. If too many branches are published at low feerates, this can result in users
being unable to publish their own branch promptly due to descendant count limit
pinning. This could be disastrous as the number of counterparties becomes large,
as is the case in the idealized Ark scenario.
3. We need generalized sibling eviction. We don’t have 0-value output support
for valueless anchors.

Instead, let us try to fit the required transaction structure into the 1P1C
paradigm as best we can, at the cost of some additional fees. All Ark tree
transactions, starting at the root, are a TRUC transaction and add to it a
minimal satoshi value P2A output.

When a transactor chooses to unilaterally exit from an Ark, the user publishes
the root transaction plus spend of P2A for fees, then waits for confirmation.
Once confirmed, the user submits the next transaction in their merkle branch,
along with its own P2A being spent for CPFP. This continues until the whole
merkle branch is published and the funds are safely extracted from the Ark tree.
Other users of the same Ark may maliciously or accidentally submit the same
inner node transaction with too low a feerate, but sibling eviction would ensure
that at every step honest child transactions below 1kvB could RBF competing
children without requiring all other outputs be locked, or multiple anchors.

Assuming binary trees, this comes at the asymptotic cost of nearly 100% vbyte
overhead versus the idealized Ark for the first user, and roughly 50% over the
whole tree if it completely unrolls. For 4-nary, this diminishes to ~25% over
the whole tree.

### LN Splices

Other topologies also come up in more advanced Lightning Network constructs that
may need some work to match with 1P1C relay.

Lightning Network [splices][topic splicing] are an emerging standard and in
general use already. Each splice spends the original funding output,
re-depositing contract funds into a new funding output, with the same presigned
commitment transaction chain as before. While unconfirmed, the original channel
state and new channel state(s) are simultaneously signed and tracked.

One example that could exceed the 1P1C paradigm is the case where:

1. Alice and Bob fund a channel.
2. Alice splices *out* some funds to an on-chain address controlled by Carol,
who is using a cold set of keys, so she cannot CPFP. This splice-out is shooting
for confirmation within hours.
3. Bob’s node goes offline or force-closes for some reason.
4. Feerates skyrocket (perhaps some token just launched), delaying confirmation
of the splice-out transaction unduly.

Alice wants the on-chain payment to Carol to happen, so she does not go to chain
with a commitment transaction without the splice. This means
splice_tx->commitment_tx->anchor_spend becomes the required package to make this
propagate.

Instead, let us consider how to fit it within the 1P1C paradigm, without wasting
vbytes when unnecessary. An LN wallet could, instead of running one splice-out
per on-chain payment, do 2 splice-outs, since they’re conflicting. One version
uses the relatively conservative feerate chosen by the fee estimator. The other
version could include a P2A output at 240 satoshis, or 0 satoshis in the future
with [ephemeral dust][topic ephemeral anchors].

First, broadcast the non-anchored splice-out.

If there’s no fee event, it is confirmed and Alice can continue the force close
as normally if desired.

If there is a fee event causing the first splice-out to take too long, broadcast
the 1P1C splice *with* anchor along with anchor spend, using package RBF to
replace the first splice-out. This fee bump enables confirmation and payment to
Carol, then continue with the force close if desired.

More copies of splice-outs could also be issued at various fee levels, but note
that each copy would require an additional set of signatures for the commitment
transaction as well as all outstanding offered HTLCs.

{% include references.md %}

[Gregory Sanders]: https://github.com/instagibbs
[bc 28.0]: https://github.com/bitcoin/bitcoin/releases/tag/v28.0
[bc 28.0 release notes]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-28.0.md
[package relay tracking issue]: https://github.com/bitcoin/bitcoin/issues/27463
[policy series]: /en/blog/waiting-for-confirmation/
