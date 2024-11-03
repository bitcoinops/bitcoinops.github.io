In [last week's column][taproot series vaults], Antoine Poinsot described how taproot
can make [vault][topic vaults]-style coin backup and security schemes
more private and fee efficient.  In this week's column, we'll look
at several other backup and security schemes that are improved by
converting to taproot.

- **Simple 2-of-3:** as [mentioned][threshold signing] in a previous
  week, it's easy to use a combination of [multisignatures][topic
  multisignature] and scriptpath spends to create a 2-of-3 spending
  policy that's normally just as efficient onchain as a single-sig spend
  and which is much more private than current P2SH and P2WSH multisigs.
  It's still fairly efficient and private in the abnormal cases as well.
  This makes taproot great for upgrading your security from a
  single-signer wallet to a multi-signer policy.

  We expect future techniques for [threshold signatures][topic
  threshold signature] to further improve 2-of-3 and other k-of-n
  cases.

- **Degrading multisignatures:** one of the exercises in the [Optech
  Taproot Workshop][taproot workshop] allows you to experiment with
  creating a taproot script that can be spent at any time by three keys,
  or after three days with two of the original keys, or after ten days
  with only one of the original keys.  (That exercise also uses backup
  keys, but we'll cover that separately in the next point.)  Tweaking
  the time parameters and the key settings provides you with a flexible
  and powerful backup construct.

  For example, imagine you can normally spend using a combination of
  your laptop, mobile phone, and a hardware signing device.  If one of
  those becomes unavailable, you can wait a month to be able to spend
  with the remaining two devices.  If two devices become unavailable,
  you can spend using just one after six months.

  In the normal case of using all three devices, your onchain script
  is maximally efficient and private.  In the other cases, it's a bit
  less efficient but may still be reasonably private (your script and
  its tree depth will look similar to the scripts and depths used in
  many other contracts).

- **Social recovery for backups and security:** the example above is
  great at protecting you if one of your devices gets stolen by an
  attacker, but what happens if two of your devices are stolen?  Also,
  if you frequently use your wallet, do you really want to wait even a
  month before you can start spending again after losing a device?

  Taproot makes it easy, cheap, and private to add a social element to
  your backups.  In addition to the scripts in the previous example,
  you can also allow immediate spending of your bitcoins with two of
  your devices plus signatures from two of your friends or family
  members.  Or immediate spending with only a single one of your keys
  plus signatures from five people you trust.  (A similar non-social
  version of this would simply be using extra devices or seed phrases
  you have stored in secure locations.)

- **Combining time and social thresholds for inheritance:** combining
  the techniques above, you can allow someone or a group of people to
  recover your funds in case you suddenly die or become incapacitated.
  For example, if you haven't moved your bitcoins for six months, you
  can allow your lawyer and any three of your five most trusted
  relatives to spend your coins.  If you normally move your bitcoins
  every six months anyway, this inheritance preparation has no added
  onchain cost for as long as you live and is completely private from
  outside observers.  You can even keep the transactions you make
  private from your lawyer and family as long as you have a reliable way
  for them to learn your wallet's extended public key (xpub) after your
  death.

  Please note that making it possible for your heirs' to spend your
  bitcoins doesn't mean that they'll be able to spend those coins
  legally.  We recommend that anyone planning to pass on Bitcoins read
  *Cryptoasset Inheritance Planning* by Pamela Morgan ([physical book
  and DRM'd ebook][cip amazon] or [DRM-free ebook][cip aantonop]) and
  use its information to discuss details with a local expert in estate
  planning.

- **Compromise detection:** an idea [proposed][tree signatures] prior to
  the invention of taproot is to put a key controlling some amount of
  bitcoin on all of the devices you care about as a way of detecting
  when the device has been compromised.  If the amount of bitcoin is
  large enough, the attacker will probably spend it to themselves for
  the immediate gain rather than wait to use their illicit access in a
  long-term attack that might cause you more overall harm.

  A problem with this approach is that you want to make the amount of
  bitcoin offered large enough to entice the attacker but you don't
  want to put large amounts of bitcoin on every one of your
  devices---you'd prefer to offer only one large bounty.  However, if
  you were to put the same key on every device, the attacker
  transaction spending the bitcoin wouldn't reveal which device was
  compromised.  Taproot makes it easy to put a different key with a
  different scriptpath on every device.  Any one of those keys
  will be able to spend all the funds controlled by that address, but
  it can also uniquely identify to you which device was compromised.

[taproot series vaults]: /en/preparing-for-taproot/#vaults-with-taproot
[cip amazon]: https://amazon.com/Cryptoasset-Inheritance-Planning-Simple-Owners/dp/1947910116
[cip aantonop]: https://aantonop.com/product/cryptoasset-inheritance-planning-a-simple-guide-for-owners/
[tree signatures]: https://blockstream.com/2015/08/24/en-treesignatures/#h.2lysjsnoo7jd
[threshold signing]: /en/preparing-for-taproot/#threshold-signing
[taproot workshop]: https://github.com/bitcoinops/taproot-workshop
