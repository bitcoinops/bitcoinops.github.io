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
only binary mode can be used.  Additionally, BIP21 specifies that query
parameter names such as `amount` and `label` are case sensitive, so
uppercase versions of them aren't expected to work anyway.

Still, anywhere you want to display just an address in a QR code, you
should consider using all-uppercase for bech32 addresses and [bech32-like
addresses][News 44 bech32].

[bech32 easy]: {{news38}}#bech32-sending-support
[rfc3986]: https://tools.ietf.org/html/rfc3986#section-3.1
[news 44 bech32]: {{news44}}#bech32-sending-support

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
