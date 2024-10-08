---
layout: page
title: Bitcoin Feature Matrix
permalink: /en/matrix/
nowrap: true
redirect_from:
  - /en/compatibility/
  - /en/compatibility/wasabi/
---

<head>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

</head>

<style>

/* Style the table */
table {
  border-collapse: collapse;
  width: auto; /* Set width to auto */
  margin: 0 auto; /* Center the table */
}

/* Style table cells */
th, td {
  text-align: center;
  padding: 0; /* Set padding to 0 */
  border: 1px solid black;
}

/* Style for tooltips */
.tooltip-container {
  position: relative;
  display: inline-block;
}

.tooltip {
  visibility: hidden;
  background-color: #333;
  color: #fff;
  text-align: left;
  border-radius: 5px;
  padding: 5px;
  position: absolute;
  z-index: 1;
  bottom: 125%;
  left: 50%;
  margin-left: -75px; /* Adjust this value to center the tooltip */
  opacity: 0;
  transition: opacity 0.3s;
  white-space: pre-line; /* Allows for multiple lines */
  max-width: 200px; /* Set a maximum width for the tooltip */
  width: max-content; /* Set width to adjust dynamically based on content */
  overflow-wrap: break-word; /* Enable word wrapping */
}

.tooltip-container:hover .tooltip {
  visibility: visible;
  opacity: 1;
}

/* Style to keep the checkmark used for Alternate Implementation the Standard across all browsers  */
.checkmark {
  font-family: 'Segoe UI Emoji', 'Apple Color Emoji', 'Noto Color Emoji', 'Segoe UI Symbol', 'Arial', sans-serif;
  font-size: 1em; /* Set a fixed font size */
}

.tracking-description {
    font-size: 1.2em; /* Adjust text font size */
    font-style: italic; /* Make text italic */
    color: #666; /* Adjust text color */
}

</style>

<center><p class="tracking-description">tracking interoperability of ₿itcoin products & services 🤝</p></center>

<table style="border: 1px solid white;">
  <colgroup>
      <col style="width:15%"/>
      <col style="width:13%"/>
      <col style="width:17%"/>
      <col style="width:25%"/>
      <col style="width:10%"/>
  </colgroup>
  <tr style="border-style:hidden;">
    <td style="border-style:hidden;"></td>
    <td style="border-style:hidden;text-align:left;vertical-align: top;font-size:14px;">
      <font size="3"><b>Select features to display:</b></font><br>
      &#160;<input type="checkbox" id="showPlatform">Platform<br>
      &#160;<input type="checkbox" id="showHWInterface">Hardware Wallet Interface<br>
      &#160;<input type="checkbox" id="showFeeBumping">Fee Bumping<br>
      &#160;<input type="checkbox" id="showDescriptors">Descriptors<br>
      &#160;<input type="checkbox" id="showMultiPartyTxn">Multi-Party<font size="1"> (PSBT, MuSig2, Coinjoin, Payjoin)</font><br>
    </td>
    <td style="border-style:hidden;text-align:left;vertical-align: top;font-size:14px;">
      <font size="3"><b></b></font><br>
      &#160;<input type="checkbox" id="showPC_SilentPayments">Payment Codes, Silent Payments<br>
      &#160;<input type="checkbox" id="showLightning">Lightning<br>
    </td>
    <td style="border-style:hidden;text-align:left;vertical-align: top;font-size:14px;">
          <font size="3"><b>Legend:</b></font><br>
              &#x2705; - Full Support (send & receive)<br/>
              &#x1F4B8; - Send Support<br/>
              &#x274C; - No Support <br/>
              &#x2796; - Not Applicable (for a category type)<br/>
              <span class="checkmark">&#10004;</span> - Alternate Implementation / <font size="3"><b>&#178;</b></font> - Multiple Implementations
    </td>
    <td style="border-style:hidden;"></td>
  </tr>
</table>

