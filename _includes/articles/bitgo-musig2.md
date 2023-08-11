{:.post-meta}
*by [Brandon Black][] from [BitGo][]*

The first [MuSig paper][] was published in 2018, and the potential of
[MuSig][topic musig] on
Bitcoin was one of the selling points used to gain support for the taproot soft
fork. Work on MuSig continued with the publication of [MuSig-DN][] and [MuSig2][] in 2020.
When taproot neared activation on Bitcoin’s mainnet in 2021, excitement
about bringing MuSig signing to Bitcoin users was palpable. At BitGo, we were
hoping to launch a MuSig taproot wallet concurrent with taproot activation; but
the spec, test vectors, and reference implementation were incomplete. Instead,
BitGo [launched][bitgo blog taproot] the first tapscript multisig wallet and made the [first tapscript
multisig transaction][] on mainnet. Nearly two years later, MuSig2 is specified in
[BIP327][], and we [launched][bitgo blog musig2] the first MuSig taproot multisig wallet.

{{include.extrah}}## Why MuSig2?

{{include.extrah}}### Compared to Script Multisig

There are two main
benefits of MuSig compared to script multisig. The first and most obvious
benefit is a reduced transaction size and miner fee. Onchain signatures are
64-73 bytes, 16-18.25 virtual bytes (vB), and MuSig can combine two (or more)
signatures into one. In BitGo’s 2-of-3 case, a MuSig key path input costs
57.5vB, compared to a native SegWit input at 104.5vB or depth 1
[tapscript][topic tapscript] at
107.5vB. The second benefit of MuSig is an improvement in privacy. With a MuSig
key path on a collaboratively held output, a cooperative spend cannot be
distinguished by a third party blockchain observer from a single signature
taproot spend.

Naturally, there are some drawbacks to MuSig2. Two important ones revolve around
[nonces](#nonces-deterministic-and-random). Unlike signers for plain ECDSA (elliptic curve digital signature
algorithm) or [schnorr signatures][topic schnorr signatures], MuSig2 signers cannot consistently use
deterministic nonces. This inability makes it more difficult to ensure
high-quality nonces and to ensure against nonce reuse. MuSig2 requires two
rounds of communication in most cases. First nonce exchange, and then signing.
In some cases, the first round can be precomputed, but this must be undertaken
cautiously.

{{include.extrah}}### Compared to Other MPC protocols

MPC (multi-party compute) signing protocols are growing in popularity due to the
aforementioned fee and privacy benefits. MuSig is a _simple_ multi-signature
(n-of-n) protocol, made possible by schnorr signatures’ linearity. MuSig2 can be
explained in a 30-minute presentation, and the complete reference implementation
is 461 lines of code in Python. [Threshold signature][topic threshold signature] (t-of-n) protocols, such as
[FROST][], are significantly more complex, and even [2-party multi-signatures][] based
on ECDSA rely on Paillier encryption and other techniques.

{{include.extrah}}## Choice of Scripts

Even before [taproot][topic taproot], choosing a specific script for a multi-signature (t-of-n)
wallet was difficult. Taproot, with its multiple spending paths further
complicates the matter, and MuSig layers in even more options. Here are some of
the considerations that went into the design of BitGo’s taproot MuSig2 wallet:

- We use fixed key order, not lexicographic sorting. Each signing key has a
specific role stored with the key, so using those keys in the same order each
time is simple and predictable.
- Our MuSig key path includes only the most common signing quorum, “user” /
“bitgo”. Including the “backup” signing key in the key path would significantly
reduce how often it could be used.
- We do not include the “user”, “bitgo” signing pair in the Taptree. As this is
our second taproot script type and the first is a three tapscript design, users
requiring script signing can use the first type.
- For tapscripts, we do not use MuSig keys. Our wallets include a “backup” key
which is potentially difficult to access or signs with software outside of our
control, so expecting to be able to sign MuSig for the “backup” key is not
realistic.
- For tapscripts, we choose `OP_CHECKSIG` / `OP_CHECKSIGVERIFY` scripts over
`OP_CHECKSIGADD`. We know which keys will sign when we construct transactions, and
2-of-2 depth 1 scripts are slightly cheaper than 2-of-3 depth 0.

The final structure looks like this:

