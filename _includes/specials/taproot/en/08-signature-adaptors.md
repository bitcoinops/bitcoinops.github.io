Imagine someone offers to donate 1,000 BTC to a particular charity if
anyone can guess that person's favorite very large number.  An easy way for the donor
to do this is to create an unsigned transaction paying the 1,000 BTC and
then publish an encrypted copy of their signature for the transaction,
with the favorite number being the decryption key.

In theory, anyone who guesses the number can decrypt the signature and
then broadcast the transaction, paying the charity.  But if the donor
uses a standard encryption scheme like AES, there's no easy way for
third parties to know before decryption that the signature is actually
valid for that transaction.  Anyone who wants to put effort into
number guessing has to trust that the donor is sincere and not a
troll.

Let's extend this problem a bit further.  Third parties Alice
and Bob want to bet on whether or not the signature is revealed.
They could perhaps ask the signer for the hash of the signature and use
that as the hash in an [HTLC][topic htlc] function, but that again
requires trusting the donor to act honestly.  Even if the signature was
eventually revealed, the donor could sabotage Alice and Bob's contract
by giving them an incorrect hash.

### Adaptor magic

[Signature adaptors][topic adaptor signatures], also commonly called
*adaptor signatures* and *one-time verifiably encrypted signatures*, are
a solution to these problems---and to many other problems actually faced
today in production systems built on Bitcoin.  Although
usable with Bitcoin's existing ECDSA signature scheme, it's much easier
to use adaptors privately and costlessly in combination with the
[BIP340][] implementation of [schnorr signatures][topic schnorr
signatures] for taproot.  Let's see how our example above changes if we
use adaptors.

As before, the donor prepares a 1,000 BTC transaction.  They sign in
almost the normal way, with the one difference being that they
essentially generate their nonce in two parts: a true random nonce that
they will forever keep secret, and their favorite number---which they'll
initially keep secret but which is safe for other people to discover.
The donor generates a fully valid signature using both of these values,
adding them together as if they were a single nonce.

BIP340 signature commitments use the nonce in two forms: a numeric
representation (called a *scalar*), which normally only the signer
knows, and as a *point* on the Elliptic Curve (EC), which is published
to enable verification.

The donor takes the commitment part of their valid signature and
subtracts out the hidden scalar.  This makes the signature incomplete
(and thus invalid) but allows the donor to share the (invalid) signature
commitment, the (valid) point for the complete nonce, and the (valid)
point for the hidden number.  Together these three pieces of information
are a *signature adaptor*.

Using a slight variant on the BIP340 signature verification algorithm,
anyone can verify that the signature adaptor would provide a valid signature
if the hidden scalar was simply added back in to the (currently invalid)
signature commitment.  This is possible to verify even without knowing
what that hidden number is.  In short, it is now possible for users to
trustlessly begin making guesses about the value of hidden scalar,
secure in the knowledge that a correct guess will allow them to get the
signature and send the transaction.

Like everyone else who received the donor's signature adaptor, Alice and
Bob now have a copy of the EC point for the hidden number.  Also like
everyone else, they don't know the actual scalar.  But, if you recall,
all the donor did to turn their valid signature into an invalid
signature is subtract out the hidden number from their signature
commitment while continuing to have the signature commit to the point
of the hidden number.  Alice can just as easily create an invalid
signature by not committing to the scalar she doesn't know but still
committing to the EC point she does know.  She does this by creating her
own nonce pair, using the private form when creating her (invalid)
signature but commiting to the aggregation of the public form of her
nonce and the EC point from the donor's signature adaptor.
This produces a
signature adaptor for a transaction that pays Bob.  If Bob learns the
scalar, he can convert that adaptor into a valid signature and send the
transaction, winning the bet.

But how does Bob learn the winning number?  Does he have to wait for
someone else who guesses it to publish a press release?  Nope.  Recall
one more time that the signature adaptor the donor published was their
actual signature minus the scalar.  When the hidden number is discovered
and somebody sends the 1,000 BTC transaction, they must publish the
original (valid) signature commitment.  Bob can take that (valid)
signature commitment and subtract from it the (invalid) signature
commitment in the original signature adaptor to get the scalar.  He then
uses that scalar to convert Alice's adaptor into a valid signature.

### Multisignature adaptors

The previous section shows individual users modifying how they
create their signatures to produce signature adaptors.  It's also
possible for the parties to a [multisignature][topic multisignature] to
use the same trick.  That's extraordinarily useful, as many cases where
signature adaptors will be used require the cooperation of two users.

For example, when Alice and Bob make the bet above, they might start by
depositing funds into a script only spendable by a multisignature
between them.  Then Alice can produce her partial signature in the form
of a signature adaptor; if Bob learns the hidden number, he can
transform Alice's adaptor into her valid partial signature and then
provide his partial signature to produce a full signature spending the
money.

This gives signature adaptors all the same advantages of multisignatures
in general: they look like and use the same amount of space as a single
signature, minimizing fees and maximizing privacy and fungibility.

In next week's *preparing for taproot* column, we'll explore one of the
main ways we expect to see signature adaptors used: Point Time Locked
Contracts ([PTLCs][topic ptlc]), an upgrade for the venerable Hash Time
Lock Contracts ([HTLCs][topic htlc]) used extensively in LN, coinswaps,
and a number of other protocols.
