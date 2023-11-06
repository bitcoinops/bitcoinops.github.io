{:.post-meta}
*by [Antoine Poinsot][] from [Wizardsardine][]*

Our (practical) interest for miniscript started back in early 2020 when we were
designing [Revault][], a multiparty [vault][topic vaults] architecture only
using then available scripting primitives.

We initially showcased Revault using a fixed set of participants. We quickly ran
into issues as we tried to generalize it to more participants in a production
setting.

- Actually are we _sure_ the script we used in the demo is secure? Is it
possible to spend it in all the ways it's advertized to be? Is there no other
way of spending it than how it's advertized?
- Even if it is, how can we generalize it to various number of participants and
keep it secure? How can we apply some optimizations and make sure the resulting
script has the same semantics?
- In addition, Revault is using pre-signed transactions (to enforce spending
policies). How can we know in advance the budget to allocate for fee-bumping
given the configuration of the script? How can we make sure _any_ transaction
spending those scripts will pass the most common standardness checks?
- Finally, even assuming our scripts correspond to the intended semantics and
are always spendable, how can we _concretely_ spend them? As in how can we
produce a satisfying witness for ("sign for") each and every possible
configuration? How can we make hardware signing devices compatible with our
scripts?

These questions would have been a show stopper if it was not for miniscript. Two
guys in a garage are not going to write a software that [creates some script on
the fly, hope for the best][rekt lost funds] and on top of that call it a
security enhancing Bitcoin wallet. We wanted to start a company around the
development of Revault, but we wouldn't get funding without providing some
reasonable assurance to an investor we could bring a safe product to market. And
we wouldn't be able to solve all these engineering problems without funding.

[Enters miniscript][sipa miniscript], "a language for writing (a subset of)
Bitcoin Scripts in a structured way, enabling analysis, composition, generic
signing and more. [...] It has a structure that allows composition. It is very
easy to statically analyze for various properties (spending conditions,
correctness, security properties, malleability, ...)." This is exactly what we
needed. Armed with this powerful tool, we could give better guarantees [0] to
our investors, raise funds, and start the development of Revault.

At the time, miniscript was still far from being a turnkey solution for any
Bitcoin application developer to use. (If you are a new Bitcoin dev reading this
after the year 2023, yes, there was a time where we used to write Bitcoin
scripts BY HAND.) We had to integrate miniscript in Bitcoin Core (see PRs
[#24147][Bitcoin Core #24147], [#24148][Bitcoin Core #24148] and
[#24149][Bitcoin Core #24149]), which we used as the backend of the Revault
wallet, and convince signing devices manufacturers to implement it in their
firmware. The latter part would turn out to be the most difficult.

It was a chicken-and-egg problem: incentives were low for manufacturers to
implement miniscript with no demand from users. And we couldn't release Revault
without signing device support. Fortunately this cycle was eventually broken by
[Stepan Snigirev][] in March 2021 by [bringing][github embit descriptors]
[support][github specter descriptors] for miniscript descriptors to the [Specter
DIY][]. The Specter DIY was however for a long time disclaimed as being merely a
"functional prototype", and [Salvatore Ingala][] brought [miniscript to a
production-ready signing device][] for the first time in 2022 with the [new
Bitcoin app][ledger bitcoin app] for the Ledger Nano S(+). The app was released
in January 2023, allowing us to publish the [Liana wallet][] with support for
the most popular signing device.

One last development is left to wrap up our miniscript journey. [Liana][github
liana] is a Bitcoin wallet focused on recovery options. It lets one specify some
timelocked recovery conditions (for instance a third-party [recovery key that
cannot normally spend the funds][blog liana 0.2 recovery], or a
[decaying/expanding multisig][blog liana 0.2 decaying]). Miniscript was
initially only available for P2WSH scripts. Almost 2 years after [taproot][topic
taproot] activated, it's unfortunate that you would have to publish your
recovery spending paths onchain every time you spend. To this end, we have been
working to port miniscript to tapscript (see [here][github minitapscript] and
[here][Bitcoin Core #27255]).

The future is bright. With most signing devices either having implemented or in
the process of implementing miniscript support (for instance recently
[Bitbox][github bitbox v9.15.0] and [Coldcard][github coldcard 227]), along with
[taproot and miniscript native frameworks][github bdk] being polished,
contracting on Bitcoin with safe primitives is more accessible than ever.

It's interesting to note how the funding of Open Source tools and frameworks
lower the barrier to entry for innovative companies to compete and, more
generally, projects to be implemented. This trend accelerating in the past years
can make us hopeful about the future of the space.

[0] There was still risk, of course. But at least we were confident we could get
past the onchain part. The offchain one would prove to be (as expected) more
challenging.

{% include references.md %}
{% include linkers/issues.md v=2 issues="24147,24148,24149,27255" %}
[Antoine Poinsot]: https://twitter.com/darosior
[Wizardsardine]: https://wizardsardine.com/
[Revault]: https://wizardsardine.com/revault
[rekt lost funds]: https://rekt.news/leaderboard/
[sipa miniscript]: https://bitcoin.sipa.be/miniscript
[Stepan Snigirev]: https://github.com/stepansnigirev
[github embit descriptors]: https://github.com/diybitcoinhardware/embit/pull/4
[github specter descriptors]: https://github.com/cryptoadvance/specter-diy/pull/133
[Specter DIY]: https://github.com/cryptoadvance/specter-diy
[Salvatore Ingala]: https://github.com/bigspider
[ledger bitcoin app]: https://github.com/LedgerHQ/app-bitcoin-new
[Liana wallet]: https://wizardsardine.com/liana/
[github liana]: https://github.com/wizardsardine/liana
[blog liana 0.2 recovery]: https://wizardsardine.com/blog/liana-0.2-release/#trust-distributed-safety-net
[blog liana 0.2 decaying]: https://wizardsardine.com/blog/liana-0.2-release/#decaying-multisig
[github minitapscript]: https://github.com/sipa/miniscript/pull/134
[github bitbox v9.15.0]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware%2Fv9.15.0
[github coldcard 227]: https://github.com/Coldcard/firmware/pull/227
[github bdk]: https://github.com/bitcoindevkit/bdk