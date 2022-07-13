---
title: Channel Factories
uid: channel_factories
topic_page_or_best_reference: /en/topics/channel_factories/
excerpt: >
  Channel factories are an efficient way of creating payment channels.
  Multiple participants trustlessly combine their funds together using a
  single transaction.  From the combined funds, they create payment
  channels between each pair of participants, e.g. Alice with Bob, Bob
  with Carol, and Alice with Carol.  Although these are regular payment
  channels, the transactions opening the channels never need to appear
  on chain as long as the participants remain in cooperation with each
  other, allowing *n* users to open *n(n-1)/2* channels at the cost of
  opening and mutual transactions that are only roughly *n* times larger
  than standard open and mutual close transactions, e.g. 10 users can
  open 45 channels using transactions only 10x larger than normal.  In
  the case any participant violates the channel protocol, each
  participant has the independent ability to close their channel onchain
  in the proper state, ensuring the protocol remains trustless.


---
Channel factories are similar to [joinpools][topic joinpools].  Also
similar to joinpools, channel factories don't require any changes to
Bitcoin---using presigned transactions is enough---but several covenant
proposals could help make factories more efficient, easier to construct,
or easier to analyze.

Some notable quotes about channel factories related to covenant
proposals:

- "The ability to extend the protocol to a larger number of participants
  also means that it can be used for other protocols, such as the
  channel factories presented by Burchert et al.  Prior to eltoo this
  used the Duplex Micropayment Channel construction, which resulted in a
  far larger number of transactions being published in the case of a
  non-cooperative settlement of the contract."  ---[Eltoo paper][] by
  Decker, Russell, and Osuntokun (Note: the eltoo protocol is based on
  the `SIGHASH_ANYPREVOUT` proposal)

- "IIDs support a simple factory protocol in which not all parties need
  to sign the factory's funding transaction, thus greatly improving the
  scale of the factory (at the expense of requiring an on-chain
  transaction to update the set of channels created by the factory).
  These channel factories can be combined with the 2Stage protocol to
  create trust-free and watchtower-free channels including very large
  numbers of casual users."  ---[Inherited Identifiers (IIDs)
  introduction][iid intro] by John Law

{% include references.md %}
[eltoo paper]: https://blockstream.com/eltoo.pdf
[iid intro]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019470.html