<table id="feature-tracker">

  <thead>   <!--  the <thead> tag is used to define the header section of a table -->
  <tr>
    <th rowspan="2">Product <br/>/ <br/>Service </th>
    <th rowspan="2">Category</th>
    <th rowspan="2">Key <br/> Features / <br/>Use Cases<br/><font size="1"><i class="italic">(hover)</i></font></th>
    <th class="col-platform" style="display: none;color:blue;" colspan="3">Platform</th>
    <th class="col-hwinterface" style="display: none;" rowspan="2"><a href="https://bitcoinops.org/en/topics/hwi/">HWI</a></th>

    <th rowspan="2">Default <br/>Receive<br/> Address</th>

    <th colspan="3" style="color:blue;">Native Segwit</th>
    <th class="col-feebumping" style="display: none;color:blue;" colspan="4">Fee Bumping </th>

    <th class="col-descriptors" style="display: none;" rowspan="2"><a href="https://bitcoinops.org/en/topics/output-script-descriptors/">Descriptors</a></th>

    <th class="col-multipartytxn" style="display: none;color:blue;" colspan="6">Multi-Party Transactions </th>

    <th class="col-pc_silentpayments" style="display: none;color:blue;" colspan="1"><div class="tooltip-container">
    <a href="https://github.com/bitcoin/bips/blob/master/bip-0047.mediawiki">Payment <br>Codes</a><span class="tooltip">BIP47</span>
    </div></th>

    <th class="col-pc_silentpayments" style="display: none;color:blue;" colspan="2"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/silent-payments/">Silent <br>Payments</a><span class="tooltip">BIP352</span>
    </div></th>

    <th class="col-lightning" style="display: none;color:blue;" colspan="6"><div class="tooltip-container">Lightning<span class="tooltip">Lightning only sending (Pay Invoice) and receiving (Create Invoice) capabilities are considered.</span>
    </div></th>

    </tr>
    <tr>

    <th class="col-platform" style="vertical-align:top;display: none;"><div class="tooltip-container">Device<span class="tooltip">Desktop/Mobile</span>
    </div></th>
    <th class="col-platform" style="vertical-align:top;display: none;"><div class="tooltip-container">OS<span class="tooltip">Linux, Windows, OS, Android, iOS</span>
    </div></th>
    <th class="col-platform" style="vertical-align:top;display: none;"><div class="tooltip-container">Web /<br> Browser<span class="tooltip">Y/N</span>
    </div></th>

    <th style="vertical-align:top;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/bech32/">Bech32 <br/><font color="grey">P2WPKH<br/>P2WSH</font></a><span class="tooltip">BIP173</span>
    </div></th>

    <th style="vertical-align:top;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/bech32/">Bech32m <br/><font color="grey">P2TR</font></a><span class="tooltip">BIP350</span>
    </div></th>

    <th style="vertical-align:top;">Native <br/>Segwit<br/> Change</th>

    <th class="col-feebumping" style="display: none;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/replace-by-fee/">Full RBF<br><font color="grey">Bump<br>Fee</font></a><span class="tooltip">full-RBF</span>
    </div></th>

    <th class="col-feebumping" style="display: none;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/replace-by-fee/">Full RBF<br><font color="grey">Cancel<br>TXN</font></a><span class="tooltip">full-RBF</span>
    </div></th>

    <th class="col-feebumping" style="display: none;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/replace-by-fee/">Full RBF<br><font color="grey">Notification</font></a><span class="tooltip">full-RBF</span>
    </div></th>

    <th class="col-feebumping" style="display: none;"><a href="https://bitcoinops.org/en/topics/cpfp/">CPFP</a></th>

    <th class="col-multipartytxn" style="display: none;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/psbt/">PSBT<br><font color="grey">Version</font></a><span class="tooltip">BIP174 & BIP370</span>
    </div></th>

    <th class="col-multipartytxn" style="display: none;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/psbt/">PSBT<br><font color="grey">Export</font></a><span class="tooltip">BIP174 & BIP370</span>
    </div></th>

    <th class="col-multipartytxn" style="display: none;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/psbt/">PSBT<br><font color="grey">Update / <br>Finalize</font></a><span class="tooltip">BIP174 & BIP370</span>
    </div></th>

    <th class="col-multipartytxn" style="display: none;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/musig/">MuSig2</a><span class="tooltip">BIP327</span>
    </div></th>

    <th class="col-multipartytxn" style="display: none;"><a href="https://bitcoinops.org/en/topics/coinjoin/">Coinjoin</a></th>

    <th class="col-multipartytxn" style="display: none;"><div class="tooltip-container">
    <a href="https://bitcoinops.org/en/topics/payjoin/">Payjoin<font color="orange">*</font></a><span class="tooltip">BIP78 and Alternate Implementations are considered</span>
    </div></th>

    <th class="col-pc_silentpayments" style="display: none;">Send /<br>Receive</th>

    <th class="col-pc_silentpayments" style="display: none;">Send /<br>Receive</th>

    <th class="col-pc_silentpayments" style="display: none;">Send / Receive<br> <font color="grey"> + DNS<br>Address</font></th>

    <th class="col-lightning" style="display: none;"><a href="https://github.com/lightning/bolts/blob/master/11-payment-encoding.md">BOLT 11</a></th>
    <th class="col-lightning" style="display: none;"><a href="https://bitcoinops.org/en/topics/offers/">BOLT 12</a></th>
    <th class="col-lightning" style="display: none;"><a href="https://github.com/bitcoin/bips/blob/2d9c172cddd6eaf2b1dedea66595fb33fa987fef/bip-XXXX.mediawiki">BOLT 12 <br><font color="grey">+ DNS<br>Addresses</font></a></th>
    <th class="col-lightning" style="display: none;"><a href="https://bitcoinops.org/en/topics/lnurl/">LNURL</a></th>
    <th class="col-lightning" style="display: none;"><a href="https://bitcoinops.org/en/topics/lnurl/">LNURL <font color="grey">+<br>Lightning<br> Addresses</font></a></th>

  </tr>
  </thead>
  <tbody>
  {% assign tools = site.data.matrix | sort %}    <!-- Liquid Syntax assigning the YAML data in the directory to the variable tools, sorted -->

  {% for wrapped_tool in tools %}
    {% assign tool = wrapped_tool[1] %}
      {% if tool.feature %}  <!-- YAML files must have "feature" attribute -->
        <tr>
          <td><a href="{{tool.homepage}}">{{tool.name}}</a></td>
          <td><font size="3">{{tool.category}}</font></td>
          <td>
                <div class="tooltip-container"> <!-- Everything within this division activates the tooltip container -->
                <span class="tooltip">{{tool.keyfeatures}}</span> <!-- This span contains the tooltip text for the tooltip container -->
                &#x1F4A1;
                </div>
          </td>

          <td class="col-platform" style="display: none;">
          {% include functions/matrix-cell-device.md state=tool.feature.device %}

          <td class="col-platform" style="display: none;">
          {% include functions/matrix-cell-os.md state=tool.feature.os %}

          <td class="col-platform" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.web %}

          <td class="col-hwinterface" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.hw_interface %}

          <td>{{tool.feature.default_receive}}</td>

          <td>
          {% include functions/matrix-cell-1-input.md state=tool.feature.bech32 %}

          <td>
          {% include functions/matrix-cell-1-input.md state=tool.feature.bech32m %}

          <td>
          {% include functions/matrix-cell-1-input.md state=tool.feature.segwit_change %}

          <td class="col-feebumping" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.full_rbf_bump_fee %}

          <td class="col-feebumping" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.full_rbf_cancel_txn %}

          <td class="col-feebumping" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.full_rbf_notification %}

          <td class="col-feebumping" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.cpfp %}

          <td class="col-descriptors" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.descriptors %}

          <td class="col-multipartytxn" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.psbt_version %}

          <td class="col-multipartytxn" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.psbt_export %}

          <td class="col-multipartytxn" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.psbt_update_finalize %}

          <td class="col-multipartytxn" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.musig2 %}

          <td class="col-multipartytxn" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.coinjoin %}

          <td class="col-multipartytxn" style="display: none;">
          {% include functions/matrix-cell-4-input.md input="BIP78 - " input2=tool.feature.payjoin_BIP78 input3=tool.feature.payjoin_alternate input4=tool.feature.payjoin_alternate_name %}

          <td class="col-pc_silentpayments" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.payment_code %}

          <td class="col-pc_silentpayments" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.silent_payments_BIP352 %}

          <td class="col-pc_silentpayments" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.silent_payments_dns %}

          <td class="col-lightning" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.lightning_11 %}
          <td class="col-lightning" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.lightning_12 %}
          <td class="col-lightning" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.lightning_12_dns %}
          <td class="col-lightning" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.lightning_lnurl %}
          <td class="col-lightning" style="display: none;">
          {% include functions/matrix-cell-1-input.md state=tool.feature.lightning_lnurl_hrla %}

        </tr>
      {% endif %}

  {% endfor %}

  </tbody>
  </table>

  <table>

  <tr style="background-color: transparent;">
  <td colspan="15" style="text-align:left;font-size:14px;border-style:hidden;" >
  <span class="bold">Notes:</span><br/>
  &#x1F538; Features with alternate implementations are denoted with <font color="orange" size="3">*</font>, hover for details.<br/>
  &#x1F538; To qualify as having Bech32 sending support, a product should be able to send to both P2WPKH and P2WSH<br/>
  &#x1F538; To qualify as having Bech32 receiving support, it is sufficient to receive to either P2WPKH or P2WSH<br/>
  </td>

  </tr>
  <tr style="background-color: transparent;">
  <td colspan="15" style="text-align:left;font-size:14px;border-style:hidden;" >
  <span class="bold">Approach:</span><br/>
  &#x1F538; The initial features within the matrix have been selected by bitcoinops with a focus on interoperability.  <br/>
  &#x1F538; The matrix will be split by category, once enough results are collected.<br/>
  &#x1F538; New feature as well as product/service requests are welcome!  Open a PR in the Optech Github.<br/>
  </td>
  </tr>

  </table>

