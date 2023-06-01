---
title: 'Bitcoin Optech Newsletter #129: 2020 Year-in-Review Special'
permalink: /en/newsletters/2020/12/23/
name: 2020-12-23-newsletter
slug: 2020-12-23-newsletter
type: newsletter
layout: newsletter
lang: en

excerpt: >
  This special edition of the Optech Newsletter summarizes notable
  developments in Bitcoin during all of 2020.
---
{{page.excerpt}} It's the sequel to our summaries from [2018][2018
summary] and [2019][2019 summary].

As we've done in our previous annual summaries, we must prefix what
you're about to read with an apology.  Many more people worked on both
maintaining and improving Bitcoin's technology than we could possibly
ever write about.  Their fundamental research, code review, bug fixes,
test writing, administrative work, and other thankless activities may
not be described here---but it is not unacknowledged.  If you contributed
to Bitcoin in 2020, please accept our deepest thanks.

## Contents

* January
  * [DLC specification, implementations, and usage](#dlc)
* February
  * [LN large channels](#large-channels)
  * [LN dual funding and interactive funding](#dual-interactive-funding)
  * [LN blinded paths](#blinded-paths)
* March
  * [Exfiltration resistant signing](#exfiltration-resistance)
* April
  * [Payjoin](#payjoin)
  * [LN PTLCs and other cryptography-based improvements](#ptlcs)
  * [BIP85 keychains](#bip85)
  * [Vaults](#vaults)
* May
  * [Transaction origin privacy](#transaction-origin-privacy)
  * [Succinct atomic swaps](#succinct-atomic-swaps-sas)
  * [Coinswap implementation](#coinswap-implementation)
  * [Compact block filters](#compact-block-filters)
* June
  * [Overpayment attack on multi-input segwit transactions](#overpayment-attack-on-multi-input-segwit-transactions)
  * [LN payment atomicity attack](#ln-payment-atomicity-attack)
  * [Fast LN eclipse attacks](#fast-ln-eclipse-attacks)
  * [LN fee ransom](#ln-fee-ransom)
  * [HTLC mining incentives](#concern-about-htlc-mining-incentives)
  * [Inventory out-of-memory denial-of-service attack](#inventory-out-of-memory-denial-of-service-attack-invdos)
  * [WabiSabi coordinated coinjoins with arbitrary output amounts](#wabisabi)
* July
  * [WTXID transaction announcements](#wtxid-announcements)
* August
  * [Signet](#signet)
  * [LN anchor outputs](#anchor-outputs)
* September
  * [Faster signature verification](#glv-endomorphism)
  * [Patent alliance](#patent-alliance)
* October
  * [LN jamming attacks](#jamming)
  * [LND security disclosures](#lnd-disclosures)
  * [Generic signmessage](#generic-signmessage)
  * [MuSig2](#musig2)
  * [Version 2 addr messages](#addrv2)
* November
  * [Lightning Pool incoming channel marketplace](#lightning-pool)
* December
  * [LN offers](#ln-offers)
* Featured summaries
    * [Taproot, tapscript, and schnorr signatures](#taproot)
    * [Major releases of popular infrastructure projects](#releases)
    * [Bitcoin Optech](#optech)

## January

{:#dlc}
Several developers began [working][news81 dlc] on a [specification][dlc
spec] for using [Discreet Log Contracts][] (DLCs) between different
software.  DLCs are a contract protocol where two or more parties agree
to exchange money dependent on the outcome of a certain event as
determined by an oracle (or several oracles). After the event happens,
the oracle publishes a commitment to the outcome of the event
that the winning party can use to claim
their funds.  The oracle doesn't need to know the terms of the contract
(or even that there is a contract). The contract can be made
indistinguishable from many other Bitcoin transactions or it can be
executed within an LN channel. This makes DLCs more private and
efficient than other known oracle-based contract methods, and it's
arguably more secure as an oracle that commits to a false
result generates clear evidence of fraud.  By the end of the year,
there would be four compatible implementations of DLCs, an
[application][crypto garage p2p deriv] for offering and accepting
DLC-based peer-to-peer derivatives, and several users [reporting][dlc
election bet] that they'd used DLCs in transactions on mainnet.

## February

{:#large-channels}
Five years after the [first public presentation about LN][dryja poon sf
devs], several early protocol decisions meant to be temporary were
revisited.   The most immediate change was the February [update][news86
bolts596] to the LN specification that allowed users to opt out of the
[maximum channel and payment value][topic large channels] limits enacted
in 2016.

{:#dual-interactive-funding}
Another early decision that saw reconsideration was keeping the protocol
simple by opening all channels with a single funder.  This minimizes
protocol complexity but prevents channel funders from receiving any
payments until they've spent some of their funds---a position that
creates barriers to merchants joining LN.  One proposal to eliminate
this problem is dual-funded channels where both the channel opener and
their counterparty commit some amount of funds to the channel.
Lisa Neigut has developed a [protocol][bolts #524] for dual funding, but
(as expected) it's complex.  In February, she started a
[discussion][news83 interactive funding] about an incremental
improvement over the existing single-funder standard that would allow
interactive construction of the funding transaction.  Instead of the
current case where one party proposes a channel open and the other party
either accepts it or rejects it, the nodes belonging to the two parties
could exchange information about their preferences and negotiate opening
a channel that they would both find desirable.

{:#blinded-paths}
New progress was also made on the often-discussed plans to allow
rendez-vous routing for LN, which was labeled a priority during the
[2018 LN specification meeting][rv routing].  A new method for achieving
equivalent privacy was [described][news85 blinded paths] by Bastien
Teinturier in February based on a previous privacy enhancement he had
proposed.  This new method, called *blinded paths*, was later
implemented as an experimental feature in [C-Lightning][news92
cl3600].

## March

{:#exfiltration-resistance}
One method hardware wallets could use to steal bitcoins from their users is by
leaking information about the wallet's private keys via the transaction
signatures it creates.  In March, [Stepan Snigirev][news87 exfiltration],
[Pieter Wuille][news88 exfiltration], and several others discussed
possible solutions to this problem for both Bitcoin's current ECDSA
signature system and the proposed [schnorr signature][topic schnorr signatures] system.

<div markdown="1" class="callout" id="taproot">
### 2020 summary<br>Taproot, tapscript, and schnorr signatures

Nearly every month of 2020 saw some notable development related to the
proposed [taproot][topic taproot] soft fork ([BIP341][]) which also adds
support for [schnorr signatures][topic schnorr signatures] ([BIP340][])
and [tapscript][topic tapscript] ([BIP342][]).  Together, these
improvements will allow users of single-signature scripts,
multisignature scripts, and complex contracts to all use
identical-appearing commitments that enhance their privacy and the
fungibility of all bitcoins.  Spenders will enjoy lower fees and the
ability to resolve many multisig scripts and complex contracts with the
same efficiency, low fees, and large anonymity set as single-sig users.
Taproot and schnorr also lay the groundwork for future potential
upgrades that may improve efficiency, privacy, and fungibility further,
such as signature aggregation, [SIGHASH_ANYPREVOUT][topic
sighash_anyprevout], and [scripting language changes][topic simplicity].

This special section concentrates the summaries about those developments
into a single narrative that we hope will be easier to follow than
describing each event separately in the month it occurred.

{:#activation-mechanisms}
January started with a discussion of soft fork activation mechanisms,
with Matt Corallo [proposing][news80 msfa] a careful and patient
approach to addressing disagreements between different sets of
stakeholders.  Other developers focused on the [BIP8][] proposal to be
able to quickly bypass the type of procedural problem that delayed
segwit activation in 2016 and 2017.  The discussion about what precise
activation mechanism to use would continue all year, in a [dedicated IRC
channel][##taproot-activation] and elsewhere, with there being both a
[developer survey][news122 devsurvey] about mechanism design and a
[survey of miners][news125 miner survey] about their support for
taproot.

February saw the first of several updates during the year to the
algorithms used to derive public keys and signatures in the BIP340
specification of schnorr signatures.  [Most][news83 alt tiebreaker] of
these [changes][news87 bip340 update] were [small][news111 uniform
tiebreaker] optimizations [discovered][news96 bip340 update] from
[experience][news113 bip340 update] implementing and testing the
proposal in [libsecp256k1][] and its experimental fork
[libsecp256k1-zkp][].  Also in February, Lloyd Fournier
[extended][news87 taproot generic group] Andrew Poelstra's previous
security proof for taproot.

In March, Bitcoin Core carefully [changed][news89 op_if] its consensus
code---without introducing a fork---to remove an inefficiency in the
parsing of `OP_IF` and related flow control opcodes.   Currently, the
inefficiency can't be exploited to cause problems, but the extended
capabilities proposed for tapscript would have made it possible for an
attacker to use the inefficiency to create blocks that could take a
large amount of computation to verify.

Although much of the public attention on taproot focuses on its change
to Bitcoin's consensus rules, taproot won't be a positive contribution unless
wallet developers can use it safely.  In April, and throughout the year,
[several][news87 bip340 update1] updates to BIP340 [changed][news87
bip340 update] the [recommendations][news91 bip340 powerdiff] for
[how][news96 bip340 nonce update] developers should generate public keys
and the signature nonce.  The changes are probably only directly
interesting to cryptographers, but the history of Bitcoin has many
examples of people losing money because a wallet developer didn't fully
understand the cryptographic protocol they implemented.  Hopefully, the
recommendations from experienced cryptographers in BIP340 will help
avoid some of those types of problems in the future.

In May, there was [renewed discussion][news97 additional commitment] about
the blinded ownership attack that makes it
dangerous to automatically sign transactions with a hardware wallet.
Ideally, hardware wallets could provide a mode where they'd automatically
sign transactions guaranteed to increase the wallet's balance, such as
maker coinjoins and LN [splices][topic splicing].  Unfortunately, it's
only safe to sign a transaction if you know for sure which inputs are
yours---otherwise an attacker can get you to sign a transaction that
looks like it only has one of your inputs, then get you to sign a
different version of the same transaction that also looks like it only
has one of your inputs (a different input than the first version), and
finally combine the signatures for the two different inputs into the
actual transaction that pays your money to the attacker.  This
isn't normally a risk because most people today only use hardware
wallets to sign transactions where they own 100% of the inputs, but for
coinjoins, LN splices, and other protocols, it's expected that other users
may partly or fully control some of the inputs.  It was proposed that
taproot provide an additional way to commit to inputs that can be used
in conjunction with data provided in a [PSBT][topic psbt] to ensure a
hardware wallet will only generate a valid signature when it has enough
data to identify all of its inputs.  This proposal was later
[accepted][news101 additional commitment] into BIP341.

![Illustration of using a fake coinjoin to trick a hardware wallet into losing funds](/img/posts/2020-05-fake-coinjoin-trick-hardware-wallet.dot.png)

In July, another discussion resumed about a previously known problem---the
[bech32 address format][topic bech32] being less effective than
expected at preventing users from sending money to unspendable
addresses.  This doesn't practically affect current bech32 address
users, but it could be an issue for planned taproot addresses where the
addition or removal of a small number of characters could lead to the
loss of funds.  Last year it was proposed to simply extend the
protection current segwit v0 addresses have to segwit v1 (taproot)
addresses, but that would reduce the flexibility of future upgrades.
[This year][news107 bech32 fives], after more [research][news127 bech32m
research] and [debate][news119 bech32 discussion], there seemed to be
agreement among developers that taproot and future segwit-based script
upgrades should use a new address format that's a slight tweak on the
original [BIP173][] bech32 addresses.  The new format will resolve the
deficiency and provide some other nice properties.

In September, the code implementing schnorr signature verification and
single-party signing functions from [BIP340][] was [merged][news115
bip340 merge] into libsecp256k1 and soon became part of Bitcoin
Core.  This allowed the subsequent October [merge][news120 taproot
merge] of the verification code for taproot, schnorr, and tapscript.
The code consists of about 700 lines of consensus-related changes (500
excluding comments and whitespace) and 2,100 lines of tests. Over 30
people directly reviewed this PR and related changes, and many others
participated in developing and reviewing the underlying research, the
BIPs, the related code in libsecp256k1, and other parts of the system.
The new soft fork rules are currently only used in [signet][topic signet] and Bitcoin Core's
private test mode ("regtest"); they need to be activated before they can
be used on Bitcoin's mainnet.

Many of the contributors to taproot spent the remainder of the year
focusing on the 0.21.0 release of Bitcoin Core with the intention that a
subsequent minor release, possibly 0.21.1, will contain code that can
begin enforcement of taproot's rules when an appropriate activation
signal is received.

</div>

## April

{:#payjoin}
The [payjoin][topic payjoin] protocol based on the 2018 [Pay-to-EndPoint
proposal][news8 p2ep] received a major boost in April when a version of
it was [added][news94 btcpay payjoin] to the BTCPay self-hosted payment
processing system.  Payjoin provides a convenient way for users to
increase their privacy and the privacy of other users on the network by
creating transactions that undermine the [assumption][common ownership heuristic] that the same person
owns all of the inputs in a transaction.  The BTCPay version of payjoin
would soon be [specified][news104 bips923] as [BIP78][] and support for
it was added to [other programs][news116 payjoin joinmarket].

{:#ptlcs}
One widely desired improvement to LN is switching the payment security
mechanism from Hash Time Locked Contracts ([HTLCs][topic htlc]) to Point
Time Locked Contracts ([PTLCs][topic ptlc]) that improve the privacy of
spenders and receivers against a variety of surveillance methods.  One
complication is that the ideal multiparty PTLC construction is
challenging to implement using Bitcoin's existing [ECDSA signature
scheme][ecdsa] (although it'd be easier with [schnorr signatures][topic
schnorr signatures]).  Early in the year, Lloyd Fournier circulated a
[paper][fournier otves] analyzing [signature adaptors][topic adaptor
signatures] by disentangling their core locking and information exchange
properties from their use of multiparty signatures, describing an easy
way to use plain Bitcoin Script-based multisig instead.  During an April
hackathon, several developers [produced][news92 ecdsa adaptor] a rough
implementation of this protocol for a fork of the popular libsecp256k1
library.  Later, in September, Fournier would further advance the
practicality of PTLCs without needing to wait for changes to Bitcoin by
proposing a [different way][news113 witasym] to [construct][news119
witasym update] LN commitment transactions.  In December, he would
propose [two new ways][news128 fancy static] to improve the robustness
of LN backups, again offering practical solutions to user problems
through the clever use of cryptography.

{:#bip85}
April also saw Ethan Kosakovsky [post][news93 super keychain] a proposal
to the Bitcoin-Dev mailing list for using one [BIP32][] Hierarchical
Deterministic (HD) keychain to create seeds for child HD keychains that
can be used in different contexts.  This may address the problem that
many wallets don't implement the ability to import extended private keys
(xprvs)---they only allow importing either an HD seed or some precursor
data that is transformed into the seed (e.g. [BIP39][] or SLIP39 seed
words).  The proposal allows a user with multiple wallets to backup all
of them using just the super-keychain's seed.  This proposal would
[later][news102 bip85] become [BIP85][] and would be implemented in
recent versions of the ColdCard hardware wallet.

{:#vaults}
Two announcements about [vaults][topic vaults] were made in April.  Vaults
are a type of contract known as a [covenant][topic covenants] that produces a warning
when someone is trying to spend the covenant's funds, giving
the covenant's owner time to block a spend they didn't authorize.  Bryan Bishop announced a [prototype
vault][news94 bishop vault] based on his [proposal][news59 bishop idea]
from last year.  Kevin Loaec and Antoine Poinsot announced their own
project, [Revault][news95 revault], that [focuses][news100 revault arch]
on using the vault model to store funds shared between multiple users
with multisig security.  Jeremy Rubin also announced a [new high level
programming language][news109 sapio] designed for building stateful
smart contracts with the proposed [OP_CHECKTEMPLATEVERIFY][topic
op_checktemplateverify] opcode, which could make it easier to create and
manage vaults.

## May

{:#transaction-origin-privacy}
The Bitcoin Core project merged several PRs in May and the following
months that improved [transaction origin privacy][tx origin wiki], both
for users of the Bitcoin Core wallet and for users of other systems.
[Bitcoin Core #18038][] began [tracking][news96 bcc18038] whether at
least one peer had accepted a locally-generated transaction, allowing
the wallet to significantly reduce the frequency Bitcoin Core used to
rebroadcast its own transactions and making it harder for surveillance
nodes to identify which node originated the transaction.  PRs
[#18861][Bitcoin Core #18861] and [#19109][Bitcoin Core #19109] were
able to [block a type of active scanning][news99 bcc18861] by
surveillance nodes by [only replying to requests][news107 bcc19109] for
a transaction from peers the node told about the transaction, further
reducing the ability of third parties to determine which node first
broadcast a transaction.  PRs [#14582][Bitcoin Core #14582] and
[#19743][Bitcoin Core #19743] allow the wallet to [automatically
try][news112 bcc14582] to eliminate [address reuse][topic output
linking] links when it wouldn't cost the user any extra fees (or, alternatively,
allowing the user to specify the maximum extra they're willing to spend
in order to eliminate such links).

Late May and early June saw two significant developments in coinswaps.
Coinswap is a trustless protocol that allows two or more users to create
transactions that look like regular payments but which actually swap
their coins with each other. This improves the privacy of not just the
coinswap users but all Bitcoin users, as anything that looks like a
payment could have instead been a coinswap.

- **Succinct Atomic Swaps (SAS):** Ruben Somsen wrote a post and created
  a video describing a [procedure][news98 sas] for a trustless exchange
  of coins using only two transactions.  The protocol has several
  advantages over earlier coinswap designs: it requires less block space, it
  saves on transaction fees, it only requires consensus-enforced
  timelocks on one of the chains in a cross-chain swap, and it doesn't
  depend on any new security assumptions or Bitcoin consensus changes.
  If taproot is adopted, swaps can be made even more privately and
  efficiently.

- **Coinswap implementation:** Chris Belcher [posted][belcher coinswap1]
  a design for a full-featured coinswap implementation.  His [initial
  post][coinswap design] included the history of the coinswap idea,
  suggested ways the multisig conditions needed for coinswap could be
  disguised as more common transaction types, proposed using a market
  for liquidity (like JoinMarket already does), described splitting and
  routing techniques to reduce privacy losses from amount correlation or
  spying participants, suggested combining coinswap with [payjoin][topic
  payjoin], and discussed some of the backend requirements for the
  system.  Additionally, he compared coinswap to other privacy
  techniques such as using LN, [coinjoin][topic coinjoin], payjoin, and
  payswap.  The proposal received a [significant amount][belcher
  coinswap2] of [expert discussion][belcher coinswap3] and a number of
  suggestions were integrated into the protocol.  By December, Belcher's
  prototype software was [creating coinswaps][belcher dec8 tweet] on
  testnet that demonstrated their strong lack of linkability.

{:#compact-block-filters}
Since Bitcoin's early days, one of the challenges of developing
lightweight clients with SPV security has been finding a way for the
client to download transactions affecting its wallet without giving the
third party server providing the transactions the ability to track the
wallet's receiving and spending history.  An initial attempt at this was
[BIP37][]-style [bloom filters][topic transaction bloom filtering], but
the way wallets used them ended up providing only [minimal privacy][nick
filter privacy] and created [denial of service risks][bitcoin core
#16152] for the full nodes that served them.  An anonymous developer
posted to the Bitcoin-Dev mailing list in May 2016 suggesting an
alternative construction of a [single bloom filter per block][bfd post]
that all wallets could use.  The idea was quickly [refined][maxwell
gcs], [implemented][neutrino], and [specified][bip157 spec discussion],
becoming the [BIP157][] and [BIP158][] specifications of [compact block
filters][topic compact block filters].  This can significantly improve
the privacy of lightweight clients, although it does increase their
bandwidth, CPU, and memory requirements compared to current popular
methods.  For full nodes, it reduces the DoS risk to that of a simple
bandwidth exhaustion attack, which nodes can already address with
bandwidth throttling options.  Although merged on the server side in
[btcd][btcd #1180] in 2018 and proposed for Bitcoin Core around the same
time, 2020 saw the P2P part of the protocol merged [piecewise][news98
bcc18877] into Bitcoin Core in [May][news100 bcc19010] through
[August][news111 bcc19070], culminating with the ability for a node
operator to opt in to creating and serving compact block filters by
enabling just two configuration options.

<div markdown="1" class="callout" id="releases">
### 2020 summary<br>Major releases of popular infrastructure projects

- [LND 0.9.0-beta][] released in January improved the access control list
  mechanism (“macaroons”), added support for receiving [multipath
  payments][topic multipath payments], added the ability to send
  additional data in an encrypted onion message, and allowed requesting
  channel close outputs pay a specified address (e.g. your hardware
  wallet).

- [LND 0.10.0-beta][] released in May added support for sending
  multipath payments, allowed funding channels using an external wallet
  via [PSBTs][topic psbt], and began supporting the creation of invoices
  [larger][topic large channels] than 0.043 BTC.

- [Eclair 0.4][] released in May added compatibility with the
  latest version of Bitcoin Core and deprecated the Eclair Node GUI
  (referring users to instead to Phoenix or Eclair Mobile).

- [Bitcoin Core 0.20.0][] released in June began defaulting to bech32
  addresses for RPC users, allowed configuring RPC permissions for
  different users and applications, and added some basic support for
  generating PSBTs in the GUI.

- [C-Lightning 0.9.0][] released in August provided an updated `pay`
  command and an RPC for sending messages over LN.

- [LND 0.11.0-beta][] released in August allowed accepting [large
  channels][topic large channels].

</div>

## June

June was an especially active month for the discovery and discussion of
vulnerabilities, although many problems were discovered earlier or fully
disclosed later.  The notable vulnerabilities included:

- [Overpayment attack on multi-input segwit transactions:][attack overpay segwit]
  in June, Trezor announced Saleem Rashid had discovered a weakness in
  segwit's ability to prevent fee overpayment attacks.  Fee overpayment
  attacks are a well known weakness in Bitcoin's original transaction
  format where signatures don't commit to the value of an input,
  allowing an attacker to trick a dedicated signing device (such as a
  hardware wallet) into spending more money than expected.  Segwit tried
  to eliminate this issue by having each signature commit to the amount
  of the input it spent.  However, Rashid re-discovered a problem
  previously discovered and reported by Gregory Sanders in 2017 where a specially
  constructed transaction with at least two inputs can get around this
  limitation if the user can be tricked into signing two or more
  seemingly identical variations of the same transaction.  Several
  developers felt this was a minor issue---if you can get a user to sign
  twice, you can get them to pay the receiver twice, which also loses
  their money.  Despite that, several hardware wallet manufacturers
  released new firmware that implemented the same protection for segwit
  transactions that they've successfully used to prevent fee
  overpayments in legacy transactions.  In some cases, such as in the
  ColdCard wallet, this security improvement was implemented
  non-disruptively.  In other hardware wallets, the implementation broke
  support with existing workflows, forcing updates to the [BIP174][]
  specification of PSBT and software such as Electrum, Bitcoin Core, and
  HWI.

    ![Fee overpayment attack illustration](/img/posts/2020-06-fee-overpayment-attack.dot.png)

- [LN payment atomicity attack:][attack ln atomicity] as LN developers
  worked to implement the [anchor outputs][topic anchor outputs]
  protocol to eliminate risks related to rapid rises in transaction
  feerates, one of the key contributors to that protocol---Matt
  Corallo---discovered it would enable a new vulnerability.  A malicious
  counterparty could attempt to settle an LN payment ([HTLC][topic
  htlc]) using a low feerate and a [transaction pinning][topic
  transaction pinning] technique that prevents the transaction or a fee
  bump of it from being confirmed quickly.  The delayed confirmation
  causes the HTLC's timeout to expire, allowing the attacker to steal
  back funds they paid to the honest counterparty.  Several solutions
  were [proposed][atomicity attack discussion], from changes to the LN
  protocol, to third-party markets, to [soft fork consensus
  changes][rubin fee sponsorship], but no solution has yet gained any
  significant traction.

- [Fast LN eclipse attacks:][attack time dilation] although Bitcoin
  protocol experts from Satoshi Nakamoto to present have been aware that
  a node isolated from any honest peer can be deceived into accepting
  unspendable bitcoins, a category of problems sometimes called [eclipse
  attacks][topic eclipse attacks], Gleb Naumenko and Antoine Riard
  published a paper in June showing that eclipse attacks could steal
  from LN nodes in as little as two hours---although it would take
  longer to steal from LN nodes that were connected to their own full
  verification nodes.
  The authors suggest the implementation of more methods for avoiding
  eclipse attacks, which did see several positive developments in the
  Bitcoin Core project this year.

- [LN fee ransom:][attack ln fee ransom] René Pickhardt publicly
  disclosed a vulnerability to the Lightning-Dev mailing list that he
  had previously privately reported to LN implementation maintainers
  almost a year earlier.  A malicious channel counterparty can initiate
  up to 483 payments (HTLCs) in an LN channel and then close the
  channel, producing an onchain transaction whose size is about 2% of an
  entire block and which needs to have its transaction fee paid by the
  honest node.  Simple mitigations for this attack were implemented in
  several LN nodes and the use of [anchor outputs][topic anchor outputs]
  is also expected to help, but no comprehensive solution has yet been
  proposed.

- [Concern about HTLC mining incentives:][attack htlc incentives] two
  papers about out-of-band HTLC bribes were discussed in late June and
  early July.  [HTLCs][topic htlc] are contracts used to secure LN
  payments, cross-chain atomic swaps, and several other trustless
  exchange protocols.  They work by giving a receiving user a period of
  time where they have the exclusive ability to claim a payment by
  releasing a secret data string; after the time expires, the spending
  user can take back the payment.  The papers examined the risk that
  the spending user could bribe miners to release the secret data but
  not confirm the transaction containing it, allowing the timelock to
  expire so that the spender would get their money back but still learn
  the secret.  Developer [[ZmnSCPxj]] reminded the researchers of a
  well known mechanism that should prevent such problems, a mechanism he
  helped [implement][cl3870] in C-Lightning.  Although the idea
  works in theory, using it will cost users money, so research into
  better solutions is still encouraged.

- [Inventory out-of-memory Denial-of-Service attack (InvDoS):][attack invdos]
  an attack originally discovered in 2018 that affected the Bcoin and
  Bitcoin Core full nodes, which was responsibly disclosed
  and fixed at that time, was reevaluated in June 2020 and found to also
  apply to the Btcd full node.  An attacker could flood a victim's node
  with an excessive number of new transaction announcements (`inv`
  messages), each containing nearly the maximum allowed number of
  transaction hashes. When too many of these announcements were queued,
  the victim's node would run out of memory and crash.  After Btcd fixed
  the problem and users were given time to upgrade, the vulnerability
  was publicly disclosed.

{:#wabisabi}
June also had some good news, with a team of researchers working on the
Wasabi coinjoin implementation [announcing][news102 wasabi] a protocol
named WabiSabi that should allow
trustless server-coordinated coinjoins with arbitrary output values.
This makes it easier to use coordinated coinjoins to send payments,
either between participants in the coinjoin or to non-participants.
Wasabi developers worked on implementing the protocol during the
remainder of the year.

## July

{:#wtxid-announcements}
July saw the [merge][bips933] of the [BIP339][] specification for wtxid
transaction announcements.  Nodes have historically announced the
availability of new unconfirmed transactions for relay using the
transaction's hash-based identifier (txid), but when the proposed segwit
code was being reviewed in 2016, Peter Todd [discovered][todd segwit
review] that a malicious node could get other nodes on the network to
ignore an innocent user's transaction by invalidating witness data in the transaction
that is not part of its txid.  A [quick
fix][Bitcoin Core #8312] was implemented at the time, but it had some
minor downsides and developers knew that the best solution---despite its
[complexities][bcc19569]---was to announce new transactions using their
witness txid (wtxid).  Within a month of BIP339 being added to the BIPs
repository, wtxid announcements were [merged][bcc18044] into Bitcoin
Core.  Although seemingly a minor concern without any obvious effect on
users, wtxid announcements simplify the development of
hoped-for upgrades, such as [package relay][topic package relay].

## August

{:#signet}
After [over][bips900] a [year][bips983] of [development][default signet
discussion], including multiple feedback-driven changes, the [last
major revision][bips947] to the [BIP325][] specification of
[signet][topic signet] was merged in early August.  Signet is a protocol
that allows developers to create public test networks and also the name
of the primary public signet.  Unlike Bitcoin's existing public test
network (testnet), signet blocks must be signed by a trusted party.
This prevents vandalism and other problems that occur because testnet
uses Bitcoin's economic-based consensus convergence mechanism (proof of
work) even though testnet coins have no value.  The ability to
optionally enable signet was finally [added][bcc18267] to Bitcoin Core
in September.

{:#anchor-outputs}
Almost two years after Matt Corallo [first proposed][news24 cpfp carve
out] the [CPFP carve-out mechanism][topic cpfp carve out], the LN
specification was [updated][news112 bolts688] to allow the creation of
[anchor outputs][topic anchor outputs] that use carve outs for security.
Anchor outputs allow a multiparty transaction to be fee bumped even if
one of the parties attempts to use a [transaction pinning][topic
transaction pinning] attack to prevent fee bumps.  The ability to fee
bump transactions even under adversarial conditions allows LN nodes to
accept offchain transactions without worrying about feerates increasing in
the future.  If it later becomes necessary to broadcast that offchain
transaction, the node can choose an appropriate feerate for it at
broadcast time.  This simplifies the LN protocol and improves several
aspects of its security.

<div markdown="1" class="callout" id="optech">
### 2020 summary<br>Bitcoin Optech

In Optech's third year, 10 new member companies joined<!-- Veriphi,
SwanBitcoin, YellowCardIO, Xbtogroup, Bitonic, Fidelity Center for
Applied Technology, AndgoInc, BTSEcom, EdgeWallet, Bitbank_inc -->, we
held a [taproot workshop][] in London,
published 51 weekly newsletters<!-- 78 to 129 -->, added 20 new pages to
our [topics index][], added several new wallets and services to our
[compatibility index][], and published several contributed [blog
posts][optech blog posts] about Bitcoin scaling technology.
</div>

## September

{:#glv-endomorphism}
In a [2011 forum post][finney glv], early Bitcoin contributor Hal Finney
described a method by Gallant, Lambert, and Vanstone (GLV) to reduce the
number of expensive computations needed to verify Bitcoin transaction
signatures. Finney wrote a proof-of-concept implementation, which he
claimed sped up signature verification by around 25%.  Unfortunately,
the algorithm was encumbered by [U.S.  Patent 7,110,538][] and so
neither Finney's implementation nor a later implementation by Pieter
Wuille was distributed to users.  On September 25th, [that patent
expired][news117 patent].  Within a month, the code was [merged][news120
glv] into Bitcoin Core.  For users with the default settings, the speed
improvement will be most apparent during the final part of syncing a new
node or when verifying blocks after a node has been offline for a while.
Finney died in 2014, but we remain grateful for his two decades of work
on making cryptographic technology widely accessible.

{:#patent-alliance}
Square [announced][copa announced] the formation of the Cryptocurrency Open Patent Alliance (COPA) to
coordinate the pooling of patents related to cryptocurrency technology.
Members allow anyone to use their patents freely and, in exchange,
receive the ability to use patents in the pool in defense against patent
aggressors.  As of this writing, the alliance had [18 members][copa
membership]: ARK.io, Bithyve, Blockchain Commons, Blockstack,
Blockstream, Carnes Validadas, Cloudeya Ltd., Coinbase, Foundation
Devices, Horizontal Systems, Kraken, Mercury Cash, Protocol Labs,
Request Network, SatoshiLabs, Square, Transparent Systems, and
VerifyChain.

## October

{:#jamming}
October saw a significant increase in discussion among LN developers
about solving the jamming problem [first described in 2015][russell loop], as well
as related problems.  An LN node can route a payment to itself across a
path of 20 or more hops.  This allows an attacker with 1 BTC to
temporarily lock up 20 BTC or more belonging to other users.  After
several hours of locking other users' money, the attacker can cancel the
payment and receive a complete refund on their fees, making the attack
essentially free.  A related problem is an attacker sending 483 small
payments through a series of channels, where 483 is the maximum number
of pending payments a channel may contain.  In this case, an attacker
with two channels, each with 483 slots, can jam over 10,000 honest
connection slots---again without paying any fees.  A [variety][news120
upfront] of possible solutions were discussed, including *forward upfront
fees* paid from the spender to each node along the path, [backwards
upfront fees][news86 backwards upfront] paid from each payment hop to
the previous hop, a [combination][news122 bidir fees] of both forward
and backwards fees, [nested incremental routing][news119 nested
routing], and [fidelity bonds][news126 routing fibonds].  Unfortunately,
none of the methods discussed received widespread acceptance and so the
problem remains unsolved.

{:.center}
![Illustration of LN liquidity and HTLC jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

{:#lnd-disclosures}
Two money-stealing attacks against LND that were discovered and reported
by Antoine Riard in April were [fully disclosed][news121 riard
disclosures] in October.  In one case, LND could be tricked into
accepting invalid data; in the other case, it could be tricked into
disclosing secret data.  Thanks to Riard's responsible disclosure and
the LND team's response, we are unaware of any users who lost funds.
The LN specification was [updated][news123 high-s] for [both][news124
htlc release] problems to help new implementations avoid them.

{:#generic-signmessage}
Over five years after the introduction of the initial segwit proposal,
and three years after its activation, there remains no universal way to
create and verify plain text messages signed using the keys that
correspond to a P2WPKH or P2SH-P2WPKH address.  The problem exists more
generically as well: there's no widely supported way to handle messages
for P2SH, P2WSH, and P2SH-P2WSH addresses either---nor a forward
compatible way that will work for taproot addresses.  The [BIP322][]
proposal for a [generic signmessage][topic generic signmessage] function
is an attempt to fix all of these issues, but it's failed to gain much
traction.  This year saw an additional [request for feedback][news88
signmessage rfh] from its champion, a [simplification][news91
signmessage simplification], and (in October) a nearly [complete
replacement][news118 signmessage update proposal] of its core mechanism.
The [new mechanism][news121 signmessage update bip] makes message
signing potentially compatible with a large amount of existing software
and hardware wallets, as well as the [PSBT][topic psbt] data format, by
allowing the signing of *virtual transactions* that look like real
transactions but which can be safely signed because they aren't valid
according to Bitcoin's consensus rules.  Hopefully, this improvement will
allow generic signmessage to start to receive adoption.

{:#musig2}
Jonas Nick, Tim Ruffing, and Yannick Seurin [published][news120 musig2]
the MuSig2 paper in October describing a new variant of the
[MuSig][topic musig] signature scheme with a two round signing protocol
and no need for a zero-knowledge proof. What's more, the first round
(nonce exchange) can be done at key setup time with a non-interactive
signing variant that could be particularly useful for cold storage and
offchain contract protocols such as LN.

{:#addrv2}
Also in October, Bitcoin Core became the first project to
[merge][bcc19954] an implementation of the [version 2 `addr`
message][topic addr v2].  The `addr` message advertises the network
addresses of potential peers, allowing full nodes to discover new peers
without any centralized coordination.  The original Bitcoin `addr`
message was designed to hold 128-bit IPv6 addresses, which also allowed
it to contain encoded IPv4 addresses and version 2 Tor onion addresses.
After almost 15 years in production, the Tor project deprecated version
2 onion services and will stop supporting them in July 2021.  Newer
version 3 onion addresses are 256 bits, so they're not usable with the
original `addr` messages.  The [BIP155][] upgrade of the `addr` message
provides more capacity for Tor addresses and also makes it possible to use
other anonymity networks that require larger addresses.

## November

{:#lightning-pool}
As mentioned in the February section, one challenge faced in the current
LN network is that users and merchants need channels with incoming
capacity in order to receive funds over LN.  A fully
decentralized solution to that problem could be the dual-funded channels
described earlier.  However, in November, Lightning Labs took a
different track and [announced][news123 lightning pool] a new Lightning
Pool marketplace for buying incoming LN channels.  Some existing node
operators already provide incoming channels, either for free or as a
paid service, but Lightning Pool may be able to use its centrally
coordinated marketplace to make this service more standardized and
competitive.  It's possible this could also be upgraded to work with
dual funded channels when they become available.

## December

{:#ln-offers}
Last year, Rusty Russell published a first draft of a [proposed
specification][bolt12 draft] for LN *offers*, the ability for a spending
node to request an invoice from a receiving node over the onion-routed
LN network.  Although the existing [BOLT11][] provides an invoice
protocol, it doesn't allow for any protocol-level negotiation between
the spender and receiver nodes.  Offers would make it possible for the
nodes to communicate additional information and automate payment steps
that currently require manual intervention or additional tools.  For
example, offers could allow LN nodes to manage recurring payments or
donations by having a spender node request a new invoice each month from
a receiver node.  In December 2020, the first in a series of commits by
Russell to C-Lightning for implementing offers was [merged][news128
offers].

## Conclusion

One of the things we love about summarizing the past year's events is
that every bit of progress is fully realized.  The summary above does
not contain promises about what Bitcoin will do in the future---it lists
only actual accomplishments achieved in the past 12 months.  Bitcoin
contributors have a lot to be proud of in 2020.  We can't wait to see
what they have in store for us in 2021.

*The Optech newsletter will return to its regular Wednesday publication
schedule on January 6th.*

{% include references.md %}
{% include linkers/issues.md issues="8312,524,18038,18861,19109,14582,19743,16152" %}
[2018 summary]: /en/newsletters/2018/12/28/
[2019 summary]: /en/newsletters/2019/12/28/
[`addr` message]: https://btcinformation.org/en/developer-reference#addr
[atomicity attack discussion]: /en/newsletters/2020/06/24/#continued-discussion-about-ln-atomicity-attack
[attack htlc incentives]: /en/newsletters/2020/07/01/#discussion-of-htlc-mining-incentives
[attack invdos]: /en/newsletters/2020/09/16/#inventory-out-of-memory-denial-of-service-attack-invdos
[attack ln atomicity]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[attack ln fee ransom]: /en/newsletters/2020/06/24/#ln-fee-ransom-attack
[attack overpay segwit]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[attack time dilation]: /en/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[bcc18044]: /en/newsletters/2020/07/29/#bitcoin-core-18044
[bcc18267]: /en/newsletters/2020/09/30/#bitcoin-core-18267
[bcc19569]: /en/newsletters/2020/08/05/#bitcoin-core-19569
[bcc19954]: /en/newsletters/2020/10/14/#bitcoin-core-19954
[belcher coinswap1]: /en/newsletters/2020/06/03/#design-for-a-coinswap-implementation
[belcher coinswap2]: /en/newsletters/2020/08/26/#discussion-about-routed-coinswaps
[belcher coinswap3]: /en/newsletters/2020/09/09/#continued-coinswap-discussion
[belcher dec8 tweet]: https://twitter.com/chris_belcher_/status/1336322923800322049
[bfd post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-May/012636.html
[bip157 spec discussion]: /en/newsletters/2018/06/08/#bip157-bip157-bip158-bip158-lightweight-client-filters
[bips900]: /en/newsletters/2020/05/06/#bips-900
[bips933]: /en/newsletters/2020/07/01/#bips-933
[bips947]: /en/newsletters/2020/08/05/#bips-947
[bips983]: /en/newsletters/2020/09/09/#bips-983
[bitcoin core 0.20.0]: /en/newsletters/2020/06/10/#bitcoin-core-0-20-0
[bolt12 draft]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[btcd #1180]: https://github.com/btcsuite/btcd/pull/1180
[cl3870]: /en/newsletters/2020/09/16/#c-lightning-3870
[cl4068]: /en/newsletters/2020/09/30/#c-lightning-4068
[c-lightning 0.9.0]: /en/newsletters/2020/08/05/#c-lightning-0-9-0
[coinswap design]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017898.html
[common ownership heuristic]: https://en.bitcoin.it/wiki/Common-input-ownership_heuristic
[compatibility index]: /en/compatibility/
[copa announced]: /en/newsletters/2020/09/16/#crypto-open-patent-alliance
[copa membership]: /en/newsletters/2020/12/09/#cryptocurrency-open-patent-alliance-copa-gains-new-members
[crypto garage p2p deriv]: /en/newsletters/2020/08/19/#crypto-garage-announces-p2p-derivatives-beta-application-on-bitcoin
[default signet discussion]: /en/newsletters/2020/09/02/#default-signet-discussion
[discreet log contracts]: https://adiabat.github.io/dlc.pdf
[dlc election bet]: https://suredbits.com/settlement-of-election-dlc/
[dlc spec]: https://github.com/discreetlogcontracts/dlcspecs/
[dryja poon sf devs]: https://lightning.network/lightning-network.pdf
[ecdsa]: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
[eclair 0.4]: /en/newsletters/2020/05/13/#eclair-0-4
[finney glv]: https://bitcointalk.org/index.php?topic=3238.msg45565#msg45565
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[joinmarket]: https://github.com/JoinMarket-Org/joinmarket-clientserver
[libsecp256k1]: https://github.com/bitcoin-core/secp256k1
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[lnd 0.10.0-beta]: /en/newsletters/2020/05/06/#lnd-0-10-0-beta
[lnd 0.11.0-beta]: /en/newsletters/2020/08/26/#lnd-0-11-0-beta
[lnd 0.9.0-beta]: /en/newsletters/2020/01/29/#upgrade-to-lnd-0-9-0-beta
[maxwell gcs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-May/012637.html
[musig2 paper]: /en/newsletters/2020/10/21/#musig2-paper-published
[neutrino]: https://github.com/lightninglabs/neutrino
[news100 bcc19010]: /en/newsletters/2020/06/03/#bitcoin-core-19010
[news100 revault arch]: /en/newsletters/2020/06/03/#the-revault-multiparty-vault-architecture
[news101 additional commitment]: /en/newsletters/2020/06/10/#bips-920
[news102 bip85]: /en/newsletters/2020/06/17/#bips-910
[news102 wasabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[news104 bips923]: /en/newsletters/2020/07/01/#bips-923
[news107 bcc19109]: /en/newsletters/2020/07/22/#bitcoin-core-19109
[news107 bech32 fives]: /en/newsletters/2020/07/22/#bech32-address-updates
[news109 sapio]: /en/newsletters/2020/08/05/#sapio
[news111 bcc19070]: /en/newsletters/2020/08/19/#bitcoin-core-19070
[news111 uniform tiebreaker]: /en/newsletters/2020/08/19/#proposed-uniform-tiebreaker-in-schnorr-signatures
[news112 bcc14582]: /en/newsletters/2020/08/26/#bitcoin-core-14582
[news112 bolts688]: /en/newsletters/2020/08/26/#bolts-688
[news113 bip340 update]: /en/newsletters/2020/09/02/#bips-982
[news113 witasym]: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[news115 bip340 merge]: /en/newsletters/2020/09/16/#libsecp256k1-558
[news116 payjoin joinmarket]: /en/newsletters/2020/09/23/#joinmarket-0-7-0-adds-bip78-psbt
[news117 patent]: /en/newsletters/2020/09/30/#us-patent-7-110-538-has-expired
[news118 signmessage update proposal]: /en/newsletters/2020/10/07/#alternative-to-bip322-generic-signmessage
[news119 bech32 discussion]: /en/newsletters/2020/10/14/#bech32-addresses-for-taproot
[news119 nested routing]: /en/newsletters/2020/10/14/#incremental-routing
[news119 witasym update]: /en/newsletters/2020/10/14/#updated-witness-asymmetric-payment-channel-proposal
[news120 glv]: /en/newsletters/2020/10/21/#libsecp256k1-830
[news120 musig2]: /en/newsletters/2020/10/21/#musig2-paper-published
[news120 taproot merge]: /en/newsletters/2020/10/21/#bitcoin-core-19953
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news121 riard disclosures]: /en/newsletters/2020/10/28/#full-disclosures-of-recent-lnd-vulnerabilities
[news121 signmessage update bip]: /en/newsletters/2020/10/28/#bips-1003
[news122 bidir fees]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news122 devsurvey]: /en/newsletters/2020/11/04/#taproot-activation-survey-results
[news123 high-s]: /en/newsletters/2020/11/11/#bolts-807
[news123 lightning pool]: /en/newsletters/2020/11/11/#incoming-channel-marketplace
[news124 htlc release]: /en/newsletters/2020/11/18/#bolts-808
[news125 miner survey]: /en/newsletters/2020/11/25/#website-listing-miner-support-for-taproot-activation
[news126 routing fibonds]: /en/newsletters/2020/12/02/#fidelity-bonds-for-ln-routing
[news127 bech32m research]: /en/newsletters/2020/12/09/#bech32-addresses-for-taproot-and-beyond
[news128 fancy static]: /en/newsletters/2020/12/16/#proposed-improvements-to-static-ln-backups
[news128 offers]: /en/newsletters/2020/12/16/#c-lightning-4255
[news24 cpfp carve out]: /en/newsletters/2018/12/04/#cpfp-carve-out
[news59 bishop idea]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[news80 msfa]: /en/newsletters/2020/01/15/#discussion-of-soft-fork-activation-mechanisms
[news81 dlc]: /en/newsletters/2020/01/22/#protocol-specification-for-discreet-log-contracts-dlcs
[news83 alt tiebreaker]: /en/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[news83 interactive funding]: /en/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[news85 blinded paths]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news86 backwards upfront]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[news86 bolts596]: /en/newsletters/2020/02/26/#bolts-596
[news86 large channels]: /en/newsletters/2020/02/26/#bolts-596
[news87 bip340 update1]: /en/newsletters/2020/03/04/#bips-886
[news87 bip340 update]: /en/newsletters/2020/03/04/#updates-to-bip340-schnorr-keys-and-signatures
[news87 exfiltration]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news87 taproot generic group]: /en/newsletters/2020/03/04/#taproot-in-the-generic-group-model
[news88 exfiltration]: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[news88 signmessage rfh]: /en/newsletters/2020/03/11/#bip322-generic-signmessage-progress-or-perish
[news89 op_if]: /en/newsletters/2020/03/18/#bitcoin-core-16902
[news8 p2ep]: /en/newsletters/2018/08/14/#pay-to-end-point-p2ep-idea-proposed
[news91 bip340 powerdiff]: /en/newsletters/2020/04/01/#mitigating-differential-power-analysis-in-schnorr-signatures
[news91 signmessage simplification]: /en/newsletters/2020/04/01/#proposed-update-to-bip322-generic-signmessage
[news92 cl3600]: /en/newsletters/2020/04/08/#c-lightning-3600
[news92 ecdsa adaptor]: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
[news93 super keychain]: /en/newsletters/2020/04/15/#proposal-for-using-one-bip32-keychain-to-seed-multiple-child-keychains
[news94 bishop vault]: /en/newsletters/2020/04/22/#vaults-prototype
[news94 btcpay payjoin]: /en/newsletters/2020/04/22/#btcpay-adds-support-for-sending-and-receiving-payjoined-payments
[news95 revault]: /en/newsletters/2020/04/29/#multiparty-vault-architecture
[news96 bcc18038]: /en/newsletters/2020/05/06/#bitcoin-core-18038
[news96 bip340 nonce update]: /en/newsletters/2020/05/06/#bips-893
[news96 bip340 update]: /en/newsletters/2020/05/06/#bips-893
[news97 additional commitment]: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[news98 bcc18877]: /en/newsletters/2020/05/20/#bitcoin-core-18877
[news98 sas]: /en/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap
[news99 bcc18861]: /en/newsletters/2020/05/27/#bitcoin-core-18861
[nick filter privacy]: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/
[optech blog posts]: /en/blog/
[rubin fee sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[russell loop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2015-August/000135.html
[rv routing]: /en/newsletters/2018/11/20/#hidden-destinations
[somsen sas post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017846.html
[somsen sas video]: https://www.youtube.com/watch?v=TlCxpdNScCA
[##taproot-activation]: /en/newsletters/2020/07/22/#taproot-activation-discussions
[taproot workshop]: /workshops/#taproot-workshop
[todd segwit review]: https://petertodd.org/2016/segwit-consensus-critical-code-review#peer-to-peer-networking
[topics index]: /en/topics/
[tx origin wiki]: https://en.bitcoin.it/wiki/Privacy#Traffic_analysis
[u.s. patent 7,110,538]: https://patents.google.com/patent/US7110538B2/en
