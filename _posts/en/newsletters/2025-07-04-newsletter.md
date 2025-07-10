---
title: 'Bitcoin Optech Newsletter #361'
permalink: /en/newsletters/2025/07/04/
name: 2025-07-04-newsletter
slug: 2025-07-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to separate the network connections
and peer management used for onion message relay from those used for
HTLC relay in LN.  Also included are our regular sections summarizing
discussion about changing Bitcoin's consensus and listing recent changes
to popular Bitcoin infrastructure software.

## News

- **Separating onion message relay from HTLC relay:** Olaluwa Osuntokun
  [posted][osuntokun onion] to Delving Bitcoin about allowing nodes to
  use separate connections for relaying [onion messages][topic onion messages] than they
  use for relaying [HTLCs][topic htlc].  Although separate connections may
  currently be possible, such as in the case of direct relay (see
  Newsletters [#283][news283 oniondirect] and [#304][news304
  onionreply]), Osuntokun suggests that separate connections
  should always be an option, allowing nodes to have a different set of
  peers for onion messages from the set of peers they use for relaying
  payments.  He makes several arguments in support of this alternative
  approach: it more clearly separates concerns, nodes can cheaply
  support a greater density of onion message peers than channel peers
  (as channels cost money to create), separation may allow deployment of
  privacy-improving key rotation, and separation may allow faster
  delivery of onion messages due to not being blocked by the
  HTLC commitment communication protocol.  Osuntokun provides specific
  details about the proposed protocol.

  A concern of several replying developers was how the network for onion
  messages could allow
  nodes to be flooded by an excessive number of peers.  In current
  onion message implementations, each node only typically maintains
  connections with its channel partners.  Creating the UTXO to fund a
  channel costs money (onchain fees and opportunity cost) and is unique
  to the node and the channel partner; in short, it is
  one-UTXO-one-connection.  Even if onion message connections had to be
  backed by onchain funds, a single UTXO could be used to open
  connections to every public LN node: one-UTXO-thousands-of-connections.

  Although at least one respondent was supportive of Osuntokun's
  proposal, several respondents so far mentioned concern about the
  denial of service risk.  Discussion was ongoing at the time of
  writing. {% assign timestamp="2:06" %}

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **CTV+CSFS advantages for PTLCs:** developers continued a previous
  discussion (see [Newsletter #348][news348 ctvstep]) about the benefits
  of [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV),
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS),
  or both together for various deployed and imagined protocols.  Of
  particular interest, Gregory Sanders [wrote][sanders ptlc] that CTV+CSFS "would
  accelerate updating [LN] to [PTLCs][topic ptlc], even if [LN-Symmetry][topic eltoo] per-se
  is never adopted.  Re-bindable signatures just makes life so much less
  of a headache when stacking protocols."  Sjors Provoost [asked][provoost ptlc] for
  details and Sanders [replied][sanders ptlc2] with a [link][sanders gist] to his previous
  research into LN messaging changes for PTLCs (see [Newsletter
  #268][news268 ptlc]), adding that "PTLCs on today's protocols [are] by
  no means impossible, but with rebindable signatures it just gets
  significantly simpler."

  Anthony Towns additionally [mentioned][towns ptlc] that "there’s also a lack of
  tooling/standardisation for doing a PTLC reveal in combination with a
  [musig][topic musig] 2-of-2 (which would be efficient on-chain), or even general
  tx signatures (ie `x CHECKSIGVERIFY y CHECKSIG`). [...] This would
  require [adaptor signature][topic adaptor signatures] support for musig2, and that’s not part
  of the spec and was [removed][libsecp256k1 #1479] from the secp256k1
  implementation.  Doing it less efficiently as a separate adaptor
  signature would work too, but even plain adaptor signatures for
  [schnorr sigs][topic schnorr signatures] also isn’t available in secp256k1.  These also aren’t
  included even in the more experimental secp256k1-zkp project. [...] If
  the tooling were ready, I could see PTLC support being added [...] but
  I don’t think anyone considers it a high enough priority to put in the
  work to get the crypto stuff standardised and polished. [...] Having
  [CAT][topic op_cat]+CSFS available would avoid the tooling issue, at a cost in
  on-chain efficiency. [...]  I think with only CSFS available you
  continue having similar tooling problems, because you need to use
  adaptor signatures to prevent your counterparty from choosing a
  different R value for the signature.  These issues are independent of
  the update complexity and peer protocol updates Gregory Sanders
  describes above." {% assign timestamp="5:45" %}

- **Vault output script descriptor:** Sjors Provoost [posted][provoost ctvdesc] to
  Delving Bitcoin to discuss how the recovery information for a wallet
  using [vaults][topic vaults] could be specified using an [output script
  descriptor][topic descriptors].  In particular, he focused on vaults based on
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV), such as those provided by James
  O'Beirne's [simple-ctv-vault][] proof-of-concept implementation (see
  [Newsletter #191][news191 simple-ctv-vault]).

  Provoost cited a [comment][ingala vaultdesc] from a previous discussion by Salvatore
  Ingala that said, "my general take is that descriptors are the wrong
  tool for this purpose"---a sentiment Sanket Kanjalkar [agreed with][kanjalkar vaultdesc1]
  in the current thread but [found][kanjalkar vaultdesc2] a potential workaround for.
  Kanjalkar described a variant CTV-based vault where funds are
  deposited into a more typical descriptor and, from there, are moved
  into a CTV vault.  This avoids a situation that could lead naive users
  into losing money and also allows the creation of a descriptor that
  assumes all funds paid to the typical descriptor are moved into a vault using the
  same settings every time.  This would allow the CTV vault descriptor
  to be succinct and complete without any contortions to the descriptor
  language. {% assign timestamp="15:21" %}

- **Continued discussion about CTV+CSFS advantages for BitVM:** developers
  continued the previous discussion (see [Newsletter #354][news354
  bitvm]) about how the availability of [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)
  and [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) opcodes could "reduce
  [BitVM] transaction sizes by approximately 10x" and allow non-interactive
  peg-ins.  Anthony Towns [identified][towns ctvbitvm] a vulnerability in the original
  proposed contract; he and several other developers described
  workarounds.  Additional discussion looked at the advantages of using
  the proposed [OP_TXHASH][] opcode rather than CTV.  Chris Stewart
  [implemented][stewart ctvimp] some of the discussed ideas using Bitcoin Core's test
  software, validating those parts of the discussion and providing
  concrete examples for reviewers. {% assign timestamp="22:57" %}

- **Open letter about CTV and CSFS:** James O'Beirne [posted][obeirne letter] an open
  letter to the Bitcoin-Dev mailing signed by 66 individuals (as of this writing),
  many of them contributors to Bitcoin-related projects.  The letter
  "asks Bitcoin Core contributors to prioritize the review and
  integration of [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) and
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) within the next six months." The
  thread contains over 60 replies.  Some technical highlights include:

  {% assign timestamp="27:59" %}

  - *Concerns and alternatives to legacy support:* [BIP119][] specifies
    CTV for both witness script v1 ([tapscript][topic tapscript]) and legacy script.
    Gregory Sanders [writes][sanders legacy] that "legacy script support [...]
    considerably increases review surface for no known capability gain
    and no known savings for protocols."  O'Beirne [replied][obeirne legacy] that
    legacy script support could save about 8 vbytes in some cases, but
    Sanders [linked][sanders p2ctv] to his previous pay-to-CTV (P2CTV) proposal and
    proof-of-concept implementation that makes this savings available in
    witness script.

  - *Limits of CTV-only vault support:* signatory Jameson Lopp [noted][lopp ctvvaults]
    that he's "most interested in [vaults][topic vaults]," starting a discussion about
    the set of properties CTV vaults would provide, how they compare to
    vaults deployable today using presigned transactions, and whether
    they provide a meaningful improvement in security (especially
    compared to more advanced vaults that would require additional
    consensus changes).  Key takeaways from this discussion included:

    - *Address reuse danger:* both presigned and CTV vaults must prevent
      users from reusing vaulting addresses or funds are likely to be
      lost.  One way this can be accomplished is by a two-step vaulting
      procedure requiring two onchain transactions to deposit funds into
      the vault.  More advanced vaults requiring additional consensus
      changes would not have this problem, allowing deposits even to a
      reused address (although that would, of course, [reduce
      privacy][topic output linking]).

    - *Theft of staged funds:* both presigned and CTV vaults allow theft
      of authorized withdrawals.  For example, vault user Bob wants to
      pay 1 BTC to Alice.  With presigned and CTV vaults, Bob uses the
      following procedure:

      - Withdraws 1 BTC (plus possibly fees) from his vault to a staging
        address.

      - Waits the amount of time defined by the vault.

      - Transfers 1 BTC to Alice.

      If Mallory has stolen Bob's staging key, she can steal the 1 BTC
      after the withdrawal completes but before the transaction to Alice
      confirms.  However, even if Mallory also compromises the
      withdrawal key, she cannot steal any funds remaining in the vault
      because Bob can interrupt any pending withdrawal and redirect the funds
      to a _safe address_ protected by an ultra-secure key (or keys).

      More advanced vaults do not require the staging step: Bob's
      withdrawal could only go to either Alice or the safe address.
      This prevents Mallory from being able to steal funds between the
      withdrawal and spend steps.

    - *Key deletion:* an advantage of CTV-based vaults over presigned
      vaults is that they don't require deleting private keys to ensure
      that the set of presigned transactions are the only spending options
      available.  However, Gregory Maxwell [noted][maxwell autodelete] that it's simple to
      design software to delete a key immediately after signing the
      transactions without ever exposing the private key to users.  No
      hardware signing devices are known to support this directly at present,
      although at least one device supports it via manual user
      intervention---but it's also the case that no hardware supports CTV even for testing at
      present (to the best of our knowledge).  More advanced vaults
      would share the keyless advantage of CTV but would also require
      integration into software and hardware.

    - *Static state:* a claimed advantage of CTV-based vaults over
      presigned vaults is that it might be possible to compute all
      information necessary to recover the wallet from a static backup,
      such as an [output script descriptor][topic descriptors].  However, there has
      already been work on presigned vaults that also allow static
      backups by storing the non-deterministic parts of presigned state
      in the onchain transactions themselves (see [Newsletter
      #255][news255 presig vault state]).  Optech believes more advanced
      vaults could also be recovered from static state, but we had not
      verified this by press time.<!-- FIXME:harding try to verify & delete -->

  - *Responses from Bitcoin Core contributors:* as of this writing, four
    individuals Optech recognizes as currently active Bitcoin Core
    contributors responded to the letter on the mailing list.  They
    said:

    - [Gregory Sanders][sanders ctvcom]: "This letter is asking for feedback from the
      technical community and this is my feedback.  Undeployed BIPs that
      have not received any updates in years is generally not a sign of
      proposal health, and certainly not a foundation to reject
      technical advice from someone who's paid close attention.  I
      reject this framing, the raising of the bar of changes to this
      proposal to only egregious breaks, and I obviously reject a
      time-based ultimatum for BIP119 as-is.  I still think CTV (again
      in the capability sense) + CSFS are worthy of consideration, but
      this is a surefire way to sink it."

    - [Anthony Towns][towns ctvcom]: "From my perspective, the CTV discussion has
      missed important steps, and instead of those steps being taken,
      advocates have been attempting to use public pressure to force
      adoption on an 'accelerated timeline' pretty much continuously for
      at least three years now.  I've tried to help CTV advocates take
      the steps I believe they've missed, but it's mostly resulted in
      silence or insults rather than anything constructive.  At least
      from where I sit, this is just creating incentive problems, not
      solving them."

    - [Antoine Poinsot][poinsot ctvcom]: "The effect of this letter has been, as could
      have been expected, a major setback in making progress on this
      proposal (or more broadly this bundle of capabilities). I am not
      sure how we bounce back from this, but it necessarily involves
      someone standing up and actually doing the work of addressing
      technical feedback from the community and demonstrating (real) use
      cases. The way forward must be by building consensus on the basis
      of strong objective, technical, arguments. Not with a bunch of
      people stating interest and nobody acting up and helping the
      proposal move forward."

    - [Sjors Provoost][provoost ctvcom]: "Let me also speak a bit to my own motivation.
      Vaults appear to be the only feature enabled by the proposal that
      I personally find important enough to work on. [...] Up until
      quite recently it seemed to me that the momentum for vaults was in
      OP_VAULT, which in turn would require OP_CTV.  But a single
      purpose op code is not ideal, so this project didn't seem to be
      going anywhere.  [...] Conversely, I don't oppose CTV + CSFS; I
      haven't seen an argument that they're harmful. Since there's
      little MeVil potential, I could also imagine other developers
      carefully developing and rolling out these changes. I would just
      keep an eye on the process.  What I  _would_ oppose is a Python
      based alternative implementation and activation client like
      co-signer Paul Sztorc proposed."

  - *Signatory statements:* signers of the letter also clarified their
    intentions in follow-up statements:

    - [James O'Beirne][obeirne ctvcom]: "everyone who signed explicitly wants to see the
      imminent review, integration, and activation planning for CTV+CSFS
      specifically."

    - [Andrew Poelstra][poelstra ctvcom]: "Early drafts of the letter did ask for actual
      integration and even activation, but I did not sign any of those
      early drafts. It was not until the language was weakened to be
      about priorities and planning (and to be a "respectful ask" rather
      some sort of demand) that I signed on."

    - [Steven Roose][roose ctvcom]: "[The letter] merely asks Core contributors to put
      this proposal on their agenda with some urgency. No threats, no
      hard words.  Given that only a handful of Core contributors had
      thus far participated in the conversation on the proposal
      elsewhere, it seemed like a suitable next step to communicate that
      we want Core contributors to provide their position within this
      conversation.  I strongly stand against an approach involving
      independent activation clients and I think the sentiment of this
      e-mail aligns with the preference of having Core be involved in
      any deployment of protocol upgrades."

    - [Harsha Goli][goli ctvcom]: "Most people signed because they really had no idea
      what the next step ought to be, and the pressure for transaction
      commitments was so much so that a bad option (piling of a sign-on
      letter) was more optimal than inaction.  In conversations prior to
      the letter going out (facilitated by my industry survey), I only
      received admonishment of the letter from many of the signatories.
      I actually don't know of a single person who considered it as an
      explicitly good idea. And still they signed. There's signal in
      that."

- **OP_CAT enables Winternitz signatures:** developer Conduition
  [posted][conduition winternitz] to the Bitcoin-Dev mailing list a [prototype
  implementation][conduition impl] that uses the proposed [OP_CAT][topic op_cat] opcode and other
  Script instructions to allow [quantum-resistant][topic quantum
  resistance] signatures using the Winternitz protocol to be
  verified by consensus logic.  Conduition's implementation requires
  almost 8,000 bytes for the key, signature, and script (most of which
  is subject to the witness discount, reducing onchain weight to about
  2,000 vbytes).  This is about 8,000 vbytes smaller than another
  `OP_CAT`-based quantum-resistant [Lamport signature][] scheme
  [previously proposed][rubin lamport] by Jeremy Rubin. {% assign timestamp="1:12:27" %}

- **Commit/reveal function for post-quantum recovery:** Tadge Dryja
  [posted][dryja fawkes] to the Bitcoin-Dev mailing list a method for allowing
  individuals to spend UTXOs using [quantum-vulnerable][topic quantum
  resistance] signature algorithms even if fast quantum computers would
  otherwise allow redirecting (stealing) the output of any attempted spend.
  This would require a soft fork and is a variation of a previous proposal by
  Tim Ruffing (see [Newsletter #348][news348 fawkes]).

  To spend an output in Dryja's scheme, the spender creates a commitment
  to three pieces of data:

  1. A hash of the public key corresponding to the private key that
     controls the funds, `h(pubkey)`.  This is called the _address
     identifier_.

  2. A hash of the public key and the txid of the transaction the spender
     wants to eventually broadcast, `h(pubkey, txid)`.  This is called
     the _sequence dependent proof_.

  3. The txid of the eventual transaction.  This is called the
     _commitment txid_.

  None of this information reveals the underlying public key, which in
  this scheme is assumed to only be known to the person controlling the
  UTXO.

  The three-part commitment is broadcast in a transaction using a
  quantum-secure algorithm, e.g. as an `OP_RETURN` output.  At this
  point an attacker could attempt to broadcast their own commitment
  using the same address identifier but a different commitment txid that
  spends the funds to the attacker's wallet.  However, there is no way
  for the attacker to generate a valid sequence dependent proof given
  that they don't know the underlying public key.  This won't be
  immediately obvious to full verification nodes, but they will be able
  to reject the attacker's commitment after the UTXO owner reveals the
  public key.

  After the commitment confirms to a suitable depth, the spender reveals
  the full transaction matching the commitment txid.  Full nodes verify
  the public key matches the address identifier and that, in combination
  with the txid, it matches the sequence dependent proof.  At this
  point, full nodes purge all but the oldest (most deeply confirmed)
  commitments for that address identifier.  Only the first-confirmed
  txid for that address identifier with a valid sequence-dependent proof
  can be resolved into a confirmed transaction.

  Dryja goes into additional details about how this scheme could be
  deployed as a soft fork, how the commitment byte could be
  reduced by half, and what users and software today can do to prepare
  for using this scheme---as well as limitations in this scheme for
  users of both scripted and [scriptless multisignatures][topic multisignature]. {% assign timestamp="1:22:46" %}

- **OP_TXHASH variant with support for transaction sponsorship:** Steven
  Roose [posted][roose txsighash] to Delving Bitcoin about a variation on `OP_TXHASH`
  called `TXSIGHASH` that extends 64-byte [schnorr signatures][topic schnorr signatures] with
  additional bytes to indicate what fields in the transaction (or
  related transactions) the signature commits to.  In addition to the
  previously proposed commitment fields for `OP_TXHASH`, Roose notes
  that the signature could commit to an earlier transaction in the block
  using an efficient form of [transaction sponsorship][topic fee sponsorship] (see
  [Newsletter #295][news295 sponsor]).  He then analyzes the onchain costs of this
  mechanism compared to existing [CPFP][topic cpfp] and a previous sponsorship
  proposal, concluding: "With [`TXSIGHASH`] stacking, the cost in
  virtual bytes of each stacked transaction can even be lower than their
  original cost without a sponsor included [...] Additionally, all
  inputs are “simple” key-spends, meaning that they could be aggregated
  if [CISA][topic cisa] were to be deployed."

  As of this writing, the post had not received any public replies. {% assign timestamp="1:53:31" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32540][] introduces the `/rest/spenttxouts/BLOCKHASH` REST
  endpoint, which returns a list of spent transaction outputs (prevouts) for a
  specified block, primarily in a compact binary (.bin) format but also in .json
  and .hex variants. Although it was previously possible to do this with the
  `/rest/block/BLOCKHASH.json` endpoint, the new endpoint improves the
  performance of external indexers by eliminating JSON serialization overhead. {% assign timestamp="2:13:29" %}

- [Bitcoin Core #32638][] adds validation to ensure that any block read from
  disk matches the expected block hash, catching bit rot and index mix-ups that
  could have gone unnoticed previously. Thanks to the header-hash cache
  introduced in [Bitcoin Core #32487][], this extra check is virtually
  overhead-free. {% assign timestamp="2:14:47" %}

- [Bitcoin Core #32819][] and [#32530][Bitcoin Core #32530] set the maximum
  values for the `-maxmempool` and `-dbcache` startup parameters to 500 MB and 1
  GB respectively, on 32-bit systems. Since this architecture has a total RAM
  limit of 4 GB, values higher than the new limits could cause out of memory
  (OOM) incidents. {% assign timestamp="2:15:25" %}

- [LDK #3618][] implements the client-side logic for [async payments][topic
  async payments], allowing an offline recipient node to prearrange [BOLT12
  offers][topic offers] and static invoices with an always-online helper LSP
  node. The PR introduces an async receive offer cache inside `ChannelManager`
  that builds, stores, and persists offers and invoices. It also defines the new
  onion messages and hooks needed to communicate with the LSP and threads the
  state machine through the `OffersMessageFlow`. {% assign timestamp="2:17:41" %}

{% include snippets/recap-ad.md when="2025-07-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32540,32638,32819,3618,1479,32487,32530" %}
[news255 presig vault state]: /en/newsletters/2023/06/14/#discussion-about-the-taproot-annex
[news348 ctvstep]: /en/newsletters/2025/04/04/#ctv-csfs-benefits
[news268 ptlc]: /en/newsletters/2023/09/13/#ln-messaging-changes-for-ptlcs
[news191 simple-ctv-vault]: /en/newsletters/2022/03/16/#continued-ctv-discussion
[news354 bitvm]: /en/newsletters/2025/05/16/#description-of-benefits-to-bitvm-from-op-ctv-and-op-csfs
[rubin lamport]: https://gnusha.org/pi/bitcoindev/CAD5xwhgzR8e5r1e4H-5EH2mSsE1V39dd06+TgYniFnXFSBqLxw@mail.gmail.com/
[osuntokun onion]: https://delvingbitcoin.org/t/reimagining-onion-messages-as-an-overlay-layer/1799/
[news283 oniondirect]: /en/newsletters/2024/01/03/#ldk-2723
[news304 onionreply]: /en/newsletters/2024/05/24/#core-lightning-7304
[sanders ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[provoost ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/80
[sanders ptlc2]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/81
[sanders gist]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[towns ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/82
[provoost ctvdesc]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/
[simple-ctv-vault]: https://github.com/jamesob/simple-ctv-vault
[ingala vaultdesc]: https://github.com/bitcoin/bips/pull/1793#issuecomment-2749295131
[kanjalkar vaultdesc1]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/3
[kanjalkar vaultdesc2]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/9
[towns ctvbitvm]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/8
[op_txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[stewart ctvimp]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/25
[obeirne letter]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a86c2737-db79-4f54-9c1d-51beeb765163n@googlegroups.com/
[sanders legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b17d0544-d292-4b4d-98c6-fa8dc4ef573cn@googlegroups.com/
[obeirne legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfKEgA0RCvxR=mP70sfvpzTphTZGidy=JuSK8f1WnM9xYA@mail.gmail.com/
[sanders p2ctv]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/72?u=harding
[lopp ctvvaults]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fxwKLdst9tYQqabUsJgu47xhCbwpmyq97ZB-SLWQC9Xw@mail.gmail.com/
[maxwell autodelete]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAAS2fgSmmDmEhi3y39MgQj+pKCbksMoVmV_SgQmqMOqfWY_QLg@mail.gmail.com/
[sanders ctvcom]: https://groups.google.com/g/bitcoindev/c/KJF6A55DPJ8/m/XVhyLCJiBQAJ
[towns ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEu8CqGH0lX5cBRD@erisian.com.au/
[poinsot ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/GLGZ3rEDfqaW8jAfIA6ac78uQzjEdYQaJf3ER9gd4e-wBXsiS2NK0wAj8LWK8VHf7w6Zru3IKbtDU5NM102jD8wMjjw8y7FmiDtQIy9U7Y4=@protonmail.com/
[provoost ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0B7CEBEE-FB2B-41CF-9347-B9C1C246B94D@sprovoost.nl/
[obeirne ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfLc5-=UVpcvYrC=VP7rLRroFviLTjPQfeqMQesjziL=CQ@mail.gmail.com/
[poelstra ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEsvtpiLWoDsfZrN@mail.wpsoftware.net/
[roose ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/035f8b9c-9711-4edb-9d01-bef4a96320e1@roose.io/
[goli ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/mc0q6r14.59407778-1eb1-4e57-bcf2-c781d6f70b01@we.are.superhuman.com/
[conduition winternitz]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uCSokD_EM3XBQBiVIEeju5mPOy2OU-TTAQaavyo0Zs8s2GhAdokhJXLFpcBpG9cKF03dNZfq2kqO-PpxXouSIHsDosjYhdBGkFArC5yIHU0=@proton.me/
[conduition impl]: https://gist.github.com/conduition/c6fd78e90c21f669fad7e3b5fe113182
[lamport signature]: https://en.wikipedia.org/wiki/Lamport_signature
[dryja fawkes]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cc2f8908-f6fa-45aa-93d7-6f926f9ba627n@googlegroups.com/
[news348 fawkes]: /en/newsletters/2025/04/04/#securely-proving-utxo-ownership-by-revealing-a-sha256-preimage
[roose txsighash]: https://delvingbitcoin.org/t/jit-fees-with-txhash-comparing-options-for-sponsorring-and-stacking/1760
[news295 sponsor]: /en/newsletters/2024/03/27/#transaction-fee-sponsorship-improvements
