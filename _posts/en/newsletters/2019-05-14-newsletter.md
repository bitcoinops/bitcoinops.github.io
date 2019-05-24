---
title: 'Bitcoin Optech Newsletter #46'
permalink: /en/newsletters/2019/05/14/
name: 2019-05-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes a special section about the recent
Taproot proposal, news about a small potential change to the BIP174 PSBT
format, and our regular sections about bech32 sending support and
notable changes in popular infrastructure projects.

{% include references.md %}

## Action items

*None this week.*

## Dashboard items

- **Higher feerates:** at the time of writing, estimated feerates for
  confirmation in the next 2 blocks are ten times higher than estimates
  for confirmation within 30 blocks (six hours) and a hundred times
  higher than estimates for waiting 144 blocks (1 day) or more.  This
  may mean there's still an opportunity to cheaply consolidate a modest
  number of inputs in case feerates rise even further, but only if you
  can tolerate a potentially long wait for the consolidation transaction
  to confirm.

## News

- **Soft fork discussion:** several replies were posted to the
  Bitcoin-Dev mailing list in response to [bip-taproot][] and
  [bip-tapscript][].  Additionally, Anthony Towns [posted][anyprevout
  post] a proposal for an additional soft fork change that uses
  bip-taproot features to enable functionality similar in purpose to
  [BIP118][] SIGHASH_NOINPUT.  As this week's newsletter already
  includes a special section about Taproot, we're deferring summaries of
  the feedback and extension to next week's newsletter so readers can
  have some time to digest the essentials of Taproot first.

- **Addition of derivation paths to BIP174 PSBTs:** Stepan Snigirev
  [posted][psbt path] a suggestion to the Bitcoin-Dev mailing list to
  allow PSBTs to include the BIP32 extended public key (xpub) and derivation path for the public keys
  used to generate the change output's address.  This can help multisig
  wallets determine whether or not the transaction's change output pays
  back to the correct set of signers.  The author of [BIP174][], Andrew
  Chow, was receptive to the idea, as was the developer for a hardware
  wallet.

## Overview of the Taproot & Tapscript proposed BIPs

Last week, Pieter Wuille [emailed][taproot post] the Bitcoin-Dev mailing
list with links to two proposed BIPs.  The first, [bip-taproot][],
permits spending using either a Schnorr-style signature or merklized
script. The second, [bip-tapscript][], defines a slight variation on
Bitcoin's existing Script language to be used in bip-taproot merkle
spends.

For readers already familiar with Bitcoin scripting and ideas like
[MAST][], it should be possible to understand the BIPs directly.  For
readers with less background, we've prepared the following summary of
some key features from the proposals by looking at them from the point
of view of an existing wallet that wants to upgrade to use Taproot and
Tapscript.  This only skims the surface of what these proposals make
available, as one reason developers have been waiting for Schnorr
signatures and MAST-based encumbrances is that they provide the building
blocks for new features that were previously difficult or impossible to
build on Bitcoin.  We'll leave the description of those advances for
another time and focus here on how the two proposed BIPs can make
existing uses of Bitcoin work even better than they do today.

Please note, all Taproot features will be opt-in for wallets, so no
existing wallet will need to change how it works.  Only wallets that
want to take advantage of the benefits of Taproot and Tapscript will
need to upgrade.

### What's not in the proposals

Before we look at what features the proposals may add to Bitcoin, let's
take a moment to look at some things that aren't part of the proposals:

