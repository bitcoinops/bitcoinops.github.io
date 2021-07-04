Starting at block {{site.trb}}, expected in November, Bitcoin users will be
able to safely receive payments to taproot  addresses.  Given the
user enthusiasm for taproot and the five months that wallet
developers have to implement support for it, Optech expects there to be
several popular wallets that will allow their users to generate taproot
addresses at the earliest possible moment.

That means any other wallet or service that sends bitcoins to
user-provided addresses needs to be able to send to taproot addresses by
block {{site.trb}} or risk confusing and disappointing its users.  Pay
to TapRoot (P2TR) addresses use [bech32m][topic bech32] as specified in [BIP350][], which
is slightly different than [BIP173][]'s bech32 algorithm used for segwit
v0 P2WPKH and P2WSH addresses.  Bech32m uses the constant
`0x2bc830a3` instead of bech32's `0x01` in the checksum function.

Changing that single constant provides the
ability to verify bech32m checksums, but the code still needs to use the original constant for existing
P2WPKH and P2WSH addresses.  The code needs to decode the address
without verifying the checksum, determine whether it uses v0 segwit (bech32) or
v1+ segwit (bech32m), and then validate the checksum with the appropriate
constant.  For examples, see the [PR][bech32#56] that updated the bech32
reference implementations for C, C++, JS, and Python.  If the code already
uses the reference libraries, they can be updated to the latest code from
that repository, although note that some of the APIs have slight
changes.  BIP350 and the reference implementations provide test vectors
that all bech32m implementations should use.

Although *receiving* payments to taproot addresses won't be safe until
block {{site.trb}}, *sending* payments should not cause any problems for the
sender.  Bitcoin Core has supported relaying and mining transactions
with taproot-paying outputs since version 0.19 (released November 2019).
Optech encourages developers of wallets and services to implement
support for paying bech32m taproot addresses now rather than waiting
until after taproot activates.

[bech32#56]: https://github.com/sipa/bech32/pull/56
