![{{tool.name|escape_once}}]({{tool.logo}}){:.third-party-logo}{:title="{{tool.name}}"}

## Replace-by-Fee (RBF)

{% assign tested = tool.rbf.tested. %}
**Tested**: {% if tested.version != "n/a" %} *version {{tested.version}}* {% endif %} on *{{tested.platforms}}*

**Tested on**: *{{tested.date}}*

**What is Replace-by-Fee (RBF)?** An unconfirmed transaction can be replaced by another version of the
same transaction that spends the same inputs.  Most full nodes support
this if the earlier transaction enables [BIP125](https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki) signaling and the
replacement transaction increases the amount of fee paid.  In terms of
block chain space used, this is the most efficient form of fee bumping.

### Receiving support

{:id="receive-notification"}
{% assign rbf = tool.rbf.features. %}
{% case rbf.receive.notification %}
  {% when "true" %}{:.feature-yes}
  - **Notification notes RBF**<br>
    Notification of incoming transaction notes that the transaction signals RBF.
  {% when "false" %}{:.feature-no}
  - **Notification does not note RBF**<br>
    Notification of incoming transaction does not note that the transaction signals RBF.
  {% when "na" %}{:.feature-neutral}
  - **No notification**<br>
    There are no incoming transaction notifications for this service.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="receive-list"}
{% case rbf.receive.list %}
  {% when "true" %}{:.feature-yes}
  - **Received transaction labeled replaceable in list**<br>
    Visually indicates that an incoming transaction has signaled RBF.
  {% when "false" %}{:.feature-no}
  - **Received transaction not labeled replaceable in list**<br>
    Does not visually indicate that an incoming transaction has signaled RBF.
  {% when "na" %}{:.feature-neutral}
  - **This services does not handle incoming transactions**<br>
    Does not support incoming transactions.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="receive-details"}
{% case rbf.receive.details %}
  {% when "true" %}{:.feature-yes}
  - **Received transaction labeled replaceable in transaction details**<br>
    Visually indicates that a received transaction has signaled RBF when viewing the transaction details.
  {% when "false" %}{:.feature-no}
  - **Received transaction not labeled replaceable in transaction details**<br>
    Does not visually indicate that a received transaction has signaled RBF when viewing the transaction details.
  {% when "na" %}{:.feature-neutral}
  - **Does not show transaction details**<br>
    Does not show transaction details natively. Usually this means the service links to a block explorer for transaction details.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="receive-replaced"}
{% if rbf.receive.shows_replaced_version == "true" and rbf.receive.shows_original_version == "true"  %}
  {:.feature-yes}
  - **Shows replacement and original transactions**<br>
    Both the original transaction and replacement transaction(s) are shown in the
    transaction list.
{% elsif rbf.receive.shows_replaced_version == "na" or
    rbf.receive.shows_original_version == "na" %}
  {:.feature-neutral}
  - **No transaction list**<br>
    Does not support listing of transactions.
{% elsif rbf.receive.shows_replaced_version == "untested" or
    rbf.receive.shows_original_version == "untested" %}
  {:.feature-neutral}
  - **Not tested**<br>
    We either didn’t test this or could not appropriately determine the results.
{% elsif rbf.receive.shows_replaced_version == "true" %}
  {:.feature-yes}
  - **Shows replacement transaction only**<br>
    Only the replacement transaction is shown in the transaction list. No original
    transaction is shown.
{% elsif rbf.receive.shows_original_version == "true" %}
  {:.feature-no}
  - **Shows original transaction only**<br>
    Only the original transaction is shown in transaction list. Replacement transactions
    are not shown.
{% elsif rbf.receive.shows_original_version == "false" and rbf.receive.shows_replaced_version == "false" %}
  {:.feature-no}
  - **No unconfirmed transactions**<br>
    Neither the original nor replacement transactions are shown in the
    transaction list. Most likely unconfirmed transactions are not supported.
{% else %} {% include ERROR_42_UNEXPECTED_VALUE %}
{% endif %}

### Sending support

