{% auto_anchor %}As of this writing, here are what we think are some of the most
significant bech32-related insights we've gleaned from creating and
reviewing the [Compatibility Matrix][].

- **Most tools support paying bech32 addresses:** 74% of the wallets and
  services surveyed support paying to segwit addresses.  Although this
  isn't the near-universal support we'd like to see, it may be enough
  support that we'll soon see more wallets switching to bech32 receiving
  addresses by default.

- **Supporting P2WPKH but not P2WSH:** when we started testing various
  apps, we assumed "bech32 sending support" would be binary---either a
  tool supported it or not.  However, one service we surveyed supports
  spending money to native segwit (bech32) P2WPKH addresses but not
  bech32 P2WSH addresses.  This led us to tracking the two different
  segwit version 0 addresses separately.  (If you're a developer, please
  support sending to both address types.)

- **Address input field length restrictions:** some services might have
  supported sending to bech32 addresses, but when we attempted to enter
  a bech32 address, either it was rejected as being too long or the field
  simply refused to accept all the characters.  (Reminder, [BIP173][]
  says this about the lengths of Bitcoin mainnet bech32 addresses:
  they "are always between 14 and 74 characters long [inclusive],
  and their length modulo 8 cannot be 0, 3, or 5.")

- **Screenshots of input fields:** we documented the steps we took to
  try sending to bech32 addresses, which gives us a large collection of
  screenshots that UI designers can review for best practices when
  implementing their own bech32 sending support (or other features, such
  as RBF support).

- **Lack of bech32 change address support:** because sending to bech32
  addresses is still not universally supported, it makes sense for
  segwit-compatible wallets to generate P2SH-wrapped segwit receiving
  addresses by default.  However, many of these wallets also use
  P2SH-wrapped segwit addresses for receiving change sent from
  themselves to themselves.  In some cases, this may have been done for
  privacy benefits (e.g.  Bitcoin Core currently tries to match the type
  of change output to the type of payment output) but, in most cases,
  this seems like a missed opportunity for wallets to send change to
  their own bech32 addresses for increased fee savings.
{% endauto_anchor %}
