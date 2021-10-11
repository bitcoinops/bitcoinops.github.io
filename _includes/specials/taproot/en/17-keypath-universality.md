{% auto_anchor %}

The [original taproot proposal][maxwell taproot] by Gregory Maxwell suggested an
interesting principle for contract design:

> "It is almost always the case that interesting scripts have a logical
> top level branch which allows satisfaction of the contract with
> nothing other than a signature by all parties.  Other branches would
> only be used where some participant is failing to cooperate. More
> strongly stated, I believe that _any_ contract with a fixed finite
> participant set upfront can be, and should be, represented as an OR
> between an N-of-N and whatever more complex contract you might want to
> represent." (emphasis in original)

Since then, [experts][irc log1] have [debated][irc log2] the
universality of this principle, with two possible exceptions we're aware
of being focused on timelocks:

- **Consensus augmented self-control:** some people have used
  [timelocks][topic timelocks] to prevent themselves from spending their
  own bitcoins for a period of time.  The timelock requirement seems to
  suggest that more than a signature is required, but a few criticisms
  have been raised:

    - Someone truly desperate to spend their timelocked bitcoins can take
      out a loan, perhaps secured by some other asset.  This undermines
      the utility of this self contract.

    - In addition to the consensus-enforced scriptpath timelock, the user
      can allow keypath spending between their key and the key of a
      third party who only signs when the timelock has expired.  This is
      not only more efficient, but it also allows implementing a more
      flexible spending policy such as providing the user the ability to
      sell any forkcoins they receive or to work with a third party who
      will allow them to spend early in case of major life changes or
      price appreciations.

- **Vaults:** as mentioned in Antoine Poinsot's [column][p4tr vaults]
  here a few weeks ago, [vaults][topic vaults] also use timelocks
  extensively to help protect funds, which seems "contrary to the
  insight of taproot that most contracts have a happy path where all
  participants collaborate with a signature."  Others have argued <!--
  see gmaxwell and kanzure in IRC logs linked above --> that there's no
  case where the vault user wouldn't want an option to escape the
  vault's conditions through a keypath spend, and that because it costs
  nothing to add a keypath option to a contract created for scriptpaths,
  it would be strictly superior to enable a keypath.

The argument against always providing a keypath option seems to be that
there are cases even when all the signers acting together don't trust
themselves.  They instead trust other people---the operators of economic
full nodes who enforce Bitcoin's consensus rules---to enforce
restrictions on the signers spending ability which the signers are
unwilling to enforce themselves.

The counterpoint is that, at least purely in theory, you can create a
keypath spend between the regular signers and all those economic full
node operators to obtain the same security.  More practically, there's
probably some subset or alternative set of those node operators who can
be added to your keypath multisig set who will enforce the policy you
want, if they're available (and, if they aren't, you've lost nothing
since you can still use the scriptpath spend).

Theory aside, we recommend taking some extra time to consider whether
there's an opportunity to use a keypath spend in a taproot-based
contract even when it doesn't seem like an option.

{% endauto_anchor %}

[p4tr vaults]: /en/preparing-for-taproot/#vaults-with-taproot
[maxwell taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[irc log1]: https://gnusha.org/taproot-bip-review/2020-02-09.log
[irc log2]: https://gnusha.org/taproot-bip-review/2020-02-10.log
