Using Optech's [transaction size calculator][], we can compare the sizes
of different types of single-sig transactions.  As expected,
transactions using P2WPKH inputs and outputs are much smaller than those
using P2PKH inputs and outputs---but, perhaps surprisingly, P2TR
transactions are slightly larger than equivalent P2WPKH transactions.

|                    | P2PKH (legacy) | P2WPKH (segwit v0) | P2TR (taproot/segwit v1) |
|--------------------|----------------|--------------------|--------------------------|
| **Output**         |  34            | 31                 | 43                       |
| **Input**          |  148           | 68                 | 57.5                     |
| **2-in, 2-out tx** |  374           | 208.5              | 211.5                    |

That may make it seem counterproductive for single-sig wallets to
implement taproot spending in preparation for block {{site.trb}}, but a
closer look reveals that there are a number of advantages to using P2TR
for single-sigs, both for wallet users and for the network as a whole.

- **Cheaper to spend:** it costs about 15% less at the input level to
  spend a single-sig P2TR UTXO than it does to spend a P2WPKH UTXO.  An
  overly simple analysis like the table above hides the detail that the spender
  can't choose which addresses they're asked to pay, so if you stay on
  P2WPKH and everyone else upgrades to P2TR, the actual typical size of
  your 2-in-2-out transactions will be 232.5 vbytes---while all-P2TR
  transactions will still only be 211.5 vbytes.

- **Privacy:** although some privacy is lost when early adopters change
  to a new script format, users switching to taproot also immediately
  receive a privacy boost.  Your transactions will be able to look
  indistinguishable from people working on new LN channels, more
  efficient [DLCs][topic dlc], secure [multisignatures][topic
  multisignature], various clever wallet backup recovery schemes, or a
  hundred other pioneering developments.

    Using P2TR for single-sig now also allows your wallet to upgrade to
    multisignatures, tapscripts, LN support, or other features later on
    without affecting the privacy of your existing users.  It won't
    matter whether a UTXO was received to an old version or a new
    version of your software---both UTXOs will look the same onchain.

- **More convenient for hardware signing devices:** since the
  rediscovery of the [fee overpayment attack][news101 fee overpayment
  attack], several hardware signing devices have refused to sign a
  transaction unless each UTXO spent in that transaction is accompanied
  by metadata containing a copy of significant parts of the entire
  transaction which created that UTXO.  This greatly increases the
  worst-case processing that hardware signers need to perform and is
  especially problematic for hardware signers using limited-size QR
  codes as their primary communication medium.  Taproot eliminates the
  vulnerability underlying the fee overpayment attack and so can
  significantly improve the performance of hardware signers.

- **More predictable feerates:** ECDSA signatures for P2PKH and P2WPKH
  UTXOs can vary in size (see [Newsletter #3][news3 sig size]).  Since
  wallets need to choose a transaction's feerate before creating the
  signature, most wallets just assume the worst case signature size and
  accept that they'll slightly overpay the feerate when a smaller
  signature is generated.  For P2TR, the exact size of the signature is
  known in advance, allowing the wallet to reliably choose a precise
  feerate.

- **Help full nodes:** the overall security of the Bitcoin system
  depends on a significant percentage of Bitcoin users verifying every
  confirmed transaction with their own nodes.  That includes verifying
  the transactions your wallet creates.  Taproot's [schnorr
  signatures][topic schnorr signatures] can be efficiently batch
  verified, [reducing by about 1/2][batch graph] the number of CPU
  cycles nodes need to expend when verifying signatures during the
  process of catching up on previous blocks.  Even if you rejected every
  other point on this list, consider preparing to use taproot for the
  benefit of people running full nodes.

[transaction size calculator]: /en/tools/calc-size/
[news3 sig size]: /en/newsletters/2018/07/10/#unrelayable-transactions
[news101 fee overpayment attack]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[batch graph]: https://github.com/jonasnick/secp256k1/blob/schnorrsig-batch-verify/doc/speedup-batch.md
