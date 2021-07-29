{% auto_anchor %}
Almost two years ago, James Chiang and Elichai Turkel produced an [open source
repository][taproot-workshop] of Jupyter notebooks for a series of
Optech workshops to train developers on [taproot][topic taproot] technology.
Workshops [held][workshops] in San Francisco, New York City, and London
received positive reviews, but travel restrictions prevented subsequent
in-person workshops.

Since the publication of the Jupyter notebooks, taproot underwent
several changes.  However, taproot support was also merged into Bitcoin
Core, allowing the notebooks to drop their dependency on a custom branch
of Bitcoin Core.  Developer Elle Mouton has kindly [updated][mouton
tweet] the [notebooks][notebooks #168] for all those changes, making
them again a great way to quickly build hands-on experience working with
taproot's algorithms and data types.

The notebooks are divided into four sections:

- **Section 0** contains a notebook that helps you set up your
  environment, covers the basics of elliptic curve cryptography, and
  teaches you about the tagged hashes used throughout BIPs
  [340][BIP340], [341][BIP341], and [342][BIP342].

- **Section 1** walks you through creating [schnorr signatures][topic
  schnorr signatures].  Once you've mastered them, you learn how to
  create [multisignatures][topic multisignature] with the [MuSig][topic
  musig] protocol.

- **Section 2** gives you experience with every aspect of taproot.  It
  starts with a review of the principles of segwit v0 transactions and then
  helps you create and send segwit v1 (taproot) transactions.  Applying
  the knowledge from section 1, you then create and spend a taproot
  output using MuSig.  The concept of key tweaking is introduced and you
  learn how taproot allows you to use its public key to commit to data.
  Now that you can create commitments, you learn about [tapscripts][topic
  tapscript]---how they differ from legacy and segwit v0 script, and how
  to commit to a tree of tapscripts.  Finally, a short notebook
  introduces huffman encoding for creating optimal script trees.

- **Section 3** provides an optional exercise in creating a taproot
  output that changes which signatures are required the longer the
  output goes unspent---allowing the output to be efficiently spent
  under normal circumstances but also providing for a robust backup in
  case of problems.

The notebooks include numerous programming exercises that are relatively
easy but which will ensure that you actually learned the material
presented.  The author of this column, who is no great coder, was able
to complete the notebooks in six hours and only regretted that he had not
taken the time to learn from them earlier.

{% include references.md %}
[taproot-workshop]: https://github.com/bitcoinops/taproot-workshop
[workshops]: /en/schorr-taproot-workshop/
[notebooks #168]: https://github.com/bitcoinops/taproot-workshop/pull/168
[mouton tweet]: https://twitter.com/ElleMouton/status/1418108253096095745
{% endauto_anchor %}
