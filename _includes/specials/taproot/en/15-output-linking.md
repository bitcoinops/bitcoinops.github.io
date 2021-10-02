{% auto_anchor %}

After taproot activates, users will begin receiving payments to P2TR
outputs.  Later, they'll spend those outputs.  In some cases, they'll
make payments to non-P2TR outputs but will still return their change to
themselves using a P2TR change output.

{:.center}
![Example transaction P2TR -> {P2WPKH, P2TR}](/img/posts/2021-10-p2tr-to-p2tr_p2wpkh.png)

It's easy for an expert or an algorithm observing such a transaction to
reasonably infer that the P2TR output is the user's own change output,
making the other output the payment output.  This isn't guaranteed to be
true, but it is the most likely explanation.

Some have argued that the many [privacy benefits][p4tr benefits] of taproot should be
ignored because of this possible temporary decrease in privacy during the
transition of wallets to P2TR.  Many experts have [called][coindesk
experts] that an unwarranted overreaction.  We agree and can also offer
a few additional counterpoints to consider:

- **Other metadata:** transactions may contain other metadata that
  reveals which outputs are change and which are payments.  One of the
  most concerning is the large percentage of outputs that currently
  [reuse addresses][topic output linking], significantly reducing
  privacy for both the spenders and receivers involved in those
  transactions.  For as long as those problems persist, it seems foolish
  not to proceed with significant privacy upgrades for users of wallets
  and services that implement best practices.

- **Output script matching:** Bitcoin Core's built in wallet defaults to
  [using a segwit change output][bitcoin core #12119] if any of the
  payment output types are also segwit.  Otherwise, it uses the default
  change address type.  For example, when paying a P2PKH output, a P2PKH
  change output might be used; for a P2WPKH output, P2WPKH change is
  used.  As described in [Newsletter #155][news155 bcc22154], after
  taproot activation Bitcoin Core will begin to
  opportunistically use P2TR change outputs when any other
  output in the same transaction is P2TR.  This can minimize any
  increase in change identifiability during the transitional period.

- **Request upgrades:** with P2TR, we have an opportunity for the first
  time in Bitcoin's history to get everyone using the same type of
  output script no matter their security requirements, and also to
  frequently use indistinguishable inputs, which significantly improves
  privacy.  If you want to see a meaningful increase in Bitcoin privacy,
  you can ask the users and services you pay to provide taproot support
  (and also to stop reusing addresses, if applicable).  If both you and
  they upgrade, then change outputs become harder to identify and we
  also get all of taproot's other amazing privacy benefits.

{% include linkers/issues.md issues="12119" %}
{% endauto_anchor %}
[p4tr benefits]: /en/preparing-for-taproot/#multisignature-overview
[p4tr safety]: /en/preparing-for-taproot/#why-are-we-waiting
[coindesk experts]: https://www.coindesk.com/tech/2020/12/01/privacy-concerns-over-bitcoin-upgrade-taproot-are-a-non-issue-experts-say/
[compat bcc]: /en/compatibility/bitcoin-core/
[news155 bcc22154]: /en/newsletters/2021/06/30/#bitcoin-core-22154
