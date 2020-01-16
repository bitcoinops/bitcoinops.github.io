---
title: "Transaction size calculator"
layout: page
breadcrumbs: false

size:
  ## Overhead
  nversion: 4
  nin: 1
  nout: 1
  marker_and_flag: 0.5
  nelements: 0.25
  nlocktime: 4

  ## Input
  outpoint: 36
  scriptsig_length_small: 1
  scriptsig_length_big: 3
  p2pkh_ss: 107   # 1 + 72 + 1 + 33
  p2sh23_ss: 254  # 1 + 1 + 72 + 1 + 72 + 1 + 1 + (1 + 1 + 33 + 1 + 33 + 1 + 33 + 1 + 1)
  nsequence: 4
  p2wpkh_witness: 26.75  # (73 + 34)/4
  p2wsh23_witness: 63.25  # (1 + 73 + 73 + 106)/4
  p2tr_witness: 16.25  # 65/4

  ## Output
  nvalue: 8
  scriptpubkey_length: 1
  p2pkh_spk: 25  # 1 + 1 + 1 + 20 + 1 + 1
  p2wpkh_spk: 22 # 1 + 1 + 20
  p2sh23_spk: 23 # 1 + 1 + 20 + 1
  p2wsh23_spk: 34 # 1 + 1 + 32
  p2tr_spk: 34 # 1 + 1 + 32

  ## Common elements
  ecdsa_pubkey: 33
  ecdsa_signature: 72
  schnorr_public_key: 32
  schnorr_signature: 64
  public_key_hash: 20
  script_hash_p2sh: 20
  script_hash_p2wsh: 32
---
<form action="" id="vbytescalc" onsubmit="return false;">
   <fieldset>

    Transaction type:
    <select id="type" onchange="updateTotal()">
    <option value="p2pkh">P2PKH</option>
    <option value="p2wpkh">P2WPKH</option>
    <option value="p2sh2_3">P2SH 2-of-3 multisig</option>
    <option value="p2wsh2_3">P2WSH 2-of-3 multisig</option>
    <option value="p2tr">P2TR (taproot)</option>
   </select>

  <br>
  Number of inputs: <input type="number" id="inputs" min="1" value="1" onchange="updateTotal()"/><br>
  Number of outputs: <input type="number" id="outputs" min="1" value="2" onchange="updateTotal()"/>

  <br><br><hr>
  <div id="result"></div>
  </fieldset>

</form>

## Legend: data field sizes

All sizes in parenthesis in the *overhead*, *input*, and *output*
sections are [vbytes][].  Sizes in the *common elements* section are bytes.

### Overhead

- **nVersion** ({{page.size.nversion}}) The
  transaction version number

- **Input count** ([compactSize][]) The number of inputs included in the
  transaction.  {{page.size.nin}} byte for up to 252
  inputs

- **Output count** ([compactSize][]) The number of outputs included in
  the transaction.  {{page.size.nout}} byte for up to
  252 outputs

- **nLockTime** ({{page.size.nlocktime}}) The earliest [epoch time][] or block
  height when the transaction may be included in a block

- Only in transactions spending one or more segwit UTXOs:

    - **Segwit marker & segwit flag** ({{page.size.marker_and_flag}}) A
      byte sequence used to clearly differentiate segwit transactions
      from legacy transactions

    - **Witness element count** ([compactSize][]/4) The number of witness
      elements included in the transaction. {{page.size.nelements}}
      vbytes for up to 252 elements

### Input

- **Outpoint** ({{page.size.outpoint}}) The txid and vout index number
  of the output (UTXO) being spent

- **scriptSig length** ([compactSize][]) The length of the scriptSig
  field.  {{page.size.scriptsig_length_small}} vbyte for a scriptSig up to 252
  vbytes.  Maximum of {{page.size.scriptsig_length_big}} vbytes for a maximum-length scriptSig (10,000 vbytes).

- **scriptSig** (varies) The source of witness data for legacy UTXOs.
  This data is used to prove that the transaction is authorized by
  someone controlling the appropriate private keys.  For the templates
  used by this calculator, the scriptSigs sizes are:

    - **P2PKH** ({{page.size.p2pkh_ss}})
      `OP_PUSH72 <ecdsa_signature> OP_PUSH33 <public_key>`

    - **P2SH 2-of-3** ({{page.size.p2sh23_ss}}) `OP_0 OP_PUSH72 <ecdsa_signature> OP_PUSH72 <ecdsa_signature> OP_PUSHDATA1 105 <OP_2 OP_PUSH33 <pubkey> OP_PUSH33 <pubkey> OP_PUSH33 <pubkey> OP_3 OP_CHECKMULTISIG>`


- **nSequence** ({{page.size.nsequence}}) The sequence number for the
  input.  Used by [BIP68][] and [BIP125][], with other values having no
  defined meaning