- **No cross-input signature aggregation:** just like current Bitcoin
  transactions, each input will need to contain all its required
  signatures.  This means transactions such as consolidations and
  coinjoins won't receive any special discount.  If the Taproot and
  Tapscript proposals become part of Bitcoin, we think developers will
  continue to look for ways to bring cross-input signature aggregation
  to Bitcoin in future soft forks, but they'll need to find ways to
  address [complications][sigagg complications] that were discovered
  during their research into the advanced techniques described by
  bip-taproot.  (See [Newsletter #3][] for related discussion in the
  context of [bip-schnorr][].)

- **No new sighash types:** although some existing sighash types are
  tweaked a bit, the proposals do not offer anything similar to
  [BIP118][] SIGHASH_NOINPUT.  However, bip-tapscript does provide a
  forward-compatibility mechanism (tagged public keys) that will make it
  easy for future soft forks to extend the signature-checking opcodes
  with new sighash types or other changes.

- **No activation mechanism specified:** if users decide they want to
  begin enforcing the soft fork's new rules, safety requires that enough
  of them begin enforcing the new rules at the same block so that miners
  are deterred from creating blocks that violate the new rules.  Various
  mechanisms have been used to accomplish this in the past and other
  options have been described for potential future use.  However,
  bip-taproot doesn't mention any of these techniques.  Optech agrees
  with the primary author of the BIP that [activation discussion is
  premature][discuss activation].  We first need to ensure that there's
  widespread agreement that the proposals are safe and desirable before
  we start a debate about the best way to activate them.

### Single-sig spending using Taproot

To look at what's in the proposals, we'll primarily examine how existing
use cases could be transferred to Taproot.  The best place to start is by
looking at the way most wealth is transferred via the Bitcoin protocol
right now: single-sig P2PKH and P2WPKH spends.

Single-sig P2WPKH wallets today currently generate a private key, derive
a public key (pubkey) from it, and hash that pubkey to create the
witness program for a bech32 address.  (P2PKH is functionally identical
but uses a different script and a different address encoding.)

| Object      | Operation                                                       | Example result    |
|-|-|-|
| Private key | read 32 bytes from [CSPRNG][], or using [BIP32][] HD derivation | `0x807d[...]0101` |
| Public key  | point(0x807d[...]0101), or using [BIP32][] HD public derivation | `0x02e5[...]3c23` |
| Hash        | ripemd(sha256(0x0202e5[...]3c23))                               | `0x006e[...]05d6` |
| Address     | bech32.encode('bc', 0, 0x006e[...]05d6)                         | `bc1qd6[...]24zh` |

Under Taproot, the hashing step will be skipped and so the bech32
address will contain the pubkey directly, with one small change.
Currently, 33-byte Bitcoin-style pubkeys are encoded to start with either
a 0x02 or 0x03 to allow validators to reconstruct the key's Y-coordinate
on the secp256k1 elliptic curve; in bip-taproot, the value of this byte
is reduced by two so that 0x02 becomes 0x00 and 0x03 becomes 0x01.  The
meaning stays the same but using the low bit for the values frees up the
remaining bits for future soft forks.
Also the witness version is changed from the `0` used
for P2WPKH/P2WSH to a `1`.

| Object           | Operation                               | Example result    |
|-|-|-|
| Private key      | (Same as above)                         | `0x807d[...]0101` |
| Public key       | (Same as above)                         | `0x02e5[...]3c23` |
| Alter key prefix | (key[0] - 2),key[1:33])                 | `0x00e5[...]3c23` |
| Address          | bech32.encode('bc', 1, 0x00e5[...]3c23) | `bc1pqr[...]xg73` |

Here's an example of existing addresses compared to an example taproot
address.

| P2PKH   | `1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC`                              |
| P2SH    | `3QsFXpFJf2ZY6GLWVoNFFd2xSDwdS713qX`                              |
| P2WPKH  | `bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh`                      |
| P2WSH   | `bc1q0jnggjwnn22a4ywxc2pcw86c0d6tghqkgk3hlryrxl7nmxkylmnq6smlx3`  |
| Taproot | `bc1pqrj4788jx79yn3x3wpgks3h6ex3rqgs5tk5qyjreu24vjdgu3q7zxkxxg73` |

Spending from P2PKH or P2WPKH requires the spender include their public
key in their input.  For Taproot, the public key was provided in the
UTXO being spent, so several vbytes are saved by not including it again.
The spend must also include a signature; this is a Schnorr-style
signature as defined by [bip-schnorr][] with an optional sighash byte
appended.  If the default sighash is used, the signature is 64 bytes (16
vbytes); if a non-default is used, it is 65 bytes (16.25
vbytes[^vbytes-decimal]).  Overall, this makes the cost to create and
spend a Taproot single-sig output about 5% more expensive than P2WPKH.
This is probably not significant: the cost to create a Taproot output is
almost the same as to create a P2WSH output---which people pay all the
time without issue---and the cost to spend a single-key Taproot is 40%
cheaper than P2WPKH.

<table style="text-align: center;">
<tr>
  <th style="border-bottom-style: none;"></th>
  <th colspan="3">Vbytes</th>
</tr>
<tr>
  <th style="border-top-style: none;"></th>
  <th>P2PKH</th>
  <th>P2WPKH</th>
  <th>Taproot</th>
