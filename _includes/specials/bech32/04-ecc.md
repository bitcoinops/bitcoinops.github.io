In [last week's newsletter][Newsletter #40], we used the Python
reference library for bech32 to decode an address into a scriptPubKey
that you could pay.  However, sometimes the user provides an address
containing a typo.  The code we suggested would detect the typo and
ensure you didn't pay a wrong address, but bech32 is also able to help
detect the location of typos for your users.  This week, we'll
demonstrate this capability using the [Javascript sample code][].

The code is written using Node.js-style module inclusion syntax, so the
first step is to compile it into code we can use in the browser.  For
that, we install a [browserify][] tool:

```bash
sudo apt install node-browserify-lite
```

Then we compile it into a standalone file:

```bash
browserify-lite ./segwit_addr_ecc.js --outfile bech32-demo.js --standalone segwit_addr_ecc
```

Followed by including it in our HTML:

```html
<script src="bech32-demo.js"></script>
```

For convenience, we've included that file on the [web
version][Newsletter #41] of this newsletter, so you can follow along
with the rest of this example by simply opening the developer console in
your web browser.  Let's start by checking a valid address.  Recall from
last week that we provide the network identifier when checking an
address (`bc` for Bitcoin mainnet):

```text
>> segwit_addr_ecc.check('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4', 'bc')
error: null
program: Array(20) [ 117, 30, 118, … ]
version: 0
```

We see above that, just like last week, we get back the witness version
and the witness program.  The presence of the version field, plus the
lack of an error, indicate that this program decoded without any
checksum failure.

Now we replace one character in the above address with a typo and try
checking that:

```text
>> segwit_addr_ecc.check('bc1qw508d6qejxtdg4y5r4zarvary0c5xw7kv8f3t4', 'bc')
error: "Invalid"
pos: Array [ 21 ]
```

This time we get back the description of the error (the address is
invalid because it doesn't match its checksum) and a position.  If we
place the addresses above each other with each position marked, we see
that this "21" identifies the location of the specific error:

```text
                   1x        2x
         0123456789012345678901
>> good='bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'
>> typo='bc1qw508d6qejxtdg4y5r4zarvary0c5xw7kv8f3t4'
                              ^
```

What if we make an additional replacement to the typo address and try
again?

```text
>> segwit_addr_ecc.check('bc1qw508d6qejxtdg4y5r4zarvary0c5yw7kv8f3t4', 'bc')
error: "Invalid"
pos: Array [ 32, 21 ]
```

We get two locations.  Once again, when we compare the addresses to
each other, we see this has identified both incorrect characters:

```text
                   1x        2x        3x
         012345678901234567890123456789012
>> good='bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'
>> typo='bc1qw508d6qejxtdg4y5r4zarvary0c5yw7kv8f3t4'
                              ^          ^
```

Pieter Wuille's [interactive demo][] of this Javascript code includes
a few lines of additional code (view source on that page to see the
function) that uses the position of the typo characters to emphasize
them in red:

![Screenshot of the bech32 interactive demo with the typo address above](/img/posts/2019-04-bech32-demo.png)

There's a limit to how many errors the `check()` function can specifically identify.
After that it can still tell that an address contains an error, but it
can't identify where to look in the address for the error.  In that
case, it'll still return the address as invalid but it won't return the
position details:

```text
>> segwit_addr_ecc.check('bc1qw508z6qejxtdg4y5r4zarvary0c5yw7kv8f3t4', 'bc')
error: "Invalid"
pos: null
```

In the case where there are other problems with the address, the `error`
field will be set to a more descriptive message that may or may not
include a position of the error.  For example:

```text
>> segwit_addr_ecc.check('bc1zw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4yolo', 'bc')
error: "Invalid character"
pos: Array [ 43 ]
```

You can review the [source][bech32 errors] for a complete list of
errors.

Although we spent a lot of time looking at errors in this mini tutorial,
we've hopefully shown how easy it is to provide nice interactive
feedback to users entering bech32 addresses on a web-based platform.  We
encourage you to play around with the [interactive demo][] to get an
idea of what your users might see if you make use of this bech32 address
feature.

<script src="/misc/bech32-demo.js"></script>
[bech32 easy]: {{news38}}#bech32-sending-support
[browserify]: http://browserify.org/
[javascript sample code]: https://github.com/sipa/bech32/tree/master/ecc/javascript
[interactive demo]: http://bitcoin.sipa.be/bech32/demo/demo.html
[bech32 errors]: https://github.com/sipa/bech32/blob/master/ecc/javascript/segwit_addr_ecc.js#L54
