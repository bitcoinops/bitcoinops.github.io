## Segwit Addresses {#segwit}

**What are segwit addresses?** Transactions that spend bitcoins secured by segregated witness (segwit) use less
block weight than equivalent non-segwit (legacy) transactions, allowing
segwit transactions to pay less total fee to achieve the same feerate as legacy transactions.

{% if tool.segwit %}

{% assign tested = tool.segwit.tested. %}
**Tested**: {% if tested.version != "n/a" %} *version {{tested.version}}* {% endif %} on *{{tested.platforms}}*

**Tested on**: *{{tested.date}}*

### Receive support

<div markdown="1" class="compat-list">

{% assign segwit = tool.segwit.features. %}
{:id="segwit-receive-p2sh_wrapped"}
{% case segwit.receive.p2sh_wrapped %}
  {% when "true" %}{:.feature-yes}
  - **Allows receiving to P2SH-wrapped segwit**<br>
    Allows the generation of P2SH-wrapped (either P2WPKH or P2WSH) segwit receiving addresses.
  {% when "false" %}{:.feature-no}
  - **Does not allow receiving to P2SH-wrapped segwit**<br>
    Does not allow the generation of P2SH-wrapped (either P2WPKH or P2WSH) segwit receiving addresses.
  {% when "na" %}{:.feature-neutral}
  - **No receiving capabilities**<br>
    There are no receiving capabilities for this service.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested: Can P2SH-wrapped segwit transaction outputs be received?**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="segwit-receive-bech32"}
{% case segwit.receive.bech32 %}
  {% when "true" %}{:.feature-yes}
  - **Allows receiving to bech32 segwit addresses**<br>
    Allows the generation of bech32 native (either P2WPKH or P2WSH) segwit receiving addresses.
  {% when "false" %}{:.feature-no}
  - **Does not allow receiving to bech32 segwit addresses**<br>
    Does not allow the generation of bech32 native (either P2WPKH or P2WSH) segwit receiving addresses.
  {% when "na" %}{:.feature-neutral}
  - **No receiving capabilities**<br>
    There are no receiving capabilities for this service.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested: Can bech32 segwit transaction outputs be received?**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="segwit-receive-bech32m"}
{% case segwit.receive.bech32m %}
  {% when "true" %}{:.feature-yes}
  - **Allows receiving to bech32m addresses**<br>
    Allows the generation of bech32m (P2TR) receiving addresses.
  {% when "false" %}{:.feature-no}
  - **Does not allow receiving to bech32m segwit addresses**<br>
    Does not allow the generation of bech32m (P2TR) receiving addresses.
  {% when "na" %}{:.feature-neutral}
  - **No receiving capabilities**<br>
    There are no receiving capabilities for this service.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested: Can bech32m transaction outputs be received?**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="segwit-receive-default"}
{% case segwit.receive.default %}
  {% when "p2pkh" %}{:.feature-no}
  - **Default receiving address is P2PKH**<br>
    This service generates legacy P2PKH receiving addresses by default.
  {% when "p2sh" %}{:.feature-no}
  - **Default receiving address is P2SH**<br>
    This service generates P2SH (not P2SH-wrapped segwit) receiving addresses by
    default.
  {% when "p2sh_wrapped" %}{:.feature-yes}
  - **Default receiving address is P2SH-wrapped P2WPKH**<br>
    This service generates P2SH-wrapped P2WPKH segwit receiving addresses by
    default.
  {% when "p2sh_wrapped_p2wsh" %}{:.feature-yes}
  - **Default receiving address is P2SH-wrapped P2WSH**<br>
    This service generates P2SH-wrapped P2WSH segwit receiving addresses by default.
  {% when "bech32" %}{:.feature-yes}
  - **Default receiving address is bech32 P2WPKH**<br>
    This service generates bech32 P2WPKH segwit receiving addresses by default.
  {% when "bech32_p2wsh" %}{:.feature-yes}
  - **Default receiving address is bech32 P2WSH**<br>
    This service generates bech32 P2WSH segwit receiving addresses by default.
  {% when "na" %}{:.feature-neutral}
  - **No receiving capabilities**<br>
    There are no receiving capabilities for this service.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested: What is the default receiving address type?**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

</div>{% comment %}<!-- end: compat-list -->{% endcomment %}

### Send support

<div markdown="1" class="compat-list">

{:id="segwit-send-bech32"}
{% case segwit.send.bech32 %}
  {% when "true" %}{:.feature-yes}
  - **Allows sending to bech32 P2WPKH addresses**<br>
    Allows sending to bech32 P2WPKH native segwit addresses.
  {% when "false" %}{:.feature-no}
  - **Does not allow sending to bech32 P2WPKH addresses**<br>
    Does not allow sending to bech32 P2WPKH native segwit addresses.
  {% when "na" %}{:.feature-neutral}
  - **No sending capabilities**<br>
    There are no sending capabilities for this service.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested: Can transaction outputs be sent to bech32 P2WPKH addresses?**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="segwit-send-bech32_p2wsh"}
{% case segwit.send.bech32_p2wsh %}
  {% when "true" %}{:.feature-yes}
  - **Allows sending to bech32 P2WSH addresses**<br>
    Allows sending to bech32 P2WSH native segwit addresses.
  {% when "false" %}{:.feature-no}
  - **Does not allow sending to bech32 P2WSH addresses**<br>
    Does not allow sending to bech32 P2WSH native segwit addresses.
  {% when "na" %}{:.feature-neutral}
  - **No sending capabilities**<br>
    There are no sending capabilities for this service.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested: Can transaction outputs be sent to bech32 P2WSH addresses?**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="segwit-send-bech32m"}
{% case segwit.send.bech32m %}
  {% when "true" %}{:.feature-yes}
  - **Allows sending to bech32m addresses**<br>
    Allows sending to bech32m (P2TR) addresses.
  {% when "false" %}{:.feature-no}
  - **Does not allow sending to bech32m addresses**<br>
    Does not allow sending to bech32m addresses.
  {% when "na" %}{:.feature-neutral}
  - **No sending capabilities**<br>
    There are no sending capabilities for this service.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested: Can transaction outputs be sent to bech32m addresses?**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="segwit-send-change_bech32"}
{% case segwit.send.change_bech32 %}
  {% when "true" %}{:.feature-yes}
  - **Creates bech32 change addresses**<br>
    When sending, generates bech32 (either P2WPKH or P2WSH) segwit change addresses.
  {% when "false" %}{:.feature-no}
  - **Does not create bech32 change addresses**<br>
    When sending, does not generate bech32 (either P2WPKH or P2WSH) segwit change addresses.
  {% when "na" %}{:.feature-neutral}
  - **No sending or change capabilities**<br>
    There are no sending capabilities for this service or sending does not
    generate change.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested: Can bech32 addresses be used for change?**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

</div>{% comment %}<!-- end: compat-list -->{% endcomment %}

### Usability

{% include functions/compat-gallery.md examples=tool.segwit.examples %}

{% else %}
*We have not yet tested {{tool.name}} for segwit capabilities.*
{% endif %}