</tr>
<tr>
  <th>scriptPubKey</th>
  <td>25</td>
  <td>22</td>
  <td>35</td>
</tr>
<tr>
  <th>scriptSig</th>
  <td>107</td>
  <td>0</td>
  <td>0</td>
</tr>
<tr>
  <th>witness</th>
  <td>0</td>
  <td>26.75</td>
  <td>16.25</td>
</tr>
<tr>
  <th>Total</th>
  <td>132</td>
  <td>48.75</td>
  <td>51.25</td>
</tr>
</table>

Besides the change from ECDSA to Schnorr for the signature algorithm,
there are a few important (but easy to implement) changes to the
transaction digest---the hash that a signature commits to in order to
prove the transaction is an authorized spend of a UTXO.

Most notably, the hash used goes from the legacy protocol's
double-SHA256 (SHA256d) to a single SHA256 operation.  The extra hashing
previously used isn't believed to have provided any meaningful security.
Additionally, the data hashed is prefixed with a value that's specific
to this use of the hash function; this helps prevent problems like
[CVE-2012-2459][] where a hash from one context can be used in another
context.  The prefix tag is `SHA256(tag) || SHA256(tag)` where the tag
in this case is the UTF-8 string "TapSighash" and `||` stands for
concatenation.  Software that needs to create or verify a large number
of signatures (such as active LN nodes or Bitcoin full nodes) can use a
version of their SHA256 function that's been pre-initialized with the
prefix tag so it doesn't need to repeat those operations for every
signature verification.  Implementations that don't require maximal
performance (such as ordinary wallets) can just implement the algorithm
as described using their default SHA256 library function.

There are also some changes to what data is included in the hash and how
it is serialized.  This includes improvements that can help make wallets
without access to verified UTXO entries (e.g. hardware wallets and
[HSMs][]) more efficient because they don't need to retrieve as much
data in order to ensure they're signing for correct UTXOs and amounts.

Although that may sound like a significant number of changes, we suspect
it's only an afternoon worth of work making minor serialization changes
for any wallet that's already segwit compatible and which can gain
access to a library like [libsecp256k1][] for generating
bip-schnorr-compatible signatures.

## Simple multisig spending using Taproot

After single-sig UTXOs, the most common are simple multisig UTXOs.
These are outputs that depend on a certain number of signatures from
particular pubkeys but don't have any other conditions.  These are used
both by individual users (e.g. requiring multiple devices to work
together in a spend) and by multiple parties to a single transaction
(e.g. escrows).

There are two ways to perform simple multisig spending using Taproot,
the most efficient of which is key and signature aggregation as
described in this subsection.  We'll examine the other mechanism in the
next subsection.

For aggregation, two or more private keys are created and their pubkeys
are derived.  The pubkeys are then combined into a single pubkey that's
indistinguishable from any other Bitcoin pubkey.  This is used as the
segwit witness program as described in the
previous subsection.  Later, the owner or owners of some or all of the
private keys create signatures that are combined into a single signature
that's also indistinguishable from any other bip-schnorr signature.
This must commit to the same transaction digest as described in the
previous subsection, but the result is a multisig spend that's
completely indistinguishable from a single-sig spend.

You may have noticed that the preceding paragraph is vague about the
exact mechanism used to aggregate the keys and signatures.  The reason
for that is because there are multiple known methods and any one of them
can be used by the participants.  It's even possible for researchers to
find new methods and implement them in Bitcoin wallets without any
consensus changes.  This is because the signature algorithm is only
looking for a single pubkey and a single signature that are valid under
rules described in the single-sig subsection above.  That said, of the
methods known, the [MuSig protocol][musig] is probably the best studied
aggregation protocol in the context of Bitcoin.

The number of bytes used for aggregated keys and signatures is exactly
the same no matter how many signers are involved.  This can be compared
to P2WSH multisig where each additional pubkey adds 8.50 vbytes and each
additional signature adds about 18.25 vbytes.

![Size of taproot multisig compared to P2WSH](/img/posts/2019-05-taproot-multisig-size.png)

## Complex spending with Taproot

Bitcoin's Script language allows users to specify what conditions must
be fulfilled in order for their bitcoins to be spent, conditions that
sometimes require more than just signatures.  Taproot not only supports
this feature but enhances it in several ways.