- **Witness data** (varies) The source of witness data for in segwit
  transactions.  This data is used to prove that the transaction is
  authorized by someone controlling the appropriate private keys.  For
  the templates used by this calculator, the witness data sizes are:

    - **P2WPKH** ({{page.size.p2wpkh_witness}})
        - (73) `size(72) signature`
        - (34) `size(33) public_key`

    - **P2WSH 2-of-3** ({{page.size.p2wsh23_witness}})
        - (1) `size(0) (empty)`
        - (73) `size(72) ecdsa_signature`
        - (73) `size(72) ecdsa_signature`
        - (106) `size(105) OP_2 OP_PUSH33 <pubkey> OP_PUSH33 <pubkey> OP_PUSH33 <pubkey> OP_3 OP_CHECKMULTISIG`

    - **P2TR** ({{page.size.p2tr_witness}})
        - (65) `size(64) schnorr_signature`

## Output

- **nValue** ({{page.size.nvalue}}) The amount of bitcoin value being paid

- **scriptPubKey length** ([compactSize][]) The length of the
  scriptPubKey field.  {{page.size.scriptpubkey_length}} vbyte for a
  script up to 252 vbytes.  Maximum of 3 vbytes for a maximum-length
  script (10,000 vbytes).

- **scriptPubKey** (varies) The specification of what conditions need to
  be fulfilled in order for this output to be spent.  For the templates
  used by this calculator, the scriptPubKeys are:

    - **P2PKH** ({{page.size.p2pkh_spk}}) `OP_DUP OP_HASH160
      OP_PUSH20 <public_key_hash> OP_EQUALVERIFY OP_CHECKSIG`

    - **P2WPKH** ({{page.size.p2wpkh_spk}}) `OP_0 OP_PUSH20 <public_key_hash>`

    - **P2SH 2-of-3** ({{page.size.p2sh23_spk}}) `OP_HASH160
      OP_PUSH20 <script_hash> OP_EQUAL`

    - **P2WSH 2-of-3** ({{page.size.p2wsh23_spk}}) `OP_0 OP_PUSH32 <script_hash>`

    - **P2TR** ({{page.size.p2tr_spk}}) `OP_1 OP_PUSH32 <schnorr_public_key>`

## Common elements

The list below indicates the size in bytes of common elements used in
the scripts above.  When used in a scriptPubKey or a scriptSig, the size
in vbytes is the same as the size in bytes.  When used as witness data
in a segwit input, the size in vbytes is the size in bytes divided by
four.

- `OP_*` (1)---all current opcodes in Bitcoin are a single byte

- `ecdsa_public_key` ({{page.size.ecdsa_pubkey}})---old wallets may use 65-byte public keys

- `ecdsa_signature` ({{page.size.ecdsa_signature}}) (about half of all
  signatures generated with a random nonce are this size, about half are
  one byte smaller, and a small percentage are smaller than that)

- `schnorr_public_key` ({{page.size.schnorr_public_key}})

- `schnorr_signature` ({{page.size.schnorr_signature}})---may also be
  one-byte longer for a non-default signature hash (sighash)

- `public_key_hash` ({{page.size.public_key_hash}})

- `script_hash` ({{page.size.script_hash_p2sh}})---**P2SH only**

- `script_hash` ({{page.size.script_hash_p2wsh}})---**P2WSH only**

