Recently, an Optech contributor surveyed many popular wallets and Bitcoin
exchanges to see what technical features they supported.  For one of the
exchanges, he initially recorded it as supporting sending to bech32
addresses---but later he discovered its support wasn't entirely
complete.

The problem was that the exchange supported P2WPKH bech32 addresses
(single-sig addresses) but not P2WSH bech32 addresses (multisig and
complex script addresses).  Another problem was accepting all-lowercase
bech32 addresses but not all-uppercase bech32 addresses.  A different
exchange limited the length of address form fields so that they couldn't
fit all valid bech32 addresses.

With these problems in mind, we've created a short checklist for testing
basic bech32 sending support.  Only perform these tests with small
amounts of bitcoin that you can afford to lose if something goes wrong.

1. Generate two addresses of your own, one for P2WPKH and one for P2WSH.
   For example, using Bitcoin Core, the [jq][] JSON parser, and the Bash
   shell, you can run the following commands:

     ```bash
     $ p2wpkh=$( bitcoin-cli getnewaddress "bech32 test" bech32 )
     $ p2wsh=$(
       bitcoin-cli addmultisigaddress 1 \[$(
         bitcoin-cli getaddressinfo $p2wpkh | jq .pubkey
       )\] "bech32 test" bech32 | jq -r .address
     )
     $ echo $p2wpkh $p2wsh
     $ echo $p2wpkh $p2wsh | tr '[a-z]' '[A-Z]'
     ```

2. Test sending bitcoin to each lowercase address
   using your software's or service's usual spending or withdrawal forms.

3. Test again with the uppercase form of each address (these are useful
   with [QR codes][bech32 qr code section]).

4. Ensure that you received the funds by checking either the wallet you
   used to create the addresses or a block explorer.  If that worked,
   your software fully supports current bech32 spending addresses.

     If you created addresses using a temporary Bitcoin Core wallet, you
     can wait for the transactions to confirm and then send all the money
     to your regular wallet using the following command: `bitcoin-cli
     sendtoaddress YOUR_ADDRESS $( bitcoin-cli getbalance ) '' '' true`

For unit tests where you don't actually attempt to send money, or
for integration tests where you send money on testnet or in regression
testing mode, BIP173 provides a more comprehensive set of [test
vectors][bip173 test vectors].

[jq]: https://stedolan.github.io/jq/
[bech32 qr code section]: /en/bech32-sending-support/#creating-more-efficient-qr-codes-with-bech32-addresses
[bip173 test vectors]: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#Test_vectors
