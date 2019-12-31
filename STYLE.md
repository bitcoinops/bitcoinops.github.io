# Optech Style Guide

## Vocabulary

### Proper nouns

The first letter of a proper noun is always capitalized.

- Bitcoin (the network)
- MuSig (the pubkey and signature aggregation scheme. Don't refer to Musig, muSig or musig)
- Script (when referring to the Bitcoin scripting language)
  - use script (no capitalization) when referring to an indvidual script
- True/False when refering to boolean arguments in plain text (eg
  "set foo to True").
  - use whatever capitalization is appropriate when used in code (eg
    "set `foo=true`")

### Common nouns

The first letter of a common noun is only capitalized at the start of a
sentence or heading.

- bech32
- bitcoin (the currency)
- eltoo
- erlay
- merkle (tree|root|branch|node)
- schnorr
- segwit
- sybil (as in 'sybil attack')
- taproot

### Abbreviations

- Introduce sighash with "signature hash (sighash)", but don't introduce sighash
  types (`SIGHASH_SINGLE`, `SIGHASH_ALL`, etc) since they're technical terms
  and not abbreviations.

#### Unintroduced abreviations

The first occurrence of an abbreviation in a document should be preceded
by its full name (e.g. Foo Bar Baz (FBB)) with the exception of the
following abbreviations we assume readers will already know.

- BIP (Bitcoin Improvement Proposal)
  - BIPXXX referencing a specific BIP number (no zero padding eg. BIP70 not BIP070)
- BTC (Bitcoin)
- DoS (Denial-of-service)
- ECDSA (Elliptic Curve Digital Signature Algorithm)
- kB, MB, GB, TB, etc... (SI-prefixed byte sizes)
- kiB, MiB, GiB, TiB, etc... (SI-prefixed binary byte sizes)
- LN (Lightning Network)
- LND (Lightning Network Daemon - the Lightning Labs LN implementation)
- mempool (memory pool)
- P2P (Peer-to-Peer)
- P2PKH (Pay to Public Key Hash)
- P2SH (Pay to Script Hash)
- P2SH-wrapped segwit (Pay to Script Hash wrapped segwit)
- P2WPKH (Pay to Witness Public Key Hash)
- P2WSH (Pay to Witness Script Hash)
- pubkey (public key)
- RPC (Remote Procedure Call)
- RFC (Request For Comments, the IETF documents)
- segwit (segregated witness)
- txid (transaction identifier)
- UTXO (Unspent Transaction Output)
- vbyte (virtual byte)

#### Forbidden abbreviations

- Core (use Bitcoin Core)

### Compound words

| Use | Don't use | Notes |
|-|-|-|
| block chain | blockchain | |
| coinjoin | Coinjoin, coinJoin or coin-join | |
| feerate | fee-rate or fee rate | |
| mainnet | main net | |
| multisig | multi-sig | |
| multiparty | multi-party | |
| offchain | off-chain | |
| onchain | on-chain | |
| opcode | OPCODE, OpCode, Opcode or op code | |
| OP_RETURN (and all other opcodes) | op_return | |
| preimage | pre-image | |
| proof of work | proof-of-work | proof-of-work may be used as an adjective phrase (e.g. "Bitcoin's proof-of-work security is economic in nature"). | |
| redeemScript | redeem script | |
| secp256k1 | Secp256k1, SECP256k1 or SECP256K1 | |
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
| k-of-n multisig and n-of-n multisignature | m-of-n multisig or any_other_letter-of-any_other_letter multisig | When spoken, 'm-of-n' can easily be confused with 'n-of-n' |
| light client | lite client | |
| merklized | merkelized or merkleized | |

### Preferred terms

| Use | Don't use | Notes |
|-|-|-|
| coinbase transaction | generation transaction | |
| Merklized Alternative Script Trees | Merklized Abstract Syntax Trees | https://bitcoinops.org/en/newsletters/2018/12/28/#fn:fn-mast |
| receiver | recipient | |
| spender | sender | "sender" may ambiguously refer to the sender of data |
| uneconomical output | dust | The dust limit is the minimum value an output must contain in order for Bitcoin Core to relay a transaction containing that output. What's economical or not changes as minimum feerates change, but the dust limit doesn't change often. |

## Units

- **Currency:** all amounts should be denominated in BTC.  E.g. "the
  default minimum relay fee is 0.00000001 BTC/vbyte".  When writing out
  the name of the currency, pluralize by appending an `s`.  E.g. "Alice
  owns several bitcoins" not ~~"Alice owns several bitcoin"~~.

- **Weight:** use vbytes rather than weight units, unless using weight
  units would significantly improve conciseness or comprehensibility.
  You may use fractional vbytes, but consider adding a note that
  production uses of vbytes require they be rounded up.
