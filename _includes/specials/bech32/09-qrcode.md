[BIP173][] forbids bech32 addresses from using mixed case.  The
preferred way to write a bech32 address is in all lowercase, but there's
one case where all uppercase makes sense: QR codes.  Take a look at the
following two QR codes for the same address with the only difference
being lowercase versus uppercase:

![bech32 uppercase](/img/posts/2019-05-bech32-qr-uc.png)
{:.center}

This is a deliberate design feature of bech32.  QR codes can be created
in several modes that support different character sets.
The binary mode character set is used for legacy addresses because they
require mixed case.  However, Bech32 addresses for Bitcoin[^only-bc] can
be represented using only numbers and capital letters, so they can use
the smaller uppercase alphanumeric character set.  Because this set is
smaller, it uses fewer bits to encode each character in a QR code,
allowing the resultant code to be less complex.

Bitcoin addresses are often used in [BIP21][] URIs.  BIP21 technically
requires base58check formatting, but at least some wallets that support
native segwit addresses (such as Bitcoin Core) allow them to be used
with bech32.  Although the preferred form of BIP21's scheme identifier
`bitcoin:` is lowercase, it can also be uppercased as allowed by both
BIP21 and [RFC3986][].  This also produces a less complex image
(although in this case, our QR encoding library gave both images the
same dimensions).

![bech32 uppercase](/img/posts/2019-05-bip21-bech32-qr-uc.png)
{:.center}

Unfortunately, the `?` and `&` needed for passing additional parameters
in a BIP21 URI are not part of the QR code uppercase character set, so
only binary mode can be used for those characters.  Additionally, BIP21 specifies that query
parameter names such as `amount` and `label` are case sensitive, so
uppercase versions of them aren't expected to work anyway.

{:#qrcode-edit}
However, QR codes can support mixed character sets and doing so will
always be at least slightly more efficient when used with a string that
either begins or ends with an all-caps substring containing a bech32
address.  This is because the minimum allowed size of a bech32 address
(14 characters) combined with the efficiency gain from using uppercase
mode (31.25%) exceeds the worst-case overhead of switching modes (20
extra bits).  At least two QR code encoders we're aware of,
[libqrencode][] (C) and [node-qrcode][] (JS), automatically mix
character sets by default as necessary to produce the least-complex QR
code possible:

![BIP21/bech32 mixed character mode](/img/posts/2019-05-bip21-bech32-qr-mixed.png)
{:.center}

In summary, when using bech32 addresses in QR codes, consider
uppercasing them and any other adjacent characters that can be
uppercased in order to produce smaller and less complex QR codes.
(However, for all other purposes, bech32 addresses should use all
lowercase characters.)

*Correction:* an earlier version of this section claimed that QR codes
which included BIP21 query parameters needed to use binary mode.  Nadav Ivgi
kindly [informed us][ivgi tweet] that it was possible to mix character
modes, and we've updated the final two paragraphs of this section
accordingly.

[bech32 easy]: {{news38}}#bech32-sending-support
[rfc3986]: https://tools.ietf.org/html/rfc3986#section-3.1
[ivgi tweet]: https://twitter.com/shesek/status/1131733590235131905
[node-qrcode]: https://github.com/soldair/node-qrcode#mixed-modes
[libqrencode]: https://fukuchi.org/works/qrencode/

[^only-bc]:
    Bech32 addresses have three parts, a Human Readable Prefix (HRP)
    such as `bc`, a separator (always a `1`), and a data part.  The
    separator and the data part are guaranteed to be part of QR code's
    *uppercase alphanumeric* set, but the range of characters allowed in
    the HRP according to BIP173 includes punctuation that isn't part of
    that uppercase alphanumeric set.  Specifically, the following
    characters are allowed in bech32 HRPs but are not part of the QR
    code uppercase alphanumeric set:

        !"#&'()';<=>?@[\]^_`{|}~

    None of the bech32 HRPs used in Bitcoin (bc, tb, bcrt) use any of
    these characters, and neither does any other application as far as
    we know.  However, you may not want to make any assumptions in your
    code about uppercase always providing smaller QR codes for
    non-Bitcoin bech32 addresses.
