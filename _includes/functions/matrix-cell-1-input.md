{% capture /dev/null %}

{% if include.state == "Full Support (send & receive)" %}
  {% assign cell_emoji = "&#x2705;" %} <!--- Full Support --->
  {% assign cell_tooltip = "Full Support (send & receive)" %} <!--- Full Support --->
{% elsif include.state == "Send Support" %}
  {% assign cell_emoji = "&#x1F4B8;" %}  <!--- Send Support --->
  {% assign cell_tooltip = "Send Support" %} <!--- Send Support --->
{% elsif include.state == "No Support" %}
  {% assign cell_emoji = "&#x274C;" %}  <!--- No Support --->
  {% assign cell_tooltip = "No Support" %} <!--- No Support --->
{% elsif include.state == "Unknown" %}
    {% assign cell_emoji = "&#129335;" %} <!--- Unknown --->
    {% assign cell_tooltip = "Unknown" %} <!--- Unknown --->
{% elsif include.state == "Not Applicable" %}
  {% assign cell_emoji = "&#x2796;" %} <!--- Not Applicable --->
  {% assign cell_tooltip = "Not Applicable" %} <!--- Not Applicable --->
{% elsif include.state == "Yes" %}
  {% assign cell_emoji = "&#x2705;" %} <!--- Yes --->
  {% assign cell_tooltip = "Yes" %} <!--- Yes --->
{% elsif include.state == "No" %}
  {% assign cell_emoji = "&#x274C;" %} <!--- No --->
  {% assign cell_tooltip = "No" %} <!--- No --->
{% elsif include.state | slice: 0, 1 == "V" %}
    {% assign cell_emoji = include.state %} <!--- P2TR --->
    {% assign cell_tooltip = include.state %} <!--- P2TR --->
{% elsif include.state | slice: 0, 1 == "P" %}
    {% assign cell_emoji = include.state %} <!--- P2TR --->
    {% assign cell_tooltip = include.state %} <!--- P2TR --->
{% endif %}

{% endcapture %}

<div class="tooltip-container">
    {{cell_emoji}}
    <span class="tooltip">{{cell_tooltip}}</span>
</div>

</td>
