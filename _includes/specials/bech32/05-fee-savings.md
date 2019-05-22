One reason your users and customers may want you to implement bech32
sending support is because it'll allow the receivers of those payments
to save on fees when they re-spend that money.  This week, we'll look at
how much money they'll save and discuss how their savings could also
help you save money.

For the legacy P2PKH address format implemented in the first version of
Bitcoin, the scriptSig that authorizes a spend is typically 107 vbytes.
For P2SH-wrapped segwit P2WPKH, this same information is moved to a
witness data field that only consumes 1/4 as many vbytes (27 vbytes) but
whose P2SH overhead adds 23 vbytes for a total of 50 vbytes.  For native
segwit P2WPKH, there's no P2SH overhead, so 27 vbytes is all that's used.

This means you could argue that P2SH-P2WPKH saves over 50% compared to
P2PKH, and that P2WPKH saves another almost 50% compared to P2SH-P2WPKH
or 75% compared to P2PKH alone.  However, spending transactions contain
more than just scriptSigs and witness data, so the way we usually
compare savings is by looking at prototype transactions.  For example,
we imagine a typical transaction containing a single input and two
outputs (one to the receiver; one as change back to the spender).  In
that case:

- Spending P2PKH has a total transaction size of
  220 vbytes
- Spending P2SH-P2WPKH has a size of 167 vbytes (24% savings)
- Spending P2WPKH output has a size of 141 vbytes (16% savings vs
  P2SH-P2WPKH or 35% vs P2PKH)

To compare simple multisig transactions (those that just use a single
`OP_CHECKMULTSIG` opcode), things get more complex because k-of-n
multisig inputs vary in size depending on the number of signatures (k)
and the number of public keys (n).  So, for simplicity's sake, we'll
just plot the sizes of legacy P2SH-multisig compared to wrapped P2SH-P2WSH
multisig (up to the maximum 15-of-15 supported by legacy P2SH).  We can
see that switching to P2SH-P2WSH can save from about 40% (1-of-2
multisig) to about 70% (15-of-15).

![Plot of multisig transaction sizes with P2SH and P2SH-P2WSH](/img/posts/2019-04-segwit-multisig-size-p2sh-to-p2sh-p2wsh.png)

We can then compare P2SH-P2WSH to native P2WSH to see the additional
constant-sized savings of about 35 bytes per transaction or about 5% to
15%.

![Plot of multisig transaction sizes with P2SH-P2WSH and P2WSH](/img/posts/2019-04-segwit-multisig-size-p2sh-p2wsh-to-p2wsh.png)

The scripts described above account for almost all scripts being used
with addresses that aren't native segwit.  (Users of more complex
scripts, such as those used in LN, are mostly using native segwit today.)
Those less efficient script types currently consume a majority fraction
of block capacity (total block weight).  Switching to native segwit in
order to reduce a transaction's weight allows you to reduce its fee by
the same percentage without changing how long it'll take to confirm---all other
things being equal.

But all other things aren't equal.  Because the transactions use less
block weight, there's more weight available for other transactions.  If
the supply of available block weight increases and demand remains constant, we
expect prices to go down (unless they're already at the default minimum
relay fee).  This means more people spending native segwit inputs lowers
the fee not just for those spenders but for everyone who creates
transactions---including wallets and services that support sending to
bech32 addresses.
