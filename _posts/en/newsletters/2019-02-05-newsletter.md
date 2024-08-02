---
title: 'Bitcoin Optech Newsletter #32'
permalink: /en/newsletters/2019/02/05/
name: 2019-02-05-newsletter
slug: 2019-02-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes an announcement of the 2019 Chaincode
Residency program, summarizes a few talks from the Stanford Blockchain
Conference, and provides the usual list of notable code changes in
popular Bitcoin infrastructure projects.

## Action items

- **Apply to the Chaincode Residency:** Bitcoin Optech encourages any
  engineer who is interested in spending summer contributing to open source
  Bitcoin and Lightning projects to apply to the Chaincode Residency. Full
  details of the residency are in the *News* section below.

## News

- **Chaincode Residency 2019:** Chaincode Labs opened applications for its
  [fourth residency program][residency] to be held in New York over
  summer 2019. The program combines a 3 week seminar and discussion series
  covering Bitcoin and Lightning protocol development with a two month period for
  working on an open source Bitcoin or Lightning project under the guidance of an
  established protocol developer. The list of [confirmed speakers and
  mentors][residency speakers] includes some of the most prolific contributors to
  Bitcoin and Lightning. The previous Chaincode Residency (focused on Lightning
  Network applications) was covered in [Newsletter #21][].

  Chaincode is inviting developers who want to contribute to open source
  Bitcoin and Lightning protocol projects to [apply to the
  residency][residency apply]. Applicants from all backgrounds are welcomed,
  and Chaincode will cover travel and accommodation costs and provide a stipend
  to support living expenses.

[residency]: https://residency.chaincode.com
[residency speakers]: https://residency.chaincode.com/#mentors
[residency apply]: https://residency.chaincode.com/#apply

## Notable talks from the Stanford Blockchain Conference

The [third edition][sbc] of this annual conference (formerly named BPASE)
included more than two dozen presentations across three days.  We found
the following topics especially interesting from a Bitcoin perspective,
although we encourage anyone who wants to learn more to look at the
[transcripts][] provided by Bryan Bishop or the videos provided by
the organizers ([day 1][], [day 2][], [day 3][]).

- **Accumulators for blockchains** presented by Benedikt Bünz
  ([transcript][accumulators txt], [video][accumulators vid]).  Bitcoin
  full nodes maintain a ledger (called the UTXO set) that stores the
  ownership information for every currently-spendable grouping of
  bitcoins.  Currently, that ledger contains over 50 million entries
  and uses about three gigabytes of disk space.  This allows nodes who
  receive a transaction to ensure the bitcoins being spent exist in
  the UTXO set, retrieve the ownership information for those bitcoins,
  and verify that information against the signature and other witness
  data provided in the transaction.

  But what if we also asked the spender to provide a copy of the
  ownership information in their transaction along with a
  cryptographic proof that the information is actually in the UTXO
  set?  In that case, we wouldn't need to store the whole set, we'd
  only need to store a commitment to a set we knew was accurate and
  that could be referenced by accurate proofs.  RSA accumulators are
  one idea (among several others) for how to create that commitment
  and its related proofs.  Using an accumulator, the size of the UTXO
  commitment that nodes would store on disk would be tiny compared to
  the full state.  Transactions would increase in size due to needing
  to provide ownership data and a proof that they were part of the
  current UTXO set, but the size increase would be modest (assuming
  current typical transactions, about 70 bytes of ownership
  information per input plus a proof that could be aggregated down to
  about 325 bytes per block).

  Other considerations affect the suitability of accumulators to
  the task, including being relatively new to cryptography,
  requiring either a well-studied trusted setup or a
  more novel untrusted setup, and potentially making blocks take
  longer to verify than the current system given that accumulator
  verification is about 100x slower than alternative systems using
  merkle trees.  In a new development compared to a previous
  version of this talk given at Scaling Bitcoin 2018, the speaker
  describes a potential major speedup to practical verification.

  In summary, RSA accumulators remain an interesting area of investigation
  into how to reduce full node requirements for storing and quickly
  accessing the UTXO set.  This may not be particularly important now,
  when the UTXO set is relatively small and fast, but it could make it
  easier to support initiatives that would change how people use the
  UTXO set in the future.  For example:

  - If accumulator-based proofs can indeed be verified quickly, they
    could allow the UTXO set size to grow considerably (perhaps
    because of a block size increase) while still ensuring that miners
    can verify transaction inputs quickly enough to minimize the use of
    spy mining or the production of stale blocks.

  - Software that uses trusted UTXO sets with newly-started nodes to
    avoid the cost and delay of downloading and verifying the full
    block chain (an option [some software][btcpay utxo] already
    provides) could reduce those costs and delays even further by
    replacing the multi-gigabyte UTXO set with an accumulator a
    million times smaller.

  It should
  be possible for eager experimenters to explore the use of
  accumulators in Bitcoin without changing any consensus rules, such
  as Tadge Dryja has been doing with his similar [Utreexo][] system
  based on merkle trees.

- **Miniscript** presented by Pieter Wuille ([transcript][miniscript
  txt], [video][miniscript vid], [slides][miniscript slides]).
  Imagine you had a Bitcoin script that gave control over your bitcoins
  to your lawyer a year after you last moved them, in case he needed to
  distribute them to your heirs.  That's an easy script to write.  But
  what if someone then asked you to join a 3-of-4 multisig contract
  where you'd be one of parties holding some funds.  How hard would it
  be for you to insert your existing policy into their generic multisig
  contract and be sure you haven't broken anything?  That's the question
  asked by this speaker, and his answer is the composable policy
  language *miniscript*.

  Miniscript is a subset of the full Bitcoin Script language that
  focuses on just a few features such *signatures*, *times*, and
  *hashes* plus operators for combining them, such as *and*, *or*, or
  *threshold*.  It's compact, easy to read, and will compile down to
  the most efficient script implementing a given policy.  From an
  existing script compatible with its operations, it will also reverse
  it back into a policy for easy review.  By design, it uses a
  similar vocabulary to the [output script descriptors][] Wuille has
  been implementing in Bitcoin Core and it can help the updater or
  finalizer in a [BIP174][] PSBT workflow figure out who needs to sign
  next or whether all data for finalizing the script has been
  received.

  Looking at the problem posed in the introduction paragraph, we can
  define the example personal spending policy as either you providing a
  signature for your compressed pubkey, `pk(C)`, or your lawyer
  waiting for a year, `time(<seconds>)`, and then providing a
  signature for his own compressed pubkey.  We combine these branches
  with an asymmetric "or," `aor`, to reduce the witness data required
  when following the first branch.

  ```
  aor(pk(C),and(time(31536000),pk(C)))
  ```

  We can define the generic 3-of-4 multisig policy similarly using
  compressed pubkeys (`C`):

  ```
  multi(3,C,C,C,C)
  ```

  A functionally equivalent policy that allows more flexibility would
  use the threshold operation:

  ```
  thres(3,pk(C),pk(C),pk(C),pk(C))
  ```

  This allows you to just replace one of the public keys with your personal
  policy:

  ```
  thres(3,pk(C),pk(C),pk(C),aor(pk(C),and(time(31536000),pk(C))))
  ```

  When compiled, the result is the following script:

  ```
  [pk] CHECKSIG SWAP [pk] CHECKSIG ADD SWAP [pk] CHECKSIG ADD
  TOALTSTACK IF [pk] CHECKSIGVERIFY 0x8033e101 CHECKSEQUENCEVERIFY
  0NOTEQUAL ELSE [pk] CHECKSIG ENDIF FROMALTSTACK ADD 3 EQUAL
  ```

  A final benefit of miniscript is that it should allow a policy
  written today to be automatically translated into a structure that
  makes optimal use of MAST, taproot, or other possible Bitcoin
  protocol upgrades.  That means, as the Bitcoin protocol advances,
  the user or developer who invested time into crafting a policy won't
  have to redo their work in order to continue using it with newer
  technology.

  The speaker has provided an interactive Javascript [demo of the
  miniscript compiler][miniscript demo], and he and his collaborators
  also have a Rust language version of the compiler they plan to
  release as open source soon.

- **Probabilistic Bitcoin soft forks (sporks)** presented by Jeremy
  Rubin ([transcript][spork txt], [video][spork vid]).  By March 2017,
  almost all Bitcoin nodes were ready to begin enforcing the segwit soft
  fork but miners seemed unwilling to send the activation signal.  This
  created confusion: do miners get to veto protocol upgrades?  If they
  do, is segwit dead?  If they don't, what do users do to override them?
  Ultimately the situation was resolved, but it was a mess that many
  would prefer not to repeat.

  The speaker identifies the root cause of the problem as miners being
  able to delay activation at no cost to themselves.  He proposes a
  solution: use the randomness remaining in a block header hash to
  determine whether or not a block signals for activation.  For
  example, we'd choose a target that only 1 header hash out of 26,000
  would match.  A block matching that target would be produced once every
  six months on average, although nobody would know exactly when
  (about 10% of the time, it'd be within 3 weeks; but another 10% of
  the time, it'd take more than a year).

  Miners would have no control over whether or not their block
  signaled for activation, but they would have control over whether
  they published that block.  A miner who refused to publish his own
  block if it signaled for activation would lose the income from that
  block but would successfully prevent the fork from activating at
  least until the next signaling block was produced (which could be
  tomorrow or could be two years later).  This gives miners a real
  chance to hold back a change but only by sacrificing real income.
  The end of the talk suggests some variations on the method with
  different tradeoffs.

  The idea needs to be analyzed for possible problems, but it does
  provide an interesting alternative to [BIP9][]-style miner-activated
  soft forks (MASFs) and [BIP8][]-style user-activated soft forks (UASFs).

  At the conclusion of his talk, this speaker also announced that the
  next Scaling Bitcoin conference and EdgeDev++ training sessions will
  be later in 2019 in Tel Aviv, Israel.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
and [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14929][] allows peers that your node automatically
  disconnected for misbehavior (e.g. sending invalid data) to reconnect
  to your node if you have unused incoming connection slots.  If your
  slots fill up, the misbehaving nodes are disconnected to make room for
  nodes without a history of problems (unless the misbehaving node helps
  your node in some other way, such as by connecting to a part of the
  Internet from which you don't have many other peers).  Previously,
  Bitcoin Core banned the IP addresses of misbehaving peers for a period
  of time (default of 1 day); this was easily circumvented by attackers
  with multiple IP addresses.  This solution gives those peers a chance
  to be useful but provides priority to potentially more helpful peers.
  If you manually ban a peer, such as by using the `setban` RPC,
  connections from that peer will still be rejected.

- [Bitcoin Core #13926][] adds a new `bitcoin-wallet` tool to the
  executables Bitcoin Core provides.  Without using RPCs or any network access,
  this tool can currently create a new wallet file or display some basic
  information about an existing wallet, such as whether the wallet is
  encrypted, whether it uses an HD seed, how many transactions it
  contains, and how many address book entries it has.  This helps people
  who have a wallet file that hasn't been synced to the most recent chain
  tip; they can do a quick inspection on the wallet to see if it's
  interesting before they perform the lengthy rescan necessary to import
  it.  Developers plan to add more features to the tool in the future.

- [Bitcoin Core #15159][] changes the `getrawtransaction` RPC so that it
  will now only return transactions in the mempool by default.  If you
  have enabled the optional transaction index (txindex), it will also
  return confirmed transactions as well.  Prior to this change, even
  if you didn't have the txindex enabled, it would return confirmed
  transactions if they hadn't yet had all their outputs spent.  This
  previous behavior confused users: the call would work on some
  confirmed transactions but not others, and sometimes transactions that
  previously worked would suddenly stop working.  This change makes the
  RPC act more consistently (although, of course, mempools vary between
  nodes and change over time).

- [LND #2538][] increases the default time between sending updates about
  what public nodes exist on the network from 30 seconds to 90 seconds.
  This slows down propagation on the network, which has grown hugely in
  size, in order to conserve bandwidth.  Separately from this PR, LN
  protocol devs are preparing changes to the gossip protocol to be more
  bandwidth efficient, although a lower update frequency will still save
  bandwidth there as well.  (See also [C-Lightning #2297][] for the fix
  this week to a bug some nodes were encountering because the volume of
  gossip they received was so large.)

- [LND #2554][] deprecates the `IncorrectHtlcAmount` onion error
  in favor of the `UnknownPaymentHash` error that now includes the
  amount of the failed payment.  LND will still handle the old error
  code but it will no longer generate it.

- [LND #2500][] disconnects any peers that don't support the Data Loss
  Protection (DLP) protocol.  This ensures that LND's new backup format
  will be usable.  See the *notable commits* section and footnote from
  [last week's newsletter][Newsletter #31] for information about the new
  backup protocol and the existing DLP protocol.

{% include references.md %}
{% include linkers/issues.md issues="2500,2554,15159,13926,2538,14929,2297" %}
[accumulators txt]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/accumulators/
[accumulators vid]: https://youtu.be/XckwEw8FyEA?t=20295
[miniscript txt]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/miniscript/
[miniscript vid]: https://youtu.be/sQOfnsW6PTY?t=22539
[miniscript slides]: https://prezi.com/view/KH7AXjnse7glXNoqCxPH/
[miniscript demo]: http://bitcoin.sipa.be/miniscript/miniscript.html
[spork txt]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/spork-probabilistic-bitcoin-soft-forks/
[spork vid]: https://youtu.be/sQOfnsW6PTY?t=29762
[sbc]: https://cyber.stanford.edu/sbc19
[transcripts]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/
[day 1]: https://www.youtube.com/watch?v=XckwEw8FyEA
[day 2]: https://www.youtube.com/watch?v=sQOfnsW6PTY
[day 3]: https://www.youtube.com/watch?v=U5fEvfAFs_o
[utreexo]: https://dci.mit.edu/research/2018/11/28/utreexo-a-dynamic-accumulator-for-bitcoin-state-a-description-of-research-by-thaddeus-dryja
[btcpay utxo]: https://github.com/btcpayserver/btcpayserver-docker/tree/master/contrib/FastSync
[newsletter #21]: /en/newsletters/2018/11/13/#lightning-application-residency-videos
[newsletter #31]: /en/newsletters/2019/01/29/#c-lightning-2283
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