<script>
function calculateTotal(type, inputs, outputs) {
  var types = new Array();

  types["p2pkh"] = {
    "input": (
      {{page.size.outpoint}}
      + {{page.size.scriptsig_length_small}}
      + {{page.size.p2pkh_ss}}
      + {{page.size.nsequence}}
    ),
    "output": (
        {{page.size.nvalue}}
      + {{page.size.scriptpubkey_length}}
      + {{page.size.p2pkh_spk}}
    ),
    "segwit": false
  };

  types["p2wpkh"] = {
    "input": (
      {{page.size.outpoint}}
      + {{page.size.scriptsig_length_small}}
      + {{page.size.p2wpkh_witness}}
      + {{page.size.nsequence}}
    ),
    "output": (
        {{page.size.nvalue}}
      + {{page.size.scriptpubkey_length}}
      + {{page.size.p2wpkh_spk}}
    ),
    "segwit": true
  };

  types["p2sh2_3"] = {
    "input": (
        {{page.size.outpoint}}
      + {{page.size.scriptsig_length_big}}
      + {{page.size.p2sh23_ss}}
      + {{page.size.nsequence}}
    ),
    "output": (
        {{page.size.nvalue}}
      + {{page.size.scriptpubkey_length}}
      + {{page.size.p2sh23_spk}}
    ),
    "segwit": false
  };

  types["p2wsh2_3"] = {
    "input": (
        {{page.size.outpoint}}
      + {{page.size.scriptpubkey_length}}
      + {{page.size.p2wsh23_witness}}
      + {{page.size.nsequence}}
    ),
    "output": (
        {{page.size.nvalue}}
      + {{page.size.scriptpubkey_length}}
      + {{page.size.p2wsh23_spk}}
    ),
    "segwit": true
  };

  types["p2tr"] = {
    "input": (
        {{page.size.outpoint}}
      + {{page.size.scriptsig_length_small}}
      + {{page.size.p2tr_witness}}
      + {{page.size.nsequence}}
    ),
    "output": (
        {{page.size.nvalue}}
      + {{page.size.scriptpubkey_length}}
      + {{page.size.p2tr_spk}}
    ),
    "segwit": true
  };

  // Calculate the size of each input and output
  input_size = types[type].input;
  output_size = types[type].output;

  // Calculate the transaction's overhead (the size independent of inputs and outputs)
  if (types[type].segwit == true) {
    witness_flag = {{page.size.marker_and_flag}} + {{page.size.nelements}};  // segwit marker, segwit flag, segwit # of witness elements
  } else  {
    witness_flag = 0;
  }
  overhead = (
      {{page.size.nversion}} // nVersion
    + {{page.size.nin}} // number of inputs, TODO: increase for >252 inputs
    + {{page.size.nout}} // number of outputs, TODO: increase for >252 outputs
    + {{page.size.nlocktime}} // nLockTime
    + witness_flag
  )

  size = overhead + input_size * inputs + output_size * outputs;

  return {
    "size": size,
    "overhead": overhead,
    "inputs": inputs,
    "input_size": input_size,
    "outputs": outputs,
    "output_size": output_size
  }
}

// Retrieve form and update results
function updateTotal() {
  var types = new Array();
  // Get the form
  var form = document.forms["vbytescalc"];

  // The input/output type
  // TODO: maybe allow the input type to be different from the output
  //       type, or multiple inputs of different types (or multiple
  //       outputs of different types)
  var type = form.elements["type"].value;
  // The number of inputs and outputs
  var inputs = form.elements["inputs"].value;
  if (inputs != "") {
    inputs = parseInt(inputs);
  } else {
    inputs = 0;
  }
  var outputs = form.elements["outputs"].value;
  if (outputs != "") {
    outputs = parseInt(outputs);
  } else {
    outputs = 0;
  }

  var results = calculateTotal(type, inputs, outputs);
  document.getElementById('result').innerHTML = (
    "<b>Total size:</b> " + results.size + " vbytes<br><br>"
    +  "<table>"
    + "  <tr>"
    + "    <th>Part</th>"
    + "    <th>Count</th>"
    + "    <th>Size (vbytes)</th>"
    + "    <th>Total vbytes</th>"
    + "  </tr>"
    + "<tr><td>Overhead</td><td>1</td><td>" + results.overhead + "</td><td>" + results.overhead + "</td></tr>"
    + "<tr><td>Inputs</td><td>" + results.inputs + "</td><td>" + results.input_size + "</td><td>" + results.inputs * results.input_size + "</td></tr>"
    + "<tr><td>Outputs</td><td>" + results.outputs + "</td><td>" + results.output_size + "</td><td>" + results.outputs * results.output_size + "</td></tr>"
    + "</table>"
  );
}

// For now, call this option manually from a console in your browser
// TODO: automatically run test via Makefile
function testSizes() {
  // txid: 4f10b3fc7b03a5362e40999097d5b43b9d99cb34c02fb3fe6fc2f8eff5d5224a
  console.assert(226 == calculateTotal("p2pkh", 1, 2).size, "1-in, 2-out P2PKH unexpected size");

  // txid: b169e4616d00bb27242093ec1749d5e8f69236bf704eadce3126e3b5f42107f9
  console.assert(562/4 == calculateTotal("p2wpkh", 1, 2).size, "1-in, 2-out P2WPKH unexpected size");

  // txid: c48c1a33a6e8a05d8b69b84c6532ad2ac06f0c5d0fa931523090b97d9de86e80
  console.assert(371 == calculateTotal("p2sh2_3", 1, 2).size, "1-in, 2-out P2SH 2-of-3 unexpected size");

  // txid: 13eba154725924a83f95a00abb716fd9587ca6e099f289e3578596c78c831338
  console.assert(804/4 == calculateTotal("p2wsh2_3", 1, 2).size, "1-in, 2-out P2WSH 2-of-3 unexpected size");

  console.log("All tests run");
  return true;
}

// Calculate the result for the default form parameters
updateTotal();
</script>

{% include references.md %}
[compactSize]: https://btcinformation.org/en/developer-reference#compactsize-unsigned-integers
[epoch time]: https://en.wikipedia.org/wiki/Unix_time
[vbytes]: https://en.bitcoin.it/wiki/Vsize
