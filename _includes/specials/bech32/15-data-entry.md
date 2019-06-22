{% assign input_base58check_address = "1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC" %}
{% assign input_bech32_address = "bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh" %}

Before segwit was activated, developers discussed what format to use for
native segwit addresses, with some developers suggesting that a new
format was an opportunity to make addresses that were easier to read and
transcribe.  Developer Gregory Maxwell made this point rather poignantly
by [asking][maxwell phone] other developers to call him up and try to
successfully communicate a mixed-case legacy base58check address to him
over the phone.  If there was a communication error in just a single
character---even just whether that character was uppercase or
lowercase---both parties would need to go back and painstakingly try to
locate the error.

[BIP173][] bech32 addresses were able to resolve both of these concerns.
They use only a single case (lowercase preferred most of the time but
uppercase can be used with QR codes for [improved efficiency][bech32 qr
code section]), and they use an error-correction code for a checksum so
they can [help users locate errors][bech32 ecc section] while ensuring
typos will be caught an overwhelming percentage of the time.

However, as wallets and services consider upgrading to support both
bech32 sending and receiving, we think it's worth reminding any
reluctant implementers about this this key user-benefiting feature of
bech32 addresses---so we've automated part of Maxwell's old phone test
to allow you to privately evaluate the relative difficulty of
transcribing legacy and native segwit addresses.

If you click the following link (open it into a new tab), you'll find a
recording of two addresses paying the same hash value.  You can type the
addresses into the appropriate box below, which will turn red
immediately if you enter any wrong character (case sensitive).  Note: to
help improve accuracy and eliminate problems with locale-specific letter
pronunciations, we read each letter in the file using a phonetic
alphabet, e.g. `Alfa` stands for *A*; `bravo` stands for *B*, etc.

<noscript><p><b>NB:</b> JavaScript recommended&#8212;if you want the
input boxes to automatically change color to red when you enter a typo,
you need to enable JavaScript.  However, if you have JS
disabled&#8212;good for you!&#8212;we suggest you enter your input as
normal and then use your mouse to highlight this entire paragraph.  Just
after the end of this sentence in normally-invisible white text are the
two addresses; when you highlight the paragraph (changing its background
color), they should become visible so that you can compare them to your
input manually: <span class="spoiler">{{input_base58check_address}} and
{{input_bech32_address}}.</span></p></noscript>

[Reading of base58check and bech32 addresses (1 minute, 33 seconds)][bech32 audio]

**Legacy base58check address:**

<input type="text" class="addrInput" id="{{input_base58check_address}}" oninput="validateAddress('{{input_base58check_address}}')">

**Native segwit bech32 address:**

<input type="text" class="addrInput" id="{{input_bech32_address}}" oninput="validateAddress('{{input_bech32_address}}')">

If you found the bech32 address much easier to transcribe accurately,
then that means the designers of bech32 were successful at meeting one
of their goals for the new address format.  Users who discover this
benefit of bech32 are more likely to want to use bech32 addresses in
situations where they need to read or transcribe addresses, and so
they'll be more likely to use your software or service if it supports
sending to bech32 addresses.

[bech32 audio]: /img/posts/2019-06-base58-vs-bech32-audio.ogg
[maxwell phone]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2016/bitcoin-core-dev.2016-03-10-18.59.log.html#l-59
[bech32 qr code section]: /en/bech32-sending-support/#creating-more-efficient-qr-codes-with-bech32-addresses
[bech32 ecc section]: /en/bech32-sending-support/#locating-typos-in-bech32-addresses

<script>
function validateAddress(instance) {
  // Prefix the input field's current value with a ^ for a regex
  var userAddress = '^' + document.getElementById(instance).value;
  // Compile it into a regex
  var matchRegex = new RegExp(userAddress);
  // Clear the old style
  document.getElementById(instance).classList.remove("redbg")
  // If wrong, set red background
  if (! instance.match(matchRegex)) {
    document.getElementById(instance).classList.add("redbg");
  }
}
</script>

<style>
.addrInput {
  min-width: 30em;
  min-height: 1.5em;
}

.redbg { background-color: pink; }
.spoiler { color: white; }
</style>

