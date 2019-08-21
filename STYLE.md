# Optech Style Guide

## Vocabulary

### Proper nouns

The first letter of a proper noun is always capitalized.

- Bitcoin (the network)
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
- mempool (memory pool)
- P2P (Peer-to-Peer)
- P2PKH (Pay to Public Key Hash)
- P2SH (Pay to Script Hash)
- P2SH-wrapped segwit (Pay to Script Hash wrapped segwit)
- P2WPKH (Pay to Witness Public Key Hash)
- P2WSH (Pay to Witness Script Hash)
- pubkey (public key)
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
| coinjoin | Coinjoin or coinJoin or coin-join | |
| mainnet | main net | |
| multisig | multi-sig | |
| multiparty | multi-party | |
| MuSig | Musig or muSig or musig | |
| offchain | off-chain | |
| onchain | on-chain | |
| preimage | pre-image | |
| redeemScript | redeem script | |
| single-sig | singlesig | |
| soft fork/hard fork | softfork/hardfork or soft-fork/hard-fork | soft-fork/hard-fork may be used as compound adjectives (eg "Foo proposed a soft-fork change") |
| 2-of-3 | 2 of 3 | |

### Spelling

The author of the document gets to choose its flavor of English (e.g.
American or British).  However, the following terms should always be
spelled the same.

| Use | Don't use |
|-|-|
| k-of-n multisig | m-of-n multisig |
| light client | lite client |

### Preferred terms

| Use | Don't use | Notes |
|-|-|-|
| spender | sender | "sender" may ambiguously refer to the sender of data |
| receiver | recipient | |

## Units

- **Currency:** all amounts should be denominated in BTC.  E.g. "the
  default minimum relay fee is 0.00000001 BTC/vbyte".  When writing out
  the name of the currency, pluralize by appending an `s`.  E.g. "Alice
  owns several bitcoins" not ~~"Alice owns several bitcoin"~~.

- **Weight:** use vbytes rather than weight units, unless using weight
  units would significantly improve conciseness or comprehensibility.
  You may use fractional vbytes, but consider adding a note that
  production uses of vbytes require they be rounded up.
