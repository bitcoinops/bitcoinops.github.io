# Optech Style Guide

## Vocabulary

### Proper nouns

The first letter of a proper noun is always capitalized.

- Bitcoin (the network)
- MuSig (the pubkey and signature aggregation scheme. Don't refer to Musig, muSig or musig)
- Script (when referring to the Bitcoin scripting language)
  - use script (no capitalization) when referring to an individual script
- True/False when referring to boolean arguments in plain text (eg
  "set foo to True").
  - use whatever capitalization is appropriate when used in code (eg
    "set `foo=true`")

### Common nouns

The first letter of a common noun is only capitalized at the start of a
sentence or heading.

- bech32
- bitcoin (the currency)
- chaumian (blind signatures|coinjoin|ecash)
- eltoo
- erlay
- merkle (tree|root|branch|node)
- schnorr
- segwit
- sybil (as in 'sybil attack')
- tapbranch
- tapleaf
- taproot
- tapscript

### Abbreviations

- Introduce sighash with "signature hash (sighash)", but don't introduce sighash
  types (`SIGHASH_SINGLE`, `SIGHASH_ALL`, etc) since they're technical terms
  and not abbreviations.
- IBD (Initial Block Download)
- HTLC (Hash Time Locked Contract)
- PTLC (Point Time Locked Contract)

#### Unintroduced abbreviations

The first occurrence of an abbreviation in a document should be preceded
by its full name (e.g. Foo Bar Baz (FBB)) with the exception of the
following abbreviations we assume readers will already know.  All
unintroduced abbreviations should use the same case as appears
below, unless otherwise indicated (e.g. capitalizing "segwit" at the
beginning of a sentence).

- BIP (Bitcoin Improvement Proposal)
  - BIPXXX referencing a specific BIP number (no zero padding eg. BIP70 not BIP070)
- BTC (Bitcoin)
- CPFP (Child Pays For Parent)
- DoS (Denial-of-service)
- ECDSA (Elliptic Curve Digital Signature Algorithm)
- kB, MB, GB, TB, etc... (SI-prefixed byte sizes)
- KiB, MiB, GiB, TiB, etc... (Prefixes denoting byte sizes in powers of 1024)
- LN (Lightning Network)
- LND (Lightning Network Daemon - the Lightning Labs LN implementation)
- mempool (memory pool)
- P2P (Peer-to-Peer)
- P2PKH (Pay to Public Key Hash)
- P2SH (Pay to Script Hash)
- P2SH-wrapped segwit (Pay to Script Hash wrapped segwit)
- P2TR (Pay to TapRoot)
- P2WPKH (Pay to Witness Public Key Hash)
- P2WSH (Pay to Witness Script Hash)
- PSBT (Partially Signed Bitcoin Transaction)
- pubkey (public key)
- RBF (Replace By Fee)
- RPC (Remote Procedure Call)
- RFC (Request For Comments, the IETF documents)
- segwit (segregated witness)
- txid (transaction identifier)
- UTXO (Unspent Transaction Output)
- vbyte (virtual byte)

#### Forbidden terms and abbreviations

- Core (use Bitcoin Core)
- {P2WPKH, P2WSH, P2TR} address (use *bech32 address* or *bech32m
  address*, or write something like "address for P2TR";
  [rationale](https://www.erisian.com.au/bitcoin-core-dev/log-2021-06-28.html#l-89))

### Compound words

| Use | Don't use | Notes |
|-|-|-|
| anti fee sniping | anti-fee sniping, anti-fee-sniping | |
| block chain | blockchain | |
| CPFP or Child Pays For Parent | Child-Pays-For-Parent | |
| coinjoin | Coinjoin, coinJoin or coin-join | |
| coinswap | Coinswap, CoinSwap, coinSwap, or coin-swap | |
| fee bumping | fee-bumping | |
| feerate | fee-rate or fee rate | |
| hashlock | hash-lock or hash lock | |
| keypath | key-path or key path | |
| mainnet | main net | |
| multisig | multi-sig | |
| multiparty | multi-party | |
| offchain | off-chain | |
| onchain | on-chain | |
| opcode | OPCODE, OpCode, Opcode or op code | |
| OP_RETURN (and all other opcodes) | op_return | |
| RBF or Replace By Fee | Replace-By-Fee | |
| preimage | pre-image | |
| presigned | pre-signed | |
| proof of work | proof-of-work | proof-of-work may be used as an adjective phrase (e.g. "Bitcoin's proof-of-work security is economic in nature"). | |
| redeemScript | redeem script | |
| secp256k1 | Secp256k1, SECP256k1 or SECP256K1 | |
| scriptpath | script-path or script path | |
| side-channel | sidechannel | when used to describe a side-channel attack |
| sigop | Sigop, SigOp or sig op | |
| single-sig | singlesig | |
| soft fork/hard fork | softfork/hardfork or soft-fork/hard-fork | soft-fork/hard-fork may be used as compound adjectives (eg "Foo proposed a soft-fork change") |
| 2-of-3 | 2 of 3 | |

### Spelling

The author of the document gets to choose its flavor of English (e.g.
American or British).  However, the following terms should always be
spelled the same.

| Use | Don't use | Notes |
|-|-|-|
| adaptor signatures | adapter signatures | |
| discreet log contracts | discrete<!-- --> log contracts | Remembering to spell this correctly more often than one time in ten is known as the discrete log problem |
| k-of-n multisig and n-of-n multisignature | m-of-n multisig or any_other_letter-of-any_other_letter multisig | When spoken, 'm-of-n' can easily be confused with 'n-of-n' |
| light client | lite client | |
| merklized | merkelized or merkleized | |

### Preferred terms

| Use | Don't use | Notes |
|-|-|-|
| coinbase transaction | generation transaction | |
| hardware signers _or_ hardware signing devices| hardware wallets | The wallet is the software/logical component that tracks UTXOs, constructs transactions, etc. Devices sold as "hardware wallets" are dedicated key storage and signing devices. |
| lowercase words for P2P message types e.g. inv, getdata, tx | Uppercase words e.g. INV, GETDATA, TX | The command type contained in the P2P message is lowercase ascii |
| Merklized Alternative Script Trees | Merklized Abstract Syntax Trees | https://bitcoinops.org/en/newsletters/2018/12/28/#fn:fn-mast |
| payjoin | P2EP, bustapay, PayJoin | |
| receiver | recipient | |
| spender | sender | "sender" may ambiguously refer to the sender of data |
| uneconomical output | dust | The dust limit is the minimum value an output must contain in order for Bitcoin Core to relay a transaction containing that output. What's economical or not changes as minimum feerates change, but the dust limit doesn't change often. |

### Units

- **Currency:** acceptable units and abbreviations are:

    | Unit | Abbreviations | Value | &nbsp; |
    |-|-|-|-|
    | bitcoins | **BTC** | |
    | millibitcoins | mBTC | 0.001 BTC | 1e-3 BTC |
    | microbitcoins | µBTC, uBTC | 0.000001 BTC | 1e-6 BTC |
    | satoshis | **sat** | 0.00000001 BTC | 1e-8 BTC |
    | nanobitcoins | nBTC | 0.000000001 BTC | 1e-9 BTC |
    | millisatoshis | msat | 0.00000000001 BTC | 1e-11 BTC |
    | picobitcoins | pBTC | 0.000000000001 BTC | 1e-12 BTC |

    The abbreviations bolded above may always be used without
    introduction; we encourage introduction of other abbreviations, e.g.
    "you can send 1 millisatoshi (msat) on LN".

    The pluralization and agreement rules for bitcoin/bitcoins,
    satoshi/satoshis, and derived units are the same as for
    dollar/dollars (USD).  Similarly, abbreviations are never
    pluralized.

- **Feerates:** the preferred unit is "sat/vbyte" (satoshis per vbyte).
  When used only sporadically within a page or section, it is preferred
  to write out "sat/vbyte" each time, but when used frequently, you may
  introduce and use the abbreviation "sat/vB".  See note in
  *weight/vbytes* item about using SI prefixes.

- **Weight/vbytes:** use vbytes rather than weight units, unless using weight
  units would significantly improve conciseness or comprehensibility.
  You may use fractional vbytes, but consider adding a note that
  production uses of vbytes require they be rounded up.  When using SI
  prefixes with vbytes, introduce the unit the first time it is used,
  e.g. "...BTC per 1,000 vbytes (BTC/kvB)...".