<br/>

<br/>
_Contributions and corrections are welcome. Please see the [contibuting
guidelines](https://github.com/bitcoinops/bitcoinops.github.io/blob/master/CONTRIBUTING.md)
for details._
{: style="text-align: center;"}

<script>
    // Function to handle checkbox change
    function handleCheckboxChange(checkbox, columns) {
        checkbox.addEventListener('change', function() {
            const displayValue = this.checked ? 'table-cell' : 'none';
            columns.forEach(column => {
                column.style.display = displayValue;
            });
        });
    }

    // Define checkboxes and corresponding columns
    const checkboxColumnMap = [
        { checkbox: document.getElementById('showLightning'), columns: document.querySelectorAll('.col-lightning') },
        { checkbox: document.getElementById('showPC_SilentPayments'), columns: document.querySelectorAll('.col-pc_silentpayments') },
        { checkbox: document.getElementById('showMultiPartyTxn'), columns: document.querySelectorAll('.col-multipartytxn') },
        { checkbox: document.getElementById('showFeeBumping'), columns: document.querySelectorAll('.col-feebumping') },
        { checkbox: document.getElementById('showPlatform'), columns: document.querySelectorAll('.col-platform') },
        { checkbox: document.getElementById('showHWInterface'), columns: document.querySelectorAll('.col-hwinterface') },
        { checkbox: document.getElementById('showDescriptors'), columns: document.querySelectorAll('.col-descriptors') }
    ];

    // Attach event listeners to checkboxes
    checkboxColumnMap.forEach(item => {
        handleCheckboxChange(item.checkbox, item.columns);
    });
</script>
