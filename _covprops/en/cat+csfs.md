---
title: "OP_CAT + OP_CHECKSIGFROMSTACK"
shorttitle: "OP_CAT + OP_CSFS"
uid: cat_csfs
#layout: covprop
topic_page_or_best_reference: /en/topics/op_checksigfromstack/

implementations:
  - name: Liquid
    can_lose_significant_money: true
    reference: https://example.com/FIXME
    since: 2018

  - name: Bcash
    can_lose_significant_money: true
    reference: https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/op_checkdatasig.md
    # also https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/may-2018-reenabled-opcodes.md
    since: 2018

covenant_based_apps:
  channel_factories:
    enabled: true

  congestion_control:
    enabled: true

  dlc_efficiency:
    enabled: true

  drivechains:
    enabled: true

  eltoo:
    enabled: true

  statechains:
    enabled: true

  joinpools:
    enabled: true

  non_interactive_channels:
    enabled: true

  bishop_vaults:
    enabled: true

  mes_vaults:
    enabled: true
    example_code: https://blog.blockstream.com/en-covenants-in-elements-alpha/
    #example_txes: NONE

  obeirne_vaults:
    enabled: true

  zk_rollups:
    enabled: true

excerpt: >
  `OP_CAT` concatenates two strings and `OP_CHECKSIGFROMSTACK`
  (`OP_CSFS`) checks a pubkey and signature combination against an
  arbitrary messages.  Bitcoin's existing `OP_CHECKSIG` opcodes check
  pubkeys and signatures against the transaction containing them.  If
  the same pubkey and signature are valid for both the containing
  transaction and the arbitrary message, then the arbitrary message must
  be a copy of the transaction containing it.  This allows the receiver
  of an output to specify certain strings that must be present in the
  transaction spending that output (creating a covenant).  `OP_CAT` is
  used to concatenate those strings with strings only the spender can
  provide.
---
## Advantages

- **Simple:** the direct behavior of both opcodes is very simple to
  understand:

   - `OP_CAT` takes two strings and concatenates them
   - `OP_CSFS` takes a pubkey, message, and signatature and returns true
     if they're a validate combination (i.e. the private key from
     which the public key was derived also created the signature for
     that particular message)<br><br>

- **Flexible:** together the opcodes are believed to enable some version
  of all covenant-based applications.

- **Non-covenant applications:** string concatenation and arbitrary
  signature checking can also be used for several applications unrelated
  to covenants; see their [Optech topic page][] for details.  FIXME: add
  QC resistance.

## Disadvantages

- **General:** the flexible nature of CAT+CSFS allows users to opt-in to
  receiving payments to types of covenants that other users might
  find objectionable, such as drivechains or perpetual covenants.

- **Expensive:** using CAT+CSFS for coveneants requires putting a copy
  of the spending transaction on the execution stack.  That can roughly
  double the size of a spending transaction over the other data needed
  to make it valid.  Other proposals such as [OP_TX][] could reduce this
  overhead.

- **Difficult:** using CAT+CSFS to create a covenant requires
  concatenating data provided by the covenant creator with data provided
  by the spender, with the covenant creator needing to devise tests in
  the Script language that ensure the spender-provided data satisfies
  the creator's intentions.  That's challenging enough, but the creator
  also needs to ensure that transactions created within the covenant
  don't accidentally get into a state where further spending become
  improssible, burning funds.  Although both of these are challenges for
  any generalized covenant system, managing trusted and untrusted data
  as strings is more difficult than other ways of addressing
  information, e.g. it would be simpler to use [OP_TX][] to introspect
  on parts of the spending transaction directly.

## Alternative approaches

FIXME:OP_TX

