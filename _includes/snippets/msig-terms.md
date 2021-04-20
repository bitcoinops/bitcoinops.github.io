| Term | Private keys | Messages<br>(e.g. tx inputs) | Published pubkeys | Signatures | Signers required | Notes |
|-|-|-|-|-|
| Multisig | `m` | `1` | `m` | `k` where `k<=m` | `k` | Uses Bitcoin Script multisig opcodes |
| [Multisignature][topic multisignature] | `m` | `1` | `1` | `1` | `m` | Indistinguishable onchain from single-sig |
| [Threshold signature][topic threshold signature] | `m` | `1` | `1` | `1` | `k` where `k<=m` | Indistinguishable onchain from single-sig |
