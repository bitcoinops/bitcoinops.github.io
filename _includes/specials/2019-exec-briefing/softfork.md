{% include references.md %}
{% capture the-next-softfork %}In his presentation, Lee describes the various phases
  of a soft fork from idea to proposal to implementation to activation.
  Using this framework, he identifies the current state of the
  Schnorr/Taproot soft fork (see [Newsletter #46][newsletter #46 taproot]), the consensus
  cleanup soft fork ([#36][Newsletter #36 cc]), and the noinput soft fork
  proposals ([BIP118][] and [bip-anyprevout], see [#47][Newsletter
  #47 apo]).  Although later in the presentation he provides an overview of
  the consensus cleanup soft fork (fixing several non-urgent problems
  in the protocol) and the noinput proposals (enabling new features for
  contract protocols such as the [Eltoo][] layer for LN), his talk---and
  this summary of it---focuses on the combined [bip-schnorr][],
  [bip-taproot][], and [bip-tapscript][] proposal.

  After providing a high-level overview of Schnorr signatures and
  signature aggregation---information probably already familiar to
  readers of this newsletter---Lee builds a significant portion of his
  presentation around 2-of-3 multisig security for business
  spenders, a feature used by many businesses today.  He first
  describes the savings available to users of *threshold keys,*
  aggregated public keys that only require a subset of the original
  parties in order to create a valid signature, such as an aggregated
  key created from three individual keys that can be signed for by any
  two of the participants for 2-of-3 multisig security.  The upside of
  this approach is maximal efficiency and privacy onchain, but the
  downside is required interactivity creating the pubkey,
  interactivity creating the signature, and an inability of the
  keyholders to use block chain data for auditing to determine which
  subset of them actually participated in signing.

  Addressing both the public key interactivity and the signature
  auditing concerns, Lee uses an easy-to-understand sequence of illustrated slides to demonstrate an alternative construction possible
  using a combination of Taproot's key-path and script-path spending.
  Three [MuSig][]-style 2-of-2 aggregated pubkeys are created---one
  for each of the three possible pairs of signers in 2-of-3 multisig.
  Because this is MuSig n-of-n key aggregation, it doesn't require
  interaction.  The most likely of these combinations (e.g.  a hot
  wallet key and a third-party security key) is made available for
  Taproot key-path spending, allowing an output to be spent using a
  single aggregate signature that looks like any single-sig spend.
  The two alternative options (e.g. each involving a cold backup key)
  are placed in a MAST tree for a script-path spend.  This isn't as
  private or as cheap but it provides redundancy.  For any of these
  options, any third-party looking at the block chain data sees only a
  single signature and no direct information about how many parties
  are involved, but each of the three key holders knows which two of
  the participants' public keys were used to create the particular
  aggregated key that the spending signature matched, giving them
  private auditability.  Lee concludes this portion of the talk by
  summarizing the tradeoffs and showing the clear overall benefits of
  Schnorr and Taproot for current multisig spenders.

  In addition to enhancing current uses of Bitcoin, also described are
  new features that aren't currently practical but which would become
  so if Schnorr-style signatures and MAST-style script trees become
  available.  Lee finishes his talk by providing a rough, and heavily
  caveated, timeline for when we might see the changes described in
  his talk.{% endcapture %}

[newsletter #36 cc]: /en/newsletters/2019/03/05/#cleanup-soft-fork-proposal
[newsletter #46 taproot]: /en/newsletters/2019/05/14/#overview-of-the-taproot--tapscript-proposed-bips
[newsletter #47 apo]: /en/newsletters/2019/05/21/#proposed-anyprevout-sighash-modes
