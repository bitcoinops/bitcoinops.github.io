{% auto_anchor %}
This segment marks half-way through our series about bech32, so we decided to
have some fun this week by describing some bech32-related trivia that's
interesting but not important enough for its own segment.

- **How is bech32 pronounced?** Pieter Wuille, co-author of the proposal, uses a
  soft "ch" so that the word sounds like ["besh thirty two"][wuille bech32].
  The name is a portmanteau that mixes the letters of the address's error
  correction coding (BCH) into the name of its numeric base (base32).
  Pronouncing it with a soft "ch" allows the first syllable of *bech32* to be
  similar to Bitcoin's legacy address format, *base58*.  We admit this extended
  explanation ruins the joke, but it's a clever and amusing bit of wordplay.

- **BCH has nothing to do with Bitcoin Cash's ticker code:** the name of the
  BCH codes bech32 is based upon are an abbreviation for
  [Bose-Chaudhuri-Hocquenghem][wikipedia bch], with Hocquenghem inventing this
  type of cyclic codes in 1959 followed by Bose and Ray-Chaudhuri independently
  rediscovering them in 1960.  Moreover, the bech32 address format was announced
  in March 2017, three months before the [first plans][] for what would later be
  labeled Bitcoin Cash (which initially planned to use the ticker code *BCC*).

- **Over ten CPU years consumed:** using existing information about
  BCH codes, the authors of bech32 were able to find the set of codes that
  provided the minimum amount of error detection they desired for Bitcoin
  addresses.  However, there were almost 160 thousand eligible codes in this
  set, and the authors expected some of them to be better than others.  To find the best
  code among them, over 200 CPU cores and ["more than 10 years of computation time"][cpu time] was used.

[wuille bech32]: https://youtu.be/NqiN9VFE4CU?t=1827
[cpu time]: https://youtu.be/NqiN9VFE4CU?t=1329
[wikipedia bch]: https://en.wikipedia.org/wiki/BCH_code
[first plans]:https://blog.bitmain.com/en/uahf-contingency-plan-uasf-bip148/
{% endauto_anchor %}
