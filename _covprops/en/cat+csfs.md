---
title: "OP_CAT + OP_CHECKSIGFROMSTACK"
shorttitle: "CAT+CSFS"
uid: cat_csfs
#layout: covprop
topic_page_or_best_reference: /en/topics/op_checksigfromstack/
aliases:
  - OP_SHASTREAM   # FIXME: move to separate OP_CAT covenants page

implementations:
  - name: Liquid
    can_lose_significant_money: true
    reference: https://example.com/FIXME
    since: "2018"

  - name: Bcash
    can_lose_significant_money: true
    reference: https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/op_checkdatasig.md
    # also https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/may-2018-reenabled-opcodes.md
    since: "2018"

uses:
  channel_factories:
    enabled: "true"

  congestion_control:
    enabled: "true"

  dlc_efficiency:
    enabled: "unknown"

  drivechains:
    enabled: "true"

  eltoo:
    enabled: "true"

  statechains:
    enabled: "true"

  joinpools:
    enabled: "true"

  non_interactive_channels:
    enabled: "true"

  bishop_vaults:
    enabled: "true"

  mes_vaults:
    enabled: "true"
    example_code: https://blog.blockstream.com/en-covenants-in-elements-alpha/
    #example_txes: NONE

  obeirne_vaults:
    enabled: "true"

  zk_rollups:
    enabled: "true"

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
  to covenants; see the CAT+CSFS [topic page][topic
  op_checksigfromstack] for details.  FIXME: add QC resistance.

## Disadvantages

- **General:** the flexible nature of CAT+CSFS allows users to opt-in to
  receiving payments to types of covenants that other users might
  find objectionable, such as drivechains or perpetual covenants.

- **Expensive:** using CAT+CSFS for coveneants requires putting a copy
  of the spending transaction on the execution stack.  That can roughly
  double the size of a spending transaction over the other data needed
  to make it valid.  Other proposals such as OP_TX could reduce this
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
  information, e.g. it would be simpler to use OP_TX to introspect on
  parts of the spending transaction directly.

## Alternative approaches

<!-- TODO: probably should be moved to a separate page about just CAT with a reference note left here -->

- **SHA256 streaming instead of `OP_CAT`:** the way CAT would usually be
  combined with CSFS is something like `signature data3 data2 data1
  data0 OP_CAT OP_CAT OP_CAT OP_SHA256 pubkey OP_CSFS`, which would
  combine the four pieces of data, create a 32-byte hash digest of them,
  and then verify that a signature for a particular pubkey signed that
  hash digest.

    This is simple to think about but it runs into some practical
    problems, most especially Bitcoin Script's requirement that any
    piece of data on the stack be 520 bytes or less.  If you CAT
    together two pieces of data that are over 520 bytes, the script
    fails.  This is a significant constraint when using CAT+CSFS
    requires replicating significant parts of a transaction (and the
    UTXOs it's spending) on the stack.  It can limit a transaction to 10
    or fewer inputs or outputs.

    However, it's possible to incrementally feed data to a separate
    buffer that will return a SHA256 hash digest of that data on return.
    For example, `signature data3 data2 data1 data0 OP_SHA256INITIALIZE
    OP_SHA256UPDATE OP_SHA256UPDATE OP_SHA256FINALIZE pubkey OP_CSFS`.
    This produces the same result as CAT but each data element may be up
    to 520 bytes in size and there's no limitation on their combined
    size.  An optimization here is that the buffer never needs to be
    larger than 96 bytes---64 bytes for the SHA256 working state and up
    to 32 bytes for the next chunk of data that the SHA256 algorithm
    will work producing the ultimate digest.  In short, SHA streaming
    circumvents a burdensome constraint and reduces the worst-case
    amount of memory a node would use to process a CAT-style script.

    The only known downsides of SHA streaming are slight: they're more
    conceptually complex than CAT, and the optimized way of implementing
    them requires lower-level access to the SHA256 hash function than
    may be available to some full node implementations without writing
    their own SHA256 code.

    SHA streaming is [implemented][elements shastream] in
    ElementsProject.org (the basis for Blockstream Liquid).

{% include references.md %}
[elements shastream]: https://github.com/ElementsProject/elements/blob/master/doc/tapscript_opcodes.md
