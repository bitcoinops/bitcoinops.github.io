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
{% elsif include.state == "Not Applicable" %}
  {% assign cell_emoji = "&#x2796;" %} <!--- Not Applicable --->
  {% assign cell_tooltip = "Not Applicable" %} <!--- Not Applicable --->
{% elsif include.state == "Yes" %}
  {% assign cell_emoji = "&#x2705;" %} <!--- Yes --->
  {% assign cell_tooltip = "Yes" %} <!--- Yes --->
{% elsif include.state == "No" %}
  {% assign cell_emoji = "&#x274C;" %} <!--- No --->
  {% assign cell_tooltip = "No" %} <!--- No --->
{% elsif include.state == "V0" %}
    {% assign cell_emoji = "V0" %} <!--- No --->
    {% assign cell_tooltip = "V0" %} <!--- No --->
{% elsif include.state == "V2" %}
    {% assign cell_emoji = "V2" %} <!--- No --->
    {% assign cell_tooltip = "V2" %} <!--- No --->

  {% endif %}

{% endcapture %}

<div class="tooltip-container">
    {{cell_emoji}}
    <span class="tooltip">{{cell_tooltip}}</span>
</div>

</td>
