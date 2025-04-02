---
title: 'Bitcoin Optech Newsletter #348'
permalink: /en/newsletters/2025/04/04/
name: 2025-04-04-newsletter
slug: 2025-04-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to an educational implementation of
elliptic curve cryptography for Bitcoin's secp256k1 curve.  Also
included are our regular sections with descriptions of discussions about
changing consensus, announcements of new releases and release
candidates, and summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Educational and experimental-based secp256k1 implementation:**
  Sebastian Falbesoner, Jonas Nick, and Tim Ruffing [posted][fnr secp]
  to the Bitcoin-Dev mailing list to announce a Python
  [implementation][secp256k1lab] of various functions related to the
  cryptography used in Bitcoin.  They warn that the implementation is
  "INSECURE" (caps in original) and "intended for prototyping,
  experimentation, and education."

  They also note that reference and test code for several BIPs
  ([340][bip340], [324][bip324], [327][bip327], and [352][bip352])
  already includes "custom and sometimes subtly diverging
  implementations of secp256k1."  They hope to improve this situation
  going forward, perhaps starting with an upcoming BIP for ChillDKG (see
  [Newsletter #312][news312 chilldkg]).

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Multiple discussions about quantum computer theft and resistance:**
  several conversations examined how Bitcoiners could respond to quantum
  computers becoming powerful enough to allow stealing bitcoins.

  - *Should vulnerable bitcoins be destroyed?* Jameson Lopp [posted][lopp
    destroy] to the Bitcoin-Dev mailing list several arguments for the
    destruction of bitcoins vulnerable to quantum theft after an upgrade
    path to [quantum resistance][topic quantum resistance] has been
    adopted and users have had time to adopt the solution.  Some
    arguments include:

    - *Argument from common preference:* he believes most people would
      prefer that their funds be destroyed rather than stolen by someone
      with a fast quantum computer.  Especially, he argues, since the
      thief will be among "the few privileged folks who gain
      early access to quantum computers".

    - *Argument from common harm:* many of the stolen bitcoins will be
      either lost coins or those that were planned to be held
      long-term.  By contrast, the thieves might quickly spend their
      stolen bitcoins, which reduces the purchasing power of other
      bitcoins (similar to money supply inflation).  He notes that lower
      purchasing power of bitcoins reduces miner income, reducing
      network security, and (in his observation) results in lower
      merchant acceptance of bitcoins.

    - *Argument from minimal benefit:* although allowing theft could be
      used to fund the development of quantum computing, stealing coins
      does not provide any direct benefit to honest participants in the
      Bitcoin protocol.

    - *Argument from clear deadlines:* nobody can know far in advance
      the date at which someone with a quantum computer can begin
      stealing bitcoins, but a specific date at which quantum-vulnerable
      coins will be destroyed can be announced far in advance with
      perfect precision.  That clear deadline will provide more
      incentive for users to re-secure their bitcoins in time, ensuring fewer total coins
      are lost.

    - *Argument from miner incentives:* as noted above, quantum theft
      would likely reduce miner income.  A persistent majority of
      hashrate can censor spending of quantum-vulnerable bitcoins, which
      they might do even if the rest of Bitcoiners prefer a different
      outcome.

    Lopp also provides several arguments against the destruction of
    vulnerable bitcoins, but he concludes in favor of destruction.

    Nagaev Boris [asks][boris timelock] whether UTXOs that are
    [timelocked][topic timelocks] beyond the upgrade deadline should
    also be destroyed.  Lopp notes existing pitfalls of long timelocks
    and says he personally gets "a bit nervous locking funds for more
    than a year or two."

  - *Securely proving UTXO ownership by revealing a SHA256 preimage:*
    Martin Habovštiak [posted][habovstiak gfsig] to the Bitcoin-Dev
    mailing list an idea that could allow someone to prove they
    controlled a UTXO even if ECDSA and [schnorr signatures][topic
    schnorr signatures] were insecure (e.g., after fast quantum
    computers existed).  If the UTXO contained a SHA256 commitment (or
    other quantum-resistant commitment) to a preimage that had never
    previously been revealed, then a multistep protocol for revealing
    that preimage could be combined with a consensus change to prevent quantum theft.  This is
    fundamentally the same as a [previous proposal][ruffing gfsig] by
    Tim Ruffing (see [Newsletter #141][news141 gfsig]), which he learned
    is generally known as the [Guy Fawkes signature scheme][].  It's
    also a variant of a [scheme][back crsig] Adam Back invented in 2013
    to improve resistance against miner censorship.  In short, the
    protocol could work like this:

    1. Alice receives funds to an output that, in some way, makes a
       SHA256 commitment.  This can be a directly hashed output, such as
       P2PKH, P2SH, P2WPKH, or P2WSH---or it can be [P2TR][topic
       taproot] output with a script path.

    2. If Alice receives multiple payments to the same output script,
       she must either not spend any of them until she's ready to spend
       all of them (definitely required for P2PKH and P2WPKH; probably
       also practically required for P2SH and P2WSH), or she's very
       careful to ensure at least one preimage remains unrevealed by her
       spending (easily possible with P2TR keypath versus scriptpath
       spends).

    3. When Alice is ready to spend, she privately creates her spending
       transaction normally but does not broadcast it.  She
       also obtains some bitcoin secured by a quantum-secure signature
       algorithm so that she can pay transaction fees.

    4. In a transaction spending some of the quantum-secure bitcoins,
       she commits to the
       quantum-insecure bitcoins she wants to spend
       and also commits to the private spending transaction (without
       revealing it).  She waits for this transaction to be deeply
       confirmed.

    5. After she's sure her previous transaction can't
       practically be reorged, she reveals her previously private
       preimage and quantum-insecure spend.

    6. Nodes on the network search the blockchain to find the first
       transaction that commits to the preimage.  If that transaction
       commits to Alice's quantum-insecure spend, then they execute her
       spend.  Otherwise, they do nothing.

    This ensures that Alice doesn't have to reveal quantum-vulnerable
    information until after she's already ensured her version of the
    spending transaction will take precedence over any attempted spend
    by the operator of a quantum computer.  For a more precise
    description of the protocol, please see [Ruffing's 2018
    post][ruffing gfsig].  Although not discussed in the thread, we
    believe the above protocol could be deployed as a soft fork.

    Habovštiak argues that bitcoins that can be securely spent using
    this protocol (e.g., their preimage hasn't already been revealed)
    should not be destroyed even if the community decides it wants to
    destroy quantum-vulnerable bitcoins in general.  He also argues that
    the ability to safely spend some bitcoins in case of emergency
    reduces the urgency of deploying a quantum-resistant scheme in the
    short term.

    Lloyd Fournier [says][fournier gfsig], "if this approach gains
    acceptance I think the main immediate action users can take is to
    move to a taproot wallet" because of its ability to allow keypath
    spending under the current consensus rules, including in the case of
    [address reuse][topic output linking], but also resistance to
    quantum theft if keypath spending is later disabled.

    In a separate thread (see next item), Pieter Wuille [notes][wuille
    nonpublic] that UTXOs vulnerable to quantum theft also include keys
    that have not been used publicly but which are known to multiple
    parties, such as in various forms of multisig (including LN,
    [DLCs][topic dlc], and escrow services).

  - *Draft BIP for destroying quantum-insecure bitcoins:* Agustin Cruz
    [posted][cruz qramp] to the Bitcoin-Dev mailing a [draft BIP][cruz
    bip] that describes several options for a general process of
    destroying bitcoins that are vulnerable to quantum theft (if
    that becomes an expected risk).  Cruz argues, "enforcing a
    deadline for migration, we provide rightful owners with a clear,
    non-negotiable opportunity to secure their funds [...] a forced
    migration, with sufficient notice and robust safeguards, is both
    realistic and necessary to protect the long-term security of
    Bitcoin."

    Very little of the discussion on the thread focused on the draft
    BIP.  Most of it focused on whether or not destroying
    quantum-vulnerable bitcoins was a good idea, similar to the thread later
    started by Jameson Lopp (described in a previous sub-item).

- **Multiple discussions about a CTV+CSFS soft fork:** several
  conversations examined various aspects of soft forking in the
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) and
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) opcodes.

  - *Criticism of CTV motivation:* Anthony Towns [posted][towns ctvmot]
    a criticism of [BIP119][]'s described motivation for CTV, a
    motivation which he argued would be undermined by adding both CTV
    and CSFS to Bitcoin.  Several days after the discussion started,
    BIP119 was updated by its author to remove most (and possibly all)
    of the controversial language; see [Newsletter #347][news347 bip119]
    for our summary of the change and the [older version][bip119
    prechange] of BIP119 for reference.  Some of the topics discussed
    included:

    - *CTV+CSFS allows the creation of a perpetual covenant:*
      CTV's motivation said, "Covenants have historically been widely
      considered to be unfit for Bitcoin because they are too complex to
      implement and risk reducing the fungibility of coins bound by
      them.  This BIP introduces a simple covenant called a *template*
      which enables a limited set of highly valuable use cases without
      significant risk.  BIP119 templates allow for **non-recursive**
      fully-enumerated covenants with no dynamic state" (emphasis in
      original).

      Towns describes a script using both CTV and CSFS, and links to a
      [transaction][mn recursive] using it on the MutinyNet [signet][topic
      signet], that can only be spent by sending the same amount of
      funds back to the script itself.  Although there was some debate
      about definitions, the author of CTV has [previously
      described][rubin recurse] a functionally identical construction as
      a recursive covenant and Optech followed that convention in its
      summary of that conversation (see [Newsletter #190][news190
      recursive]).

      Olaoluwa Osuntokun [defended][osuntokun enum] CTV's motivation
      related to scripts using it remaining "fully-enumerated" and "with
      no dynamic state".  This appears to be similar to an
      [argument][rubin enumeration] the author of CTV (Jeremy Rubin)
      made in 2022, where he called the type of pay-to-self covenant
      Towns designed "recursive but fully enumerated".  Towns
      [countered][towns enum] that adding CSFS undermines the
      claimed benefit of full enumeration.  He asked for either the CTV
      or CSFS BIPs to be updated to describe any "use cases that are
      somehow both scary and still prevented by the combination of CTV
      and CSFS".  This may have been [done][ctv spookchain] in the
      recent update to BIP119, which describes a "self-reproducing
      automata (colloquially called SpookChains)" that would be possible
      using [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] but which is
      not possible using CTV+CSFS.

    - *Tooling for CTV and CSFS:* Towns [noted][towns ctvmot] that he
      found it difficult to use existing tools to develop his recursive
      script described above, indicating a lack of readiness for
      deployment.  Osuntokun [said][osuntokun enum] the tooling he uses
      is "pretty straight forward".  Neither Towns nor Osuntokun
      mentioned what tools they used.  Nadav Ivgi [provided][ivgi minsc]
      an example using his [Minsc][] language and said that he's "been
      working on improving Minsc to make these kind of things easier.
      It supports Taproot, CTV, PSBT, Descriptors, Miniscript, raw
      Script, BIP32, and more." Although he admits "much of it is still
      undocumented".

    - *Alternatives:* Towns compares CTV+CSFS to both his Basic Bitcoin
      Lisp Language ([bll][topic bll]) and [Simplicity][topic
      simplicity], which would provide an alternative scripting
      language.  Antoine Poinsot [suggests][poinsot alt] that an
      alternative language that's easy to reason about may be less risky
      than a small change to the current system, which is hard to reason
      about.  Developer Moonsettler [argues][moonsettler express] that
      incrementally introducing new features to Bitcoin script makes it
      safer to add more features later, as each increase in expressivity
      makes it less likely that we'll encounter a surprise.

      Both Osuntokun and James O'Beirne [criticize][osuntokun enum] the
      [readiness][obeirne readiness] of bll and Simplicity in comparison
      to CTV and CSFS.

  - *CTV+CSFS benefits:* Steven Roose [posted][roose ctvcsfs] to Delving
    Bitcoin to suggest adding CTV and CSFS to Bitcoin as a first step to
    other changes that would increase expressivity further.  Most of the
    discussion focused on qualifying the possible benefits or CTV, CSFS,
    or both of them together.  This included:

    - *DLCs:* both CTV and CSFS individually can reduce the number of
      signatures needed to create [DLCs][topic dlc], especially DLCs for
      signing large numbers of variants of a contract (e.g., a BTC-USD
      price contract denominated in increments of one dollar).  Antoine
      Poinsot [linked][poinsot ctvcsfs1] to a recent
      [announcement][10101 shutdown] of a DLC service provider shutting
      down as evidence that Bitcoin users don't seem too interested in
      DLCs and linked to a [post][nick dlc] a few months ago from Jonas
      Nick that said, "DLCs have not achieved meaningful adoption on
      Bitcoin, and their limited use doesn't appear to stem from
      performance limitations." Replies linked to other still-functional
      DLC service providers, including one that [claims][lava 30m] to
      have raised "$30M in financing".

    - *Vaults:* CTV simplifies the implementation of [vaults][topic vaults]
      that are possible today on Bitcoin using presigned transactions
      and (optionally) private key deletion.  Anthony Towns [argues][towns
      vaults] that this type of vault isn't very interesting.  James O'Beirne
      [counters][obeirne ctv-vaults] that CTV, or something similar, is
      a prerequisite for building more advanced types of vaults, such as
      his [BIP345][] `OP_VAULT` vaults.

    - *Accountable computing contracts:* CSFS can eliminate many steps
      in [accountable computing contracts][topic acc] such as BitVM by
      replacing their current need to perform Script-based lamport
      signatures.  CTV may be able to reduce some additional signature
      operations.  Poinsot again [asks][poinsot ctvcsfs1] about whether
      there's significant demand for BitVM.  Gregory Sanders
      [replies][sanders bitvm] that he would find it interesting for
      bidirectional bridging of tokens as part of Shielded [client-side
      validation][topic client-side validation] (see [Newsletter
      #322][news322 csv-bitvm]).  However, he also notes that neither
      CTV nor CSFS significantly improve the trust model of BitVM,
      whereas other changes might be able to reduce trust or reduce the
      number of expensive operations in other ways.

    - *Improvement in Liquid timelock script:* James O'Beirne
      [relayed][obeirne liquid] comments from two Blockstream engineers
      that CTV would, in his words, "drastically improve the
      [Blockstream] Liquid timelock-fallback script that requires coins
      to be [moved] on a periodic basis."  After requests for
      clarification, former Blockstream engineer Sanket Kanjalkar
      [explained][kanjalkar liquid] that the benefit could be a
      significant savings in onchain transaction fees.  O'Beirne also [shared][poelstra
      liquid] additional details from Andrew Poelstra, Blockstream's
      Director of Research.

    - *LN-Symmetry:* CTV and CSFS together can be used to implement a
      form of [LN-Symmetry][topic eltoo], which eliminates some of the
      downsides of [LN-Penalty][topic ln-penalty] channels currently
      used in LN and may allow the creation of channels with more than
      two parties, which might improve liquidity management and onchain
      efficiency.  Gregory Sanders, who implemented an experimental
      version of LN-Symmetry (see [Newsletter #284][news284 lnsym])
      using [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO),
      [notes][sanders versus] that the CTV+CSFS version of LN-Symmetry
      isn't as featureful as the APO version and requires making
      tradeoffs.  Anthony Towns [adds][towns nonrepo] that nobody is
      known to have updated Sanders's experimental code for APO to run
      on modern software and use recently introduced relay features such
      as [TRUC][topic v3 transaction relay] and [ephemeral
      anchors][topic ephemeral anchors], much less has anyone ported the
      code to use CTV+CSFS, limiting our ability to evaluate that
      combination for LN-Symmetry.

      Poinsot [asks][poinsot ctvcsfs1] whether implementing LN-Symmetry
      would be a priority for LN developers if a soft fork
      made it possible.  Quotes from two Core Lightning
      developers (also co-authors of the paper introducing what we now
      call LN-Symmetry) indicated that it was a priority for them.  By
      comparison, LDK lead developer Matt Corallo [previously said][corallo
      eltoo], "I don't find [LN-Symmetry] all that interesting in terms
      of 'we need to get this done'".

    - *Ark:* Roose is the CEO of a business building an [Ark][topic ark]
      implementation.  He says, "CTV is a game-changer for Ark [...] the
      benefits of CTV to the user experience are undeniable, and it is
      without doubt that both [Ark] implementations will utilize CTV as
      soon as it is available."  Towns [noted][towns nonrepo] that
      nobody has implemented Ark with either APO or CTV for testing;
      Roose wrote [code][roose ctv-ark] doing that shortly thereafter,
      calling it "remarkably straightforward" and saying that it passed
      the existing implementation's integration tests.  He quantified
      some of the improvements: if they switched to CTV, "we could net
      remove about 900 lines of code [...] and reduce our own round
      protocol to [two] instead of three, [plus] the bandwidth
      improvement for not having to pass around signing nonces and
      partial signatures."

      Roose would later start a separate thread to discuss the
      benefits of CTV for users of Ark (see our summary below).

  - *Benefit of CTV to Ark users:* Steven Roose [posted][roose
    ctv-for-ark] to Delving Bitcoin a short description of the
    [Ark][topic ark] protocol currently deployed to [signet][topic
    signet], called [coventless Ark][clark doc] (clArk), and how the
    availability of the [OP_CHECKTEMPLATEVERIFY][topic
    op_checktemplateverify] (CTV) opcode could make a [covenant][topic
    covenants]-using version of the protocol more appealing to users when
    it's eventually deployed to mainnet.

    One design goal for Ark is to allow [async payments][topic async
    payments]: payments made when the receiver is offline.  In clArk,
    this is achieved by the spender plus an Ark server extending the
    spender's existing chain of presigned transactions, allowing the
    receiver to ultimately accept exclusive control over the funds.  The
    payment is called an Ark [out-of-round][oor doc] payment (_arkoor_).
    When the receiver comes online, they can choose what they want to
    do:

    - *Exit, after a delay:* broadcast the entire chain of presigned
      transactions, exiting the [joinpool][topic joinpools] (called an
      _Ark_).  This requires waiting for the expiry of a timelock agreed
      to by the spender.  When the presigned transactions are confirmed
      to a suitable depth, the receiver can be certain they have
      trustless control over the funds.  However, they lose the benefits
      of being part of a joinpool, such as rapid settlement and lower
      fees deriving from UTXO sharing.  They may also need to pay
      transaction fees to confirm the chain of transactions.

    - *Nothing:* in the normal case, a presigned transaction in the chain
      of transactions will eventually expire and allow the server to claim
      the funds.  This is not theft---it's an expected part of the
      protocol---and the server may choose to return some or all of the
      claimed funds to the user in some way.  Until the expiry approaches,
      the receiver can just wait.

      In the pathological case, the server and spender can (at any time)
      collude to sign an alternative chain of transactions to steal the
      funds sent to the receiver.  Note: Bitcoin's privacy properties
      allow both the server and the spender to be the same person, so
      collusion might not even be required.  However, if the receiver
      keeps a copy of the chain of transactions cosigned by the server,
      they can prove that the server stole funds, which might be
      sufficient to deter other people from using that server.

    - *Refresh:* with server cooperation, the receiver can atomically
      transfer ownership over the funds in the spender-cosigned
      transaction for another presigned transaction with the receiver as
      a cosigner.  This extends the expiration date and eliminates the
      ability for the server and previous spender to collude to steal the
      previously sent funds.  However, refreshing requires that the server
      hold on to the refreshed funds until they expire, reducing the
      server's liquidity, so the server charges the receiver an interest
      rate until expiration (paid upfront since the expiration time is
      fixed).

    Another design goal for Ark is to allow participants to receive LN
    payments.  In his original post and a [reply][roose ctv-ark-ln],
    Roose describes that existing participants who already have funds
    inside the joinpool can be penalized up to the cost of an onchain
    transaction if they fail to perform the interactivity required for
    receiving an LN payment.  However, those who don't already have
    funds in the joinpool can't be penalized, so they can refuse to
    perform the interactive steps and costlessly create problems for
    honest participants.  This appears to effectively prevent Ark users
    from receiving LN payments unless they already have a moderate
    amount of funds on deposit with the Ark server they want to use.

    Roose then describes how the availability of CTV would allow
    the protocol to be improved.  The main change is how Ark rounds are
    created.  An _Ark round_ consists of a small onchain transaction that
    commits to a tree of offchain transactions.  These are presigned
    transactions in the case of clArk, requiring all of the spenders in
    that round to be available for signing.  If CTV was available, each
    branch in the tree of transactions can commit to its descendants using
    CTV with no signing required.  This allows the creation of
    transactions even for participants who aren't available at the time
    the round is created, with the following benefits:

    - *In-round non-interactive payments:* instead of Ark out-of-round
      (arkoor) payments, a spender who is willing to wait for the next
      round can pay the receiver in-round.  For the receiver, this has a
      major advantage: as soon as the round confirms to a suitable depth,
      they receive trustless control over their received funds (until
      expiration approaches, at which time they can either exit or
      cheaply refresh).  Instead of waiting for several confirmations,
      the receiver can choose to immediately trust the incentives
      created by the Ark protocol for the server to operate honestly
      (see [Newsletter #253][news253 ark 0conf]).  In a separate point,
      Roose notes that these non-interactive payments can also be
      [batched][topic payment batching] to pay multiple receivers at
      once.

    - *In-round acceptance of LN payments:* a user could request an LN
      payment ([HTLC][topic htlc]) be sent to an Ark server, the server
      would then [hold][topic hold invoices] the payment until its next
      round, and it would use CTV to include an HTLC-locked payment to the
      user in the round---after which the user could disclose the HTLC
      preimage to claim the payment.  However, Roose noted that this
      would still require the use of "various anti-abuse measures" (we
      believe that this is because of the risk of the receiver failing
      to disclose the preimage, leading to the server's funds remaining
      locked until the end of the Ark round, which might extend for two
      or more months).

      David Harding [replied][harding ctv-ark-ln] to Roose asking for
      additional details and comparing the situation to LN [JIT
      channels][topic jit channels], which have a similar problem with
      non-revelation of HTLC preimages creating problems for Lightning
      Service Providers (LSPs).  LSPs currently address that problem
      through the introduction of trust-based mechanisms (see
      [Newsletter #256][news256 ln-jit]).  If the same solutions were
      planned to be used with CTV-Ark, those solutions would also seem
      to safely allow in-round acceptance of LN payments in clArk.

    - *Fewer rounds, fewer signatures, and less storage:* clArk uses
      [MuSig2][topic musig], and each party needs to participate in
      multiple rounds, generate multiple partial signatures, and store
      completed signatures.  With CTV, less data would need to be
      generated and stored and less interaction would be required.

- **OP_CHECKCONTRACTVERIFY semantics:** Salvatore Ingala
  [posted][ingala ccv] to Delving Bitcoin to describe the semantics of
  the proposed [OP_CHECKCONTRACTVERIFY][topic matt] (CCV) opcode, link
  to a [first draft BIP][ccv bip], and link to an [implementation
  draft][bitcoin core #32080] for Bitcoin Core.  His description starts
  with an overview of CCV's behavior: it allows checking that a public
  key commits to an arbitrary piece of data.  It can check both the
  public key of the [taproot][topic taproot] output being spent or the
  public key of a taproot output being created.  This can be used to
  ensure that data from the output being spent is carried over to the
  output being created.  In taproot, a tweak of the output can commit to
  tapleaves such [tapscripts][topic tapscript].  If the tweak commits to
  one or more tapscripts, it places an _encumbrance_ (spending
  condition) on the output, allowing conditions placed on the output
  being spent to be transferred to the output being created---commonly
  (but [controversially][towns anticov]) called a [covenant][topic
  covenants] in Bitcoin jargon.  The covenant may allow satisfaction or
  modification of the encumbrance, which would (respectively) terminate
  the covenant or modify its terms for future iterations.  Ingala
  describes some of the benefits and drawbacks of this approach:

  - *Benefits:* taproot native, doesn't increase the size of taproot
    entries in the UTXO set, and spending paths that don't require the
    extra data don't need to include it in their witness stack (so
    there's no extra cost in that case).

  - *Drawbacks:* only works with taproot and checking tweaks requires
    elliptic curve operations that are more expensive than (say)
    SHA256 operations.

  Only transferring the spending conditions from the output being spent
  to an output being can be useful, but many covenants will want to
  ensure some or all of the bitcoins in the output being spent are
  passed through to the output being created.  Ingala describes CCV's
  three options for handling values.

  - *Ignore:* don't check amounts.

  - *Deduct:* the amount of an output being created at a particular
    index (e.g., the third output) is deducted from the amount of the
    output being spent at the same index and the residual value is
    tracked.  For example, if the output being spent at index three is
    worth 100 BTC and the output being created at index three is worth
    70 BTC, then the code keeps track of the residual 30 BTC.  The
    transaction is marked as invalid if the output being created is
    greater than the output being spent (as that would reduce the
    residual value, perhaps below zero).

  - *Default:* mark the transaction invalid unless the amount of output
    being created at a particular index is greater than the amount of
    the output being spent plus the sum of any previous residuals that
    haven't been used with a _default_ check yet.

  A transaction is valid if any output is checked more than once with
  _deduct_ or if both _deduct_ and _default_ are used on the same
  output.

  Ingala provides several visual examples of combinations of the above
  operations.  Here's our textual description of his "send partial
  amount" example, which might be useful for a [vault][topic vaults]: a
  transaction has one input (spending one output) worth 100 BTC and two
  outputs, one for 70 BTC and the other for 30 BTC.  CCV is run twice
  during transaction validation:

  1. CCV with _deduct_ operates index 0 for 100 BTC spent to 70 BTC
     created, giving a residual of 30.  In a [BIP345][]-style vault, CCV
     would be returning that 70 BTC back to the same script it was
     previously secured by.

  2. The second time, it uses _default_ on index 1.  Although there's an
     output being created at index 1 in this transaction, there's no
     corresponding output being spent at index 1, so the implicit amount
     `0` is used.  To that zero is added the residual 30 BTC from the
     _deduct_ call on index 0, requiring this output being created equal
     30 BTC or greater.  In a BIP345-style vault, CCV would tweak the
     output script to allow spending this value to an arbitrary address
     after a [timelock][topic timelocks] expires or returning it to the
     user's main vault address at any time.

  Several alternative approaches that Ingala considered and discarded
  are discussed both in his post and the replies.  He writes, "I think
  the two amount behaviors (default and deduct) are very ergonomic, and
  cover the vast majority of the desirable amount checks in practice."

  He also notes that he "implemented fully featured vaults using
  `OP_CCV` plus [OP_CTV][topic op_checktemplateverify] that are roughly
  equivalent to [...[BIP345][]...]  Moreover, a reduced-functionality
  version using just `OP_CCV` is implemented as a functional test in the
  Bitcoin Core implementation of `OP_CCV`."

- **Draft BIP published for consensus cleanup:** Antoine Poinsot
  [posted][poinsot cleanup] to the Bitcoin-Dev mailing list a link to a
  [draft BIP][cleanup bip] he's written for the [consensus cleanup][topic
  consensus cleanup] soft fork proposal.  It includes several fixes:

  - Fixes for two different [time warp][topic time warp] attacks that
    could be used by a majority of hashrate to produce blocks at an
    accelerated rate.

  - A signature operations (sigops) execution limit on legacy
    transactions to prevent the creation of excessively slow-to-validate
    blocks.

  - A fix for [BIP34][] coinbase transaction uniqueness that should
    fully prevent [duplicate transactions][topic duplicate transactions].

  - Invalidation of future 64-byte transactions (calculated using
    stripped size) to prevent a type of [merkle tree
    vulnerability][topic merkle tree vulnerabilities].

  Technical replies were favorable for all but two parts of the
  proposal.  The first objection, made in several replies, was to the
  invalidation of 64-byte transactions.  The replies restated previous
  criticism (see [Newsletter #319][news319 64byte]).  An alternative
  method for addressing merkle tree vulnerabilities exists.  That method
  is relatively easy for lightweight (SPV) wallets to use but might
  present challenges to SPV validation in smart contracts, such as
  _bridges_ between Bitcoin and other systems.  Sjors Provoost
  [suggested][provoost bridge] someone implementing an
  onchain-enforceable bridge provide code illustrating the difference
  between being able to assume 64-byte transactions don't exist and
  having to use the alternative method for preventing merkle tree
  vulnerabilities.

  The second objection was about a late change to the ideas included in
  the BIP, which was described in a [post][poinsot nsequence] on Delving
  Bitcoin by Poinsot.  The change requires blocks made after
  activation of consensus cleanup to set the flag that makes
  their coinbase transaction locktime enforceable.  As previously proposed, coinbase
  transactions in post-activation blocks will set their locktime to
  their block height (minus 1).  This change means no miner can produce
  an alternative early Bitcoin block that uses both post-activation
  locktime and sets the enforcement flag (because, if they did, their
  coinbase transaction wouldn't be valid in the block that included it
  due to its use of a far-future locktime).   The inability to use
  exactly the same values in a past coinbase transaction as will be used
  in a future coinbase transaction prevents the duplicate transactions
  vulnerability.  The objection to this proposal was that it wasn't
  clear whether all miners are capable of setting the locktime
  enforcement flag.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BDK wallet 1.2.0][] adds flexibility for sending payments to custom
  scripts, fixes an edge case related to coinbase transactions, and
  includes several other features and bug fixes.

- [LDK v0.1.2][] is a release of this library for building LN-enabled
  applications.  It contains several performance improvements and bug
  fixes.

- [Bitcoin Core 29.0rc3][] is a release candidate for the next major
  version of the network's predominate full node.  Please see the
  [version 29 testing guide][bcc29 testing guide].

- [LND 0.19.0-beta.rc1][] is a release candidate for this popular LN
  node.  One of the major improvements that could probably use testing
  is the new RBF-based fee bumping for cooperative closes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31363][] cluster mempool: introduce TxGraph

- [Bitcoin Core #31278][] wallet, rpc: deprecate settxfee and paytxfee

- [Eclair #3050][] Relay non-blinded failure from wallet nodes

- [Eclair #2963][] Use package relay for anchor force-close

- [Eclair #3045][] Optional `payment_secret` in trampoline outer payload

- [LDK #3670][] Handle receiving payments via Trampoline

- [LND #9620][] chain: add testnet4 support

{% include snippets/recap-ad.md when="2025-04-08 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31363,31278,3050,2963,3045,3670,9620,32080" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[back crsig]: https://bitcointalk.org/index.php?topic=206303.msg2162962#msg2162962
[bip119 prechange]: https://github.com/bitcoin/bips/blob/9573e060e32f10446b6a2064a38bdc2047171d9c/bip-0119.mediawiki
[news75 ctv]: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv
[news190 recursive]: /en/newsletters/2022/03/09/#limiting-script-language-expressiveness
[modern ctv]: /en/newsletters/2019/12/18/#proposed-changes-to-bip-ctv
[rubin enumeration]: https://gnusha.org/pi/bitcoindev/CAD5xwhjj3JAXwnrgVe_7RKx0AVDDy4X-L9oOnwhswXAQFoJ7Bw@mail.gmail.com/
[towns ctvmot]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8eUQCfCWjdivIzn@erisian.com.au/
[mn recursive]: https://mutinynet.com/address/tb1p0p5027shf4gm79c4qx8pmafcsg2lf5jd33tznmyjejrmqqx525gsk5nr58
[rubin recurse]: https://gnusha.org/pi/bitcoindev/CAD5xwhjsVA7k7ZQ_QdrcZOxdi+L6L7dvqAj1Mhx+zmBA3DM5zw@mail.gmail.com/
[osuntokun enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-1H2s5Dso0z5CjKcHcPvQjG6PMMXvgkzLwXgCHWxNV_Q@mail.gmail.com/
[towns enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8tes4tXo53_DRpU@erisian.com.au/
[ctv spookchain]: https://github.com/bitcoin/bips/pull/1792/files#diff-aaa82c3decf53fb4312de88fbb3cc081da786b72387c9fec7bfb977ad3558b91R589-R593
[ivgi minsc]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAGXD5f3EGyUVBc=bDoNi_nXcKmW7M_-mUZ7LOeyCCab5Nqt69Q@mail.gmail.com/
[minsc]: https://min.sc/
[poinsot alt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1JkExwyWEPJ9wACzdWqiu5cQ5WVj33ex2XHa1J9Uyew-YF6CLppDrcu3Vogl54JUi1OBExtDnLoQhC6TYDH_73wmoxi1w2CwPoiNn2AcGeo=@protonmail.com/
[moonsettler express]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Gfgs0GeY513WBZ1FueJBVhdl2D-8QD2NqlBaP0RFGErYbHLE-dnFBN_rbxnTwzlolzpjlx0vo9YSgZpC013Lj4SI_WZR0N1iwbUiNze00tA=@protonmail.com/
[obeirne readiness]: https://mailing-list.bitcoindevs.xyz/bitcoindev/45ce340a-e5c9-4ce2-8ddc-5abfda3b1904n@googlegroups.com/
[nick dlc]: https://gist.github.com/jonasnick/e9627f56d04732ca83e94d448d4b5a51#dlcs
[lava 30m]: https://x.com/MarediaShehzan/status/1896593917631680835
[news322 csv-bitvm]: /en/newsletters/2024/09/27/#shielded-client-side-validation-csv
[news253 ark 0conf]: /en/newsletters/2023/05/31/#making-internal-transfers
[clark doc]: https://ark-protocol.org/intro/clark/index.html
[oor doc]: https://ark-protocol.org/intro/oor/index.html
[lopp destroy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_cF=UKVa7CitXReMq8nA_4RadCF==kU4YG+0GYN97P6hQ@mail.gmail.com/
[boris timelock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAFC_Vt54W1RR6GJSSg1tVsLi1=YHCQYiTNLxMj+vypMtTHcUBQ@mail.gmail.com/
[habovstiak gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJY=dv6cZ_HoUNQybF4-byGOjME3Jt2DRr20yZqMmdJUnQ@mail.gmail.com/
[news141 gfsig]: /en/newsletters/2021/03/24/#taproot-improvement-in-post-qc-recovery-at-no-onchain-cost
[guy fawkes signature scheme]: https://www.cl.cam.ac.uk/archive/rja14/Papers/fawkes.pdf
[fournier gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJYaLMciqYxNFa6qT6-WCsSD3P9pP7boYs=k0htAdnAR6g@mail.gmail.com/T/#ma2a9878dd4c63b520dc4f15cd51e51d31d323071
[wuille nonpublic]: https://mailing-list.bitcoindevs.xyz/bitcoindev/pXZj0cBHqBVPjkNPKBjiNE1BjPHhvRp-MwPaBsQu-s6RTEL9oBJearqZE33A2yz31LNRNUpZstq_q8YMN1VsCY2vByc9w4QyTOmIRCE3BFM=@wuille.net/T/#mfced9da4df93e56900a8e591d01d3b3abfa706ed
[cruz qramp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08a544fa-a29b-45c2-8303-8c5bde8598e7n@googlegroups.com/
[news347 bip119]: /en/newsletters/2025/03/28/#bips-1792
[roose ctvcsfs]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/
[poinsot ctvcsfs1]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/4
[10101 shutdown]: https://10101.finance/blog/10101-is-shutting-down
[towns vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[obeirne ctv-vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/23
[sanders bitvm]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[obeirne liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/24
[kanjalkar liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/28
[poelstra liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/32
[news284 lnsym]: /en/newsletters/2024/01/10/#ln-symmetry-research-implementation
[sanders versus]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[towns nonrepo]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[roose ctv-ark]: https://codeberg.org/ark-bitcoin/bark/src/branch/ctv
[roose ctv-for-ark]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/
[roose ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/5
[harding ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/8
[news256 ln-jit]: /en/newsletters/2023/06/21/#just-in-time-jit-channels
[ruffing gfsig]: https://gnusha.org/pi/bitcoindev/1518710367.3550.111.camel@mmci.uni-saarland.de/
[cruz bip]: https://github.com/chucrut/bips/blob/master/bip-xxxxx.md
[towns anticov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[ccv bip]: https://github.com/bitcoin/bips/pull/1793
[ingala ccv]: https://delvingbitcoin.org/t/op-checkcontractverify-and-its-amount-semantic/1527/
[news319 64byte]: /en/newsletters/2024/09/06/#mitigating-merkle-tree-vulnerabilities
[poinsot nsequence]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/79
[provoost bridge]: https://mailing-list.bitcoindevs.xyz/bitcoindev/19f6a854-674a-4e4d-9497-363af306e3a0@app.fastmail.com/
[poinsot cleanup]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uDAujRxk4oWnEGYX9lBD3e0V7a4V4Pd-c4-2QVybSZNcfJj5a6IbO6fCM_xEQEpBvQeOT8eIi1r91iKFIveeLIxfNMzDys77HUcbl7Zne4g=@protonmail.com/
[cleanup bip]: https://github.com/darosior/bips/blob/consensus_cleanup/bip-cc.md
[news312 chilldkg]: /en/newsletters/2024/07/19/#distributed-key-generation-protocol-for-frost
[fnr secp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d0044f9c-d974-43ca-9891-64bb60a90f1f@gmail.com/
[secp256k1lab]: https://github.com/secp256k1lab/secp256k1lab
[corallo eltoo]: https://x.com/TheBlueMatt/status/1857119394104500484
[bdk wallet 1.2.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.2.0
[ldk v0.1.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.2
