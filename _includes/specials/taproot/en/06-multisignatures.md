{% comment %}<!--
  Using dump-multisigs from img/posts/2021-07-multisig-fungibility.gnuplot

    for i in `seq 691039 692039` ; do dump-multisigs $i ; done > RESULTS
    echo $( grep of RESULTS | wc -l ) / $( cat RESULTS | wc -l ) | bc -l
-->{% endcomment %}
In the 1,000 blocks received prior to this writing, 11% of all
transaction inputs contained a multisig opcode.  Two of the largest and
most immediate benefits of taproot will manifest if many of the users
and services creating those transactions switch from multisig opcodes to
scriptless [multisignatures][topic multisignature].

The first major benefit will be a reduction in transaction size.
Script-based multisigs increase in size as more keys and signatures are
required, but multisignatures are a constant small size.  The smallest
effective multisig policy (1-of-2) requires more space than a
multisignature policy that can involve thousands of signers.  The
decrease in size leads to direct reduction in fees for the
multisignature users and an indirect reduction in fees for all users as
the same amount of demand for confirmed transactions can be fulfilled
using a smaller amount of block space.

{:.center}
![Plot showing the savings for multisignatures compared to multisig](/img/posts/2021-07-multisignature-savings.png)

The second major benefit is improved privacy.  Each use of multisigs is
distinctively recorded to the block chain where surveillants
can use them to make informed guesses about the wallet history and
current balance of individual users.  For example, looking at block
692,039, we can distinguish not just the multisig spends from the
single-sig spends but also distinguish between different set sizes and
thresholds for the multisigs.

{:.center}
![Illustration of the lack of witness fungibility in current blocks](/img/posts/2021-07-multisig-unfungible.png)

By comparison, a third party looking only at block chain data can't tell
that a spender used a multisignature.  When a multisignature is used for
a keypath spend, it is indistinguishable from single-sig spends.  If all
single-sig and multisigs in the block above were switched to P2TR
keypath spends, only a few exotic spends would be distinguishable by
their scripts (and even those could use keypath spends in the best case).

{:.center}
![Illustration of how fungibile witnesses could be ideally](/img/posts/2021-07-multisignature-fungible.png)

### Using multisignatures

We're aware of three schnorr-based multisignature schemes designed
specifically for Bitcoin, all members of the [MuSig][topic musig]
family:

- **MuSig** (also called MuSig1), which should be simple to implement
  but which requires three rounds of communication during the signing
  process.

- **MuSig2**, also simple to implement.  It eliminates one round of
  communication and allows another round to be combined with key
  exchange.  That allows using a somewhat similar signing
  process to what we use today with script-based multisig.  This does
  require storing extra data and ensuring your signing software or
  hardware can't be tricked into unknowingly repeating part of the
  signing session.

- **MuSig-DN** (Deterministic Nonce), significantly more complex to
  implement.  Its communication between participants can't be combined
  with key exchange, but it has the advantage that it's not vulnerable to the repeated
  session attack.

All signers have to agree on the protocol to use, so there may
be a network effect where many implementations choose to use the same
protocol.  The authors of the MuSig proposals [suggest][nick ruffing
blog] that will be MuSig2 due to its relative simplicity and high
utility.  <!-- "[...] there is no reason to prefer MuSig1 over MuSig2
[...] we expect that most applications will choose MuSig2 over MuSig-DN
[...]" -->

There's an open and actively-developed [PR][-zkp 131] to the libsecp256k1-zkp
project to add MuSig2 support.  We expect the basic multisignature workflow will look
something like the following:

1. The wallet for each participant generates a [BIP32][] xpub that is shared
   with all the other participants through an [output script
   descriptor][topic descriptors] or another method
   (the same as is commonly done now for
   multisigs).

2. The wallet also generates a set of nonces that are also shared with
   the other participants.  The wallet can generate these nonces using
   BIP32 hardened derivation.  Nonces are 32 bytes and you need two of
   them per signature.  For infrequently used wallets, all the nonces
   needed for the entire wallet lifetime can be shared up front.  For
   more frequently used wallets (e.g. LN routing nodes), each wallet can
   send its signature for the current transaction along with its nonces
   for the next transaction.

3. Any of the wallets can then generate an aggregated public key by
   combining its pubkey at a certain BIP32 depth with pubkeys at the
   same depth from all other wallets in the multisignature association.
   The aggregated public key can be used to receive P2TR payments.

4. When one of the wallets wants to spend the funds, it uses a
   [PSBT][topic psbt]-based workflow similar to what it would use with
   script-based multisig.  Unlike multisig, the wallet uses its next
   nonces and the next nonces of all the other participants to create a
   shared nonce according to the MuSig2 algorithm; it then creates a
   partial signature over that nonce and the transaction.

5. When the other wallets receive the PSBT, they use the same procedure.
   The partial signatures are then combined to create the final
   signature and the transaction is broadcast.

### Threshold signing

By themselves, the MuSig family of multisignature schemes only give you
n-of-n signing---every party who contributes a key towards the
aggregated public key must also contribute a partial signature to the
final signature.  That works perfectly well as a direct replacement for
some uses of script-based multisig today, such as spending 2-of-2 LN
funding outputs, but it's a departure from other popular policies such
as the 2-of-3 multisig script used by many exchanges.

Several developers are working [threshold signature][topic threshold
signature] schemes that will bring the same efficiency and privacy
benefits of multisignatures to k-of-n scenarios, but there's a simple
trick that can be used until those schemes are available.

In many threshold cases, it's known in advance which participants are
most likely to sign.  For example, in a 2-of-3 situation, it might be
known that normally Alice and Bob will co-sign, while Carol only signs
if one of the others is unavailable.  For this set of circumstances, the
primary keys can use a multisignature for the taproot keypath spend (e.g.
between Alice and Bob) and the additional outcomes (Alice and Carol, or
Bob and Carol) can use multisignatures with the `OP_CHECKSIG` opcode in
separate branches in a tree of [tapscripts][topic tapscript].

In the normal case, the above has exactly as much efficiency and privacy
as a single-sig or multisignature transaction.  In the abnormal case,
spending still works as expected and remains more efficient and private
than publishing your multisig parameters onchain.

Although users wanting minimal fees and maximal privacy may eventually
switch to pure threshold signature schemes, the above [scheme][erhardt post] may also
continue to remain in use because it provides onchain proof to an
auditor (if they know all of the participants' public keys) about which
corresponding private keys were used to sign.

[nick ruffing blog]: https://medium.com/blockstream/musig2-simple-two-round-schnorr-multisignatures-bf9582e99295
[-zkp 131]: https://github.com/ElementsProject/secp256k1-zkp/pull/131
[erhardt post]: https://murchandamus.medium.com/2-of-3-multisig-inputs-using-pay-to-taproot-d5faf2312ba3