We can consider this by looking at a basic Hash TimeLock Contract (HTLC)
similar to those used in LN and cross-chain atomic swaps.  This contract
can terminate three ways:

1. Alice receives the contracted money (a payment) by publishing a
   pre-image that releases the contract's hashlock.
2. Bob receives the contracted money (a refund) after a timelock has
   expired.
3. Alice and Bob mutually agree about how to distribute the money,
   usually because one of them could use one of the preceding
   conditions to force a payment or refund.

To take the LN case of HTLCs as an example, we can produce two
independent scripts, each of which handles one of the first two items
above:

    (1) OP_HASH256 <hash> OP_EQUALVERIFY <Alice pubkey> OP_CHECKSIG
    (2) <time> OP_CHECKLOCKTIMEVERIFY OP_DROP <Bob pubkey> OP_CHECKSIG

These separate scripts are then hashed so that they can be used as the
leaves of a merkle tree.  As described earlier, the data to be hashed is
prefixed with a tag (itself hashed) indicating its purpose.  "TapLeaf"
is the tag in this case.  The leaves must also include the size of the
script and a version (only version 0xc0 is defined in this proposal;
other versions are available for future soft fork upgrades).

After the two scripts are hashed, their digests are put in lexicographic
order.  This ordering will allow later verification of a merkle
inclusion proof without knowing whether or not each leaf or branch
appeared in the tree to the left or right of its pair sibling, thus
reducing the amount of data that needs to be communicated as well as
potentially improving privacy.  After ordering, the two hashes will be
hashed together with the prefix tag "TapBranch".  As this merkle tree
only has two leaves, the resultant hash is the merkle root.

![Example taproot merkle tree](/img/posts/2019-05-taproot-tree.png)

This merkle tree only covers two of the HTLC's possible end states.  For
the third case where Alice and Bob mutually agree on a spend, they can
use signature aggregation using something like MuSig.  As in the
multisig section above, they work together to create a single pubkey,
called the *Taproot internal key.*

The merkle root and the internal key are then hashed together (prefix
tag, "TapTweak") and the resultant digest is used as a private key from
which a pubkey is derived, this value being known as the *tweak.*  The
tweak pubkey is added to the internal key in order to derive the *taproot output
key---*the key that is used in any bech32 addresses and scriptPubKeys
that pay these three conditions.

![Construction of taproot tweak and output key](/img/posts/2019-05-taproot-tweak.png)
{:.center}

