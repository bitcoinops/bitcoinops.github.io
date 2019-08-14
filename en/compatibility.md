---
layout: page
title: Compatibility Matrix
permalink: /en/compatibility/
nowrap: true
---
{% assign yes = '<span class="feature-yes"><strong>✓</strong></span>' %}
{% assign no = '<span class="feature-no"><strong>✕</strong></span>' %}
<style>
th, td { text-align: center; }
h1, h2, h3, h4, h5, h6 { text-align: center; }
</style>

{:.center}
[Segwit](#segwit-addresses) \| [Replace-by-Fee](#replace-by-fee-rbf)

## Segwit Addresses

<table class="compatibility">
  <tr>
    <th></th>
    <th colspan="3">Receiving support</th>
    <th colspan="3">Sending support</th>
  </tr>
  <tr>
    <th></th>
    <th>P2SH-wrapped</th>
    <th>Bech32</th>
    <th>Default address</th>
    <th>P2WPKH</th>
    <th>P2WSH</th>
    <th>Bech32 change</th>
  </tr>

{% assign tools = site.data.compatibility | sort %}
{% for wrapped_tool in tools %}
  {% assign tool = wrapped_tool[1] %}
    {% if tool.segwit %}
      <tr>
        <td><a href="{{tool.internal_url}}#segwit">{{tool.name}}</a></td>
      {% assign segwit_receive_default = "" %}
      {% assign segwit_receive_default_class = "default" %}
      {% case tool.segwit.features.receive.default %}
        {% when "p2pkh" %}
          {% assign segwit_receive_default = "P2PKH" %}
          {% assign segwit_receive_default_class = "compat_no" %}
        {% when "p2sh" %}
          {% assign segwit_receive_default = "P2SH" %}
          {% assign segwit_receive_default_class = "compat_no" %}
        {% when "p2sh_wrapped" %}
          {% assign segwit_receive_default = "P2SH-P2WPKH" %}
          {% assign segwit_receive_default_class = "compat_yes" %}
        {% when "p2sh_wrapped_p2wsh" %}
          {% assign segwit_receive_default = "P2SH-P2WSH" %}
          {% assign segwit_receive_default_class = "compat_yes" %}
        {% when "bech32" %}
          {% assign segwit_receive_default = "P2WPKH" %}
          {% assign segwit_receive_default_class = "compat_yes" %}
        {% when "bech32_p2wsh" %}
          {% assign segwit_receive_default = "P2WSH" %}
          {% assign segwit_receive_default_class = "compat_yes" %}
        {% when "na" %}
        {% when "untested" %}
          {% assign cell_label = "?" %}
        {% else %}{% include ERROR_43_unexpected_value %}
      {% endcase %}

      {% include functions/compat-cell.md state=tool.segwit.features.receive.p2sh_wrapped anchor="#segwit-receive-p2sh_wrapped" %}
      {% include functions/compat-cell.md state=tool.segwit.features.receive.bech32 anchor="#segwit-receive-bech32" %}
      <td class="compat {{segwit_receive_default_class}}"><a href="{{tool.internal_url}}#segwit-receive-default">{{segwit_receive_default}}</a></td>
      {% include functions/compat-cell.md state=tool.segwit.features.send.bech32 anchor="#segwit-send-bech32" %}
      {% include functions/compat-cell.md state=tool.segwit.features.send.bech32_p2wsh anchor="#segwit-send-bech32_p2wsh" %}
      {% include functions/compat-cell.md state=tool.segwit.features.send.change_bech32 anchor="#segwit-send-change_bech32" %}
      </tr>
    {% endif %}
{% endfor %}

</table>

## Replace-by-Fee (RBF)

<table class="compatibility">
  <tr>
    <th></th>
    <th colspan="5">Receiving support</th>
    <th colspan="5">Sending support</th>
  </tr>
  <tr>
    <th></th>
    <th>Notification</th>
    <th>List</th>
    <th>Details</th>
    <th>Shows replaced</th>
    <th>Shows original</th>
    <th>Signals BIP125</th>
    <th>List</th>
    <th>Details</th>
    <th>Shows replaced</th>
    <th>Shows original</th>
  </tr>

{% assign tools = site.data.compatibility | sort %}
{% for wrapped_tool in tools %}
  {% assign tool = wrapped_tool[1] %}
  <tr>
    <td><a href="{{tool.internal_url}}#rbf">{{tool.name}}</a></td>
    {% include functions/compat-cell.md state=tool.rbf.features.receive.notification anchor="#receive-notification" %}
    {% include functions/compat-cell.md state=tool.rbf.features.receive.list anchor="#receive-list" %}
    {% include functions/compat-cell.md state=tool.rbf.features.receive.details anchor="#receive-details" %}
    {% include functions/compat-cell.md state=tool.rbf.features.receive.shows_replaced_version anchor="#receive-replaced" %}
    {% include functions/compat-cell.md state=tool.rbf.features.receive.shows_original_version anchor="#receive-replaced" %}
    {% include functions/compat-cell.md state=tool.rbf.features.send.signals_bip125 anchor="#send-signals_bip125" %}
    {% include functions/compat-cell.md state=tool.rbf.features.send.list anchor="#send-list" %}
    {% include functions/compat-cell.md state=tool.rbf.features.send.details anchor="#send-details" %}
    {% include functions/compat-cell.md state=tool.rbf.features.send.shows_replaced_version anchor="#send-replaced" %}
    {% include functions/compat-cell.md state=tool.rbf.features.send.shows_original_version anchor="#send-replaced" %}
  </tr>
{% endfor %}

</table>

<br/>
<br/>
_Contributions and corrections are welcome. Please see the [contibuting
guidelines](https://github.com/bitcoinops/bitcoinops.github.io/blob/master/CONTRIBUTING.md)
for details._
{: style="text-align: center;"}
