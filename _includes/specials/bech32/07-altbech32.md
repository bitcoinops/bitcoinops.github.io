{% auto_anchor %}
It's said that "imitation is the most sincere form of flattery."  In
this week's section, we take a quick look at a few other systems that
are using variations on bech32.  If you're already going to need to
implement something that's basically bech32 for another project, it's
probably worth your time to implement it for Bitcoin too.

- **LN invoices** use the bech32 format with an extended Human-Readable
  Part (HRP) and without bech32's normal 90-character limit.  See
  [BOLT11][] for the full specification.  Example:
  `lnbc2500u1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqdq5xysxxatsyp3k7enxv4jsxqzpuaztrnwngzn3kdzw5hydlzf03qdgm2hdq27cqv3agm2awhz5se903vruatfhq77w3ls4evs3ch9zw97j25emudupq63nyw24cg27h2rspfj9srp`

- **Bitcoin Cash new-style addresses** use the bech32 format with the
  HRP `bitcoincash` and the separator `:`.  Instead of the version byte
  encoding a segwit witness version, as in Bitcoin, it indicates whether
  the hash encoded by the address should be used with P2PKH or P2SH.  See
  [spec-cashaddr][] for the full specification.  Example:
  `bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a`

- **Backup seeds:** In June 2018, Jonas Schnelli proposed Bech32X, a
  scheme to encode Bitcoin private keys, extended private keys (xprivs),
  and extended public keys (xpubs) using bech32 for error correction.
  See the full [draft specification][bech32x].  Example:
  `pk1lmll7u25wppjn5ghyhgm7kndgjwgphae8lez0gra436mj7ygaptggl447a4xh7`

- **Elements-based sidechains:** sidechains based on
  [ElementsProject.org][], such as [Blockstream Liquid][], use both
  bech32 address and a variation of them called "blech32" addresses.
  Blech32 addresses are intended for use with that platform's
  [confidential assets][] and will soon be supported by the Esplora
  block explorer for the Liquid sidechain.  We're
  unaware of a specification document for blech32, but [this
  code][blech32 py] is labeled as the reference implementation and is
  cited elsewhere in the project as, "See liquid_addr.py for compact
  difference from bech32." Example of a blech32 address:
  `lq1qqf8er278e6nyvuwtgf39e6ewvdcnjupn9a86rzpx655y5lhkt0walu3djf9cklkxd3ryld97hu8h3xepw7sh2rlu7q45dcew5`

- **Output script descriptors:** although less directly related to
  bech32, checksums based on the same Bose-Chaudhuri-Hocquenghem (BCH) codes used in bech32 were
  added to the [output script descriptors][] supported by Bitcoin Core.
  See Pieter Wuille's [detailed comment][descriptors checksum].
  Example:
  `wpkh([f6bb4c63/0'/0'/28']02bf9d38386db60191f2f785cbf7ba90d01bed5958efb7b449a552b89da7550177)#efkksxw6`

[descriptors checksum]: https://github.com/bitcoin/bitcoin/blob/fd637be8d21a606e98c037b40b268c4a1fae2244/src/script/descriptor.cpp#L24
[spec-cashaddr]: https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/cashaddr.md
[bech32x]: https://gist.github.com/jonasschnelli/68a2a5a5a5b796dc9992f432e794d719
[elementsproject.org]: https://elementsproject.org/
[blockstream liquid]: https://blockstream.com/liquid/
[confidential assets]: https://elementsproject.org/features/confidential-transactions
[blech32 py]: https://github.com/ElementsProject/elements/commit/9cb2fa051fcbe0fe66f15e6b88d224d1935376f4#diff-265badc7e18059096c32a61b0eada470
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
{% endauto_anchor %}
