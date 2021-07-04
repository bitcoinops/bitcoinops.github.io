[Output script descriptors][topic descriptors] provide a generic way for
wallets to store the information needed to create addresses, efficiently
scan for outputs paying those addresses, and later spend from those
addresses.  In addition, descriptors are reasonably compact and contain
a basic checksum, making them convenient for backing up address
information, copying it between different wallets, or sharing it between
wallets that are cooperating to provide multiple signatures.

Although descriptors are currently only used by a few projects, they and
the related [miniscript][topic miniscript] project have the potential to
significantly improve interoperability between different wallets and
tools.  This will become increasingly important as more users take
advantage of the benefits of taproot to improve their security through
[multisignatures][topic multisignature] and their resiliency through
backup spending conditions.

Before that can happen, descriptors need to be updated to work with
taproot.  That was the subject of the recently merged [Bitcoin Core #22051][]
pull request.  The syntax has been designed to allow a single descriptor
template to provide all the information necessary to use both P2TR
keypath spends and script path spends.  For simple single-sig, the
following descriptor is sufficient:

    tr(<key>)

The same syntax may also be used for multisignatures and [threshold
signatures][topic threshold signature].  For example, Alice, Bob, and
Carol aggregate their keys using [MuSig][topic musig] and then pay to
`tr(<combined_key>)`.

Unintuitively, the `key` specified by `tr(<key>)` won't be the key encoded
in the address.  The `tr()` descriptor follows a [safety recommendation][bip341 safety]
from BIP341 to use an internal key that commits to an unspendable
script tree.   This eliminates an attack against users of naive key
aggregation schemes (more advanced schemes such as [MuSig][topic musig]
and MuSig2 are not affected).

For scriptpath spending, a new syntax is added that allows specifying
the contents of a binary tree.  For example, `{ {B,C} , {D,E} }`
specifies the following tree:

    Internal key
        / \
       /   \
      / \ / \
      B C D E

A tree can be specified as an optional second parameter to the
descriptor template we used before.  For example if Alice wants to be
able to spend via keypath, but she also wants to allow Bob, Carol, Dan,
and Edmond spend via a scriptpath that generates an audit trail for
her (but not for third-party chain surveillance), Alice can use the
following descriptor:

    tr( <a_key> , { {pk(<b_key>),pk(<c_key>)} , {pk(<d_key>),pk(<e_key>)} )

The above features are all that's required to use
descriptors for taproot, but PR #22051 notes that there are still some
things missing that could be added to make descriptors better at
completely describing expected policies:

- **Voided keypaths:** some users may want to prevent usage of keypath
  spending in order to force scriptpath spending.  That can be done now
  by using an unspendable key as the first parameter to `tr()`, but it'd
  be nice to allow wallets to store this preference in the descriptor
  itself and have it compute a privacy-preserving unspendable keypath.

- **Tapscript multisig:** for legacy and v0 segwit, the `multi()` and
  `sortedmulti()` descriptors support the
  `OP_CHECKMULTISIG` opcode.  To allow batch verification in taproot,
  script-based multisig is handled a bit differently in tapscript, so
  `tr()` descriptors currently need to specify any necessary multisig
  opcodes via a `raw()` script.  Updated versions of `multi()` and
  `sortedmulti()` for tapscripts would be nice to have.

- **MuSig-based multisignatures:** earlier in this article, we described
  Alice, Bob, and Carol manually aggregating their keys in order to use
  a `tr()` descriptor.  Ideally, there would be a function that allows
  them to specify something like `tr(musig(<a_key>, <b_key>, <c_key>))`
  so that they could retain all the original key information and use it
  to populate fields in the [PSBTs][topic psbt] they use to coordinate
  signing.

- **Timelocks, hashlocks, and pointlocks:** these powerful constructions
  used in LN, [DLCs][topic dlc], [coinswaps][topic coinswap], and many
  other protocols can currently only be described via the `raw()`
  function.  Adding support for them directly to descriptors is
  possible, but it may be the case that support will be added instead
  through descriptor's sibling project, [miniscript][topic miniscript].
  Integration of miniscript into Bitcoin Core is still an ongoing
  project, but we expect its innovations to spread to other wallets in
  the same way that tools like PSBTs and descriptors already have.

Wallets don't need to implement descriptors in order to start using
taproot, but those that do will give themselves a better foundation for
using more advanced taproot features later.

{% include linkers/issues.md issues="22051" %}
[bip341 safety]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-22