{:id="send-signals_bip125"}
{% case rbf.send.signals_bip125 %}
  {% when "true" %}{:.feature-yes}
  - **Signals BIP125 replacability when sending transactions**<br>
    Allows sending of BIP125 opt-in-RBF transactions in the interface.
  {% when "false" %}{:.feature-no}
  - **Does not signal BIP125 replacability when sending transactions**<br>
    Does not allow sending of BIP125 opt-in-RBF transactions in the interface.
  {% when "na" %}{:.feature-neutral}
  - **Does not send transactions**<br>
    Does not support sending of any transactions.
  {% when "untested" %}{:.feature-neutral}
  - **Not Tested**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="send-list"}
{% case rbf.send.list %}
  {% when "true" %}{:.feature-yes}
  - **Sent transaction labeled replaceable in list**<br>
    Visually indicates that an outgoing transaction has signaled RBF.
  {% when "false" %}{:.feature-no}
  - **Sent transaction not labeled replaceable in list**<br>
    Does not visually indicate that an outgoing transaction has signaled RBF.
  {% when "na" %}{:.feature-neutral}
  - **No transaction list**<br>
    Does not show a transaction list natively.
  {% when "untested" %}{:.feature-neutral}
  - **Not Tested**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="send-details"}
{% case rbf.send.details %}
  {% when "true" %}{:.feature-yes}
  - **Sent transaction labeled replaceable in transaction details**<br>
    Visually indicates that a sent transaction has signaled RBF when viewing the transaction details.
  {% when "false" %}{:.feature-no}
  - **Sent transaction not labeled replaceable in transaction details**<br>
    Does not visually indicate that a sent transaction has signaled RBF when viewing the transaction details.
  {% when "na" %}{:.feature-neutral}
  - **Does not show transaction details**<br>
    Does not show transaction details natively. Usually this means the service links to a block explorer for transaction details.
  {% when "untested" %}{:.feature-neutral}
  - **Not tested**<br>
    We either didn’t test this or could not appropriately determine the results.
  {% else %}{% include ERROR_42_UNEXPECTED_VALUE %}
{% endcase %}

{:id="send-replaced"}
{% if rbf.send.shows_replaced_version == "true" and rbf.send.shows_original_version == "true"  %}
  {:.feature-yes}
  - **Shows replacement and original transactions**<br>
    Both the original transaction and replacement transactions are shown in the
    transaction list.
{% elsif rbf.send.shows_replaced_version == "na" or
    rbf.send.shows_original_version == "na" %}
  {:.feature-neutral}
  - **No replacements in transaction list**<br>
    Because no transaction replacement is possible, we could not test whether
    original or replacement sent transactions are shown after replacement.
{% elsif rbf.send.shows_replaced_version == "untested" or
    rbf.send.shows_original_version == "untested" %}
  {:.feature-neutral}
  - **Not tested**<br>
    We either didn’t test this or could not appropriately determine the results.
{% elsif rbf.send.shows_replaced_version == "true" %}
  {:.feature-yes}
  - **Shows replacement transaction only**<br>
    Only the replacement transaction is shown in the transaction list. No original
    transaction is shown.
{% elsif rbf.send.shows_original_version == "true" %}
  {:.feature-no}
  - **Shows original transaction only**<br>
    Only the original transaction shown in transaction list. Replacement transactions are
    not shown.
{% elsif rbf.send.shows_original_version == "false" and rbf.send.shows_replaced_version == "false" %}
  {:.feature-no}
  - **No unconfirmed transactions**<br>
    Neither the original nor replacement transactions are shown in the
    transaction list. Most likely unconfirmed transactions are not supported.
{% else %} {% include ERROR_42_UNEXPECTED_VALUE %}
{% endif %}

### Usability

*Click on a thumbnail for a larger image or to play its video.*

{% for example in tool.rbf.examples %}
  {% capture /dev/null %}
  {% if example.link %}
    {% assign link = example.link %}
  {% else %}
    {% assign link = example.image %}
  {% endif %}
  {% endcapture %}
<div markdown="1" class="compat-usability">
[![{{example.caption|escape_once}}]({{example.image}})]({{link}})
<br /><span class="compat-caption">{{example.caption}}</span>
</div>
  {% assign break = forloop.index | modulo:2 %}
  {% if break == 0 %}<br clear="both" />{% endif %}
{% endfor %}
