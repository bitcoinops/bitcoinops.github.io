*By [Antoine Poinsot][darosior], [Revault][] developer*

Bitcoin [vaults][topic vaults] are a type of contract that require two sequential
transactions for a user to spend money from their wallet. Numerous such
protocols have been proposed (single or multi-party, with or
without [covenants][topic covenants]) so we'll focus on what they have in
common.

Contrary to [batched payments][topic payment batching] that execute multiple payments with a single onchain transaction,
vaults use multiple transactions to execute a single payment. The first transaction, the *unvault*, pays
to either:

1. a set of pubkeys after a relative timelock, or
2. a single pubkey without any timelocks.

The first spending path is the mainline case, expected to be used with "hotter" key(s). The second spending
path allows for a *cancel* transaction (sometimes called the *clawback, recovery or re-vaulting* transaction).

As such, Bitcoin vaults are contrary to the insight of [taproot][topic taproot] that most contracts have a happy path
where all participants collaborate with a signature (and the dispute path usually contains timelocks).
Rather the opposite. The *spend* transaction must use the taproot script
sending path, since it is encumbered by the relative timelock[^0] while the
*cancel* transaction could in theory use the key spending path.

Since multi-party vaults already require a lot of interactivity in practice,
they could theoretically benefit from interactive [multisignature][topic
multisignature] and [threshold signature][topic threshold signature] schemes made
possible by [BIP340][], such as [Musig2][topic musig]. However, these schemes
come with new
safety challenges. Since vault protocols are intended to be used for cold
storage, the design choices are more conservative and vaults would probably be the
last to use these new technologies.

By switching to taproot, vaults would also benefit from a slight privacy and efficiency improvement
due to the use of merkle branches and shorter BIP340 signatures (especially for multi-party ones).
For instance, the *unvault* output script in a multi-party setup with 6 "cold" keys and 3 "active" keys
(with a threshold of 2) could be represented as a Taproot of depth 2 with leaves:

- `<X> CSV DROP <active key 1> CHECKSIG <active key 2> CHECKSIGADD 2 EQUAL`
- `<X> CSV DROP <active key 2> CHECKSIG <active key 3> CHECKSIGADD 2 EQUAL`
- `<X> CSV DROP <active key 3> CHECKSIG <active key 1> CHECKSIGADD 2 EQUAL`
- `<cold key 1> CHECKSIG <cold key 2> CHECKSIGADD <cold key 3> CHECKSIGADD <cold key 4> CHECKSIGADD <cold key 5> CHECKSIGADD <cold key 6> CHECKSIGADD 6 EQUAL`

<!-- TODO: recalculate spending costs
This is about xxxx vbytes for the cheapest (happy) spending path and about xxxx vbytes for the costliest (dispute) one.
Compared to the roughly xxxx vbytes (happy) and xxxx vbytes (dispute) by using the following P2WSH: -->

In taproot, only the leaf being used to spend the output needs to be revealed,
so the transaction weight is considerably smaller than for the equivalent P2WSH
script:

```text
IF
  6 <cold key 1> <cold key 2> <cold key 3> <cold key 4> <cold key 5> <cold key 6> 6 CHECKMULTISIG
ELSE
  <X> CSV DROP
  2 <active key 1> <active key 2> <active key 3> 3 CHECKMULTISIG
ENDIF
```

Although the revocation branch can be hidden in case of a successful
spending (and if using a multisig threshold, its existence and the number of participants
obfuscated), the privacy gains are minimal as the vault usage pattern would be trivially
identifiable onchain.

Finally, vault protocols, like most pre-signed transactions protocols, would largely benefit from
further proposed Bitcoin upgrades based on taproot such as [BIP118][]'s [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]. Although requiring further caution
and protocol tweaks, `ANYPREVOUT` and `ANYPREVOUTANYSCRIPT` would enable rebindable *cancel*
signatures, which could largely reduce interactivity and allow 0(1) signature storage. This is
particularly interesting for the *emergency* signature in the [Revault protocol][], as it would largely
reduce the DoS attack surface.  By having an `ANYPREVOUTANYSCRIPT` signature in an output, you are
effectively creating a covenant by restricting how the transaction
spending this coin can create its outputs. Even more customizable
future signature hashes would permit more flexible restrictions.

[^0]:
    If known in advance you could pre-sign the *spend* transaction with a specific nSequence, but then
    you don't need an alternative spending path with "active" keys at all. Also, you don't usually know
    how you are going to spend your coins at the time you receive them.

[darosior]: https://github.com/darosior
[revault]: https://github.com/revault
[revault protocol]: https://github.com/revault/practical-revault