When it comes time to spend this money, either Alice or Bob can provide
the script they want to use, the data needed by it (a signature and,
in Alice's case, a hash preimage), the Taproot internal key, and the hash of
the script they didn't use.  Alternatively, Alice and Bob can work together
to use signature aggregation (after accounting for the tweak) to provide
a signature in combination with the same single-key, single-signature
spending pattern described in the previous subsections.  As long as the
data they provide in either case is correct, the spend will be accepted.

{% comment %}<!--
    P2WSH
      scriptPubKey: 34
      witnessScript: OP_IF OP_HASH256 <hash> OP_EQUALVERIFY <A pubkey>
                     OP_ELSE <time> OP_CLTV OP_DROP <B pubkey> OP_ENDIF OP_CHECKSIG
                     8 non-push, 4 push, 2x33 (pubkeys), 1x32 (hash), 1x4 (delta) = 114

      1. witnessScript, OP_1, preimage, Alice sig
          1+114           1      1+32       1+72    = 221/4 => 55.25

      2. witnessScript, OP_0, Bob sig
          1+114           1     1+72    = 189/4  => 47.25

      3. N/A (use one of the above)

    Taproot
      scriptPubKey: 35
      1. OP_HASH256 <hash> OP_EQUALVERIFY <Alice pubkey> OP_CHECKSIG
            1        1+32        1             1+33          1        = 69

         script, preimage, A sig; internal key; leaf hash
          1+69      1+32    1+64     1+33           32       = 234/4 => 58.5

      2. <time>     OP_CHECKLOCKTIMEVERIFY OP_DROP <Bob pubkey> OP_CHECKSIG
              1+4             1                 1        1+33         1 = 41

         script, B sig; internal key; leaf hash
           1+41   1+64      1+33         1+32       = 174/4 => 43.5

      3. AB sig

          1+64 = 65/4 => 16.25
-->{% endcomment %}

| | scriptPubKey vbytes | witness vbytes | Total vbytes |
|-|-|-|-|
| P2WSH (1) Alice spends   | 34  | 55.25 | 89.25 |
| P2WSH (2) Bob spends     | 34  | 47.25 | 81.25 |
| P2WSH (3) Mutual spend   | N/A | N/A   | N/A   |
| Taproot (1) Alice spends | 35  | 58.50 | 93.50 |
| Taproot (2) Bob spends   | 35  | 43.50 | 78.50 |
| Taproot (3) Mutual spend | 35  | 16.25 | 51.25 |

Because we chose to use a small tree and a simple example script, the
cost of using Taproot script-path spending is similar to the cost of the data
that can be omitted from the unspent branch, leading to slightly higher
costs for Taproot in the case where Alice spends.  However, the case
where Bob spends is slightly cheaper and the case of the mutual spend is
significantly less expensive than any of the other options (and using it
would completely hide that this was an HTLC).

The maximum depth of a tree is 32 rows, allowing a tree to contain a
maximum of around four billion scripts.  However, only one of those
scripts would appear in any spending transaction and only 32 hashes
directly related to the merkle tree would need to be generated to prove
the script was part of the tree---this means that more complex scripts
than our simple HTLC can gain much larger efficiency improvements than
seen above (see an article focused on [MAST][] for more information).

### Slight changes to scripting with Tapscript

When using Bitcoin Script with Taproot, some of the rules have been
changed, most notably:

- **Unused and invalid opcodes redefined:** the bytes of opcodes that
  were never assigned, or which were made invalid by Satoshi Nakamoto,
  or which were created for upgrades and have not been used yet have all
  been changed to have the semantics of an `OP_SUCCESS` opcode that
  unconditionally renders any script containing that code valid.
  Because future soft forks can only add new rules by making
  previously-valid things invalid, this maximal validity
  today will allow maximal flexibility in future soft forks.  Of course,
  receivers get to choose what scripts they use to receive payments, so no
  one should include an `OP_SUCCESS` opcode in
  their scripts until a soft fork has given it a new consensus-enforced
  meaning.

- **Schnorr signatures required:** ECDSA signatures will not be accepted
  in Tapscript.

- **New script-based multisig semantics:** the current
  `OP_CHECKMULTISIG` and `OP_CHECKMULTISIGVERIFY` opcodes are not
  available in Tapscript.  There are two alternatives.  First, the
  existing single-sig `OP_CHECKSIG` and `OP_CHECKSIGVERIFY` may be used
  in series.  For example (2-of-2 multisig):

      <A pubkey> OP_CHECKSIGVERIFY <B pubkey> OP_CHECKSIG

    Second, a new `OP_CHECKSIGADD` (`OP_CSADD`) opcode may be used to
    increment a counter if a signature matches a specified public key.
    For example (2-of-3):

      <A pubkey> OP_CHECKSIG <B pubkey> OP_CSADD <C pubkey> OP_CSADD OP_2 OP_EQUAL

    This change is made to allow for batch verification of multiple
    signatures, which can [significantly speed up
    verification][bip-schnorr] compared to checking each signature
    independently.

- **Redefined sigops limit:** because verifying signatures is the most
  CPU expensive operation in Bitcoin Script, an early version of Bitcoin
  added a limit on the maximum number of signature-checking operations
  (sigops) a block could contain, and versions of this limit were
  applied to later P2SH and segwit v0 scripts.  However, one problem
  with this limit is that miners must consider two factors when
  trying to select what valid transactions to include in a block:
  fee density (fee/vbyte) and sigop density (sigops/vbyte).  This is
  much more difficult than optimizing block composition based on just fee density.

    Taproot resolves this down to one parameter by requiring valid
    transactions using Taproot spends include a certain amount of data
    for each sigop that succeeds.  The rule is one free sigop and then
    the witness must contain 50 bytes of data for each additional sigop.  Since Schnorr
    signatures are at least 64 bytes, this should provide more than
    enough space to cover all expected uses, and it means that miners
    can simply include the most profitable valid Taproot transactions in
    their blocks without worrying about sigops.

### Taproot and Tapscript summary and next steps

Together, these proposals bring Bitcoin two features that developers
have been wanting for years.  The first of these features, Schnorr
signatures, will make available increased privacy and reduced fees for
the growing number of Bitcoin users taking advantage of multisig
security (including LN users), and research into advanced uses of
Schnorr such as [scriptless scripts][] and [discrete log contracts][]
may enable many significant improvements in efficiency, privacy, and
financial contracting without further necessary consensus changes.

The second feature, Taproot-based MAST, allows developers to write scripts
that are much more complex than are possible today but still minimize
their onchain impact by allowing spenders to only put the minimum amount
of data onchain---lowering the feerates for advanced users while also
improving their privacy.

Finally, because there's a strong chance that many single-sig,
multisig, and MAST-based spends can all be resolved using nothing but a
single public key and a single signature, it may become much harder to
track different users who are using
different Bitcoin features---an advantage that benefits all Bitcoin
users by making bitcoin ownership harder to track and thus bitcoins more
fungible and harder to efficiently censor in piecemeal fashion.

However, the future of these proposals is not certain.  At this stage,
they need careful review by experts in cryptography and the Bitcoin
protocol, as well as from application developers who plan to use these
features.  Following that, they will need to be implemented for full
nodes, which will require more review and also extensive testing (an
[example implementation][] is available, but it's currently meant to
help proposal reviewers).  Finally, it will be up to the people who use
their own full nodes for validating their incoming payments to decide
whether or not they want to enforce this proposal.

Optech doesn't know when---or if---any of those goals will be
accomplished, but we'll do our best to keep you appraised of any
progress in future editions of this newsletter.

## Bech32 sending support

*Week 9 of 24.  Until the second anniversary of the segwit soft
fork lock-in on 24 August 2019, the Optech Newsletter will contain this
weekly section that provides information to help developers and
organizations implement bech32 sending support---the ability to pay
native segwit addresses.  This [doesn't require implementing
segwit][bech32 easy] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/09-qrcode.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #15730][] extends the `getwalletinfo` RPC with a
  `scanning` field that tells the user how far along the program
  is in rescanning the block chain for transactions affecting their
  wallet (if the user requested a rescan or it was automatically
  triggered).  Otherwise, it simply returns `false`.

- [Bitcoin Core #15930][] deprecates the `getunconfirmedbalance` RPC and
  the three different *balance* fields in the `getwalletinfo` RPC.  In
  their place, a `getbalances` RPC is added that provides provides two
  sets of fields.  For balances the wallet can spend ("IsMine"), a
  `trusted` field for outputs either created by the wallet itself or
  which have at least one confirmation; an `untrusted_pending` field for
  outputs in the mempool that pay the wallet; and an `immature` field
  for outputs from a miner generation transaction that haven't yet
  received 100 confirmations (the earliest they can be spent).  For
  balances the wallet is only watching ("watchonly"), the same three
  fields are provided under a different object.

- [C-Lightning #2524][] records details about failed attempts to forward
  payments so that it can later display those details in the
  `listforwards` RPC.

- [Bitcoin Core #15939][] removes the build target for 32-bit Windows,
  meaning there will be no Win32 binaries for future versions of Bitcoin
  Core.  Evidence suggests that very few (if any) Bitcoin Core users are
  using 32-bit Windows.

## Acknowledgements

We thank Anthony Towns and Pieter Wuille for their insightful reviews of
a draft of this newsletter's Taproot overview.  Any remaining errors are
the fault of the newsletter author.

## Footnotes

[^vbytes-decimal]:
    Technically, vbytes are an integer unit to make them
    backwards-compatible with the bytes unit in legacy Bitcoin block
    weighting.  We use them in this document as a floating-point unit
    for additional precision.

{% include linkers/issues.md issues="15730,15930,2524,15939" %}
[anyprevout post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016929.html
[psbt path]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016894.html
[taproot post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016914.html
[mast]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[sigagg complications]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-March/015838.html
[discuss activation]: https://twitter.com/pwuille/status/1125478777084006400
[csprng]: https://en.wikipedia.org/wiki/Cryptographically_secure_pseudorandom_number_generator
[hsms]: https://en.wikipedia.org/wiki/Hardware_security_module
[musig]: https://blockstream.com/2018/01/23/en-musig-key-aggregation-schnorr-signatures/
[scriptless scripts]: http://diyhpl.us/wiki/transcripts/layer2-summit/2018/scriptless-scripts/
[discrete log contracts]: https://adiabat.github.io/dlc.pdf
[example implementation]: https://github.com/sipa/bitcoin/commits/taproot
