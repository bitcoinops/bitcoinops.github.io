---
layout: page
title: Compatibility Comparison
permalink: /en/compatibility/
nowrap: true
---
{% assign yes = '<span class="feature-yes"><strong>✓</strong></span>' %}
{% assign no = '<span class="feature-no"><strong>✕</strong></span>' %}
<style>
th, td { text-align: center; }
h1, h2, h3, h4, h5, h6 { text-align: center; }
</style>

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
    <td><a href="{{tool.internal_url}}">{{tool.name}}</a></td>
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