{:.center}
![BitGo's MuSig taproot structure](/img/posts/bitgo-musig/musig-taproot-tree.png)

{{include.extrah}}## Nonces (deterministic and random)

Elliptic curve digital signatures are produced with the help of an ephemeral
secret value known as a nonce (number used once). By sharing the public nonce (public
nonce is to secret nonce as public key is to secret key) in the signature,
verifiers can confirm the validity of the signature equation without revealing
the long-lived secret key. To protect the long-lived secret key, a nonce must
never be reused with the same (or related) secret key and message. For single
signatures, the most commonly recommended way to protect against nonce reuse is
[RFC6979][] deterministic nonce generation. A uniformly random value can also be
used safely if it is immediately discarded after use. Neither of these
techniques can be applied directly to multi-signature protocols.

To use deterministic nonces safely in MuSig, a technique like MuSig-DN is
necessary to prove that all participants correctly generate their deterministic
nonces. Without this proof, a rogue signer can initiate two signing sessions for
the same message but provide different nonces. Another signer who generates
their nonce deterministically will generate two partial signatures for the same
nonce with different effective messages, thus revealing their secret key to the
rogue signer.

During the development of the MuSig2 specification, [Dawid][] and I realized that
the _last_ signer to contribute a nonce could generate their nonce
deterministically. I discussed this with [Jonas Nick][], who formalized it into the
specification. For BitGo’s MuSig2 implementation, this deterministic signing
mode is used with our HSMs (Hardware Security Modules) to enable them to execute
MuSig2 signing statelessly.

When using random nonces with multi-round signing protocols, signers must
consider how the secret nonces are stored between rounds. In single signatures,
the secret nonce can be deleted in the same execution as it is created. If an
attacker could clone a signer immediately after nonce creation but before
providing nonces from the other signers, the signer could be tricked into
producing multiple signatures for the same nonce but different effective
messages. For this reason, it is recommended that signers carefully consider how
their internal states can be accessed and exactly when secret nonces are
deleted. When BitGo users sign with MuSig2 using the BitGo SDK, secret nonces
are held within the [MuSig-JS][] library, where they are deleted on access for
signing.

{{include.extrah}}## The Specification Process

Our experience with implementing MuSig2 at BitGo shows that companies and
individuals working in the Bitcoin space should take the time to review and
contribute to the development of specifications that they intend to (or even
hope to) implement. When we first reviewed the draft MuSig2 specification and
started studying how best to integrate it into our signing systems, we
considered various difficult methods to introduce stateful signing on our HSMs.

Fortunately, as I described the challenges to Dawid, he was confident that there
was a way to use a deterministic nonce, and we eventually settled on the rough
idea that one signer could be deterministic. When I later raised that idea to
Jonas and explained the specific use case we were trying to enable, he
recognized the value and formalized it into the specification.

Now other MuSig2 implementers can also take advantage of the flexibility offered
by allowing one of their signers not to manage state. By reviewing (and
implementing) the draft specification during its development, we were able to
contribute to the specification and be ready to launch MuSig2 signing soon after
the specification was formally published as BIP327.

{{include.extrah}}## MuSig and PSBTs

The [PSBT (Partially Signed Bitcoin Transaction)][topic psbt] format is intended to carry all
information needed to sign a transaction between the parties (e.g., coordinator
and signers in a simple case). The more information is needed for signing, the
more valuable the format becomes. We examined the costs and benefits of
expanding our existing API format with additional fields to facilitate MuSig2
signing vs. converting to PSBT. We settled on converting to PSBT format for
transaction data interchange, and it’s been a huge success. It’s not widely
known yet, but BitGo wallets (except those using MuSig2, see the next paragraph)
can now integrate with hardware signing devices that support PSBTs.

There are not yet published PSBT fields for use in MuSig2 signing. For our
implementation, we used proprietary fields that were based on a draft shared
with us by [Sanket][]. This is one of the little talked about benefits of the PSBT
format - the ability to include _whatever_ additional data might be needed for
your custom transaction building or signing protocol in the same binary data
format; with global, per-input, and per-output sections already defined. The
PSBT specification separates the unsigned transaction from the scripts,
signatures, and other data needed to eventually form a complete transaction.
This separation can enable more efficient communication during the signing
process. For example, our HSM can respond with a minimal PSBT including only its
nonces or signatures, and they can be combined into the pre-signing PSBT easily.

{{include.extrah}}## Acknowledgements

Thanks to Jonas Nick and Sanket Kanjalkar at Blockstream; Dawid Ciężarkiewicz at
Fedi; and [Saravanan Mani][], David Kaplan, and the rest of the team at BitGo.

{% include references.md %}
[Brandon Black]: https://twitter.com/reardencode
[BitGo]: https://www.bitgo.com/
[MuSig paper]: https://eprint.iacr.org/2018/068
[MuSig-DN]: https://eprint.iacr.org/2020/1057
[MuSig2]: https://eprint.iacr.org/2020/1261
[bitgo blog taproot]: https://blog.bitgo.com/taproot-support-for-bitgo-wallets-9ed97f412460
[first tapscript multisig transaction]: https://mempool.space/tx/905ecdf95a84804b192f4dc221cfed4d77959b81ed66013a7e41a6e61e7ed530
[bitgo blog musig2]: https://blog.bitgo.com/save-fees-with-musig2-at-bitgo-3248d690f573
[FROST]: https://datatracker.ietf.org/doc/draft-irtf-cfrg-frost/
[2-party multi-signatures]: https://duo.com/labs/tech-notes/2p-ecdsa-explained
[RFC6979]: https://datatracker.ietf.org/doc/html/rfc6979
[Dawid]: https://twitter.com/dpc_pw
[Jonas Nick]: https://twitter.com/n1ckler
[MuSig-JS]: https://github.com/brandonblack/musig-js
[Sanket]: https://twitter.com/sanket1729
[Saravanan Mani]: https://twitter.com/saravananmani_
