{% capture /dev/null %}

{% assign cell_emoji = "&#x274C;" %}  <!--- Default No Support --->

{% case include.input2 %}
  {% when 'Full Support (send & receive)' %} <!--- If a preferred implementation is supported, then we use that emoji--->
    {% assign cell_emoji = "&#x2705;" %}  <!--- Full Support --->
  {% when 'Send Support' %}
    {% assign cell_emoji = "&#x1F4B8;" %} <!--- Send Support --->
  {% when 'Not Applicable' %}
    {% assign cell_emoji = "&#x2796;" %} <!--- Not Applicable --->
{% endcase %}

{% if cell_emoji == "&#x274C;" %} <!--- If the preferred implementation has No Support, check if an alternate implementation is supported --->
  {% if include.input3 == "Full Support (send & receive)" or include.input3 == "Send Support" %}
    {% assign cell_emoji = "<span class='checkmark'>&#10004;</span>" %}  <!--- If an alternate implementation is supported, then we use that emoji--->
  {% endif %}
{% endif %}

{% assign cell_tooltip = include.input %}
{% assign cell_tooltip2 = include.input2 %}
{% assign cell_tooltip3 = include.input3 %}
{% assign cell_tooltip4 = include.input4 %}

{% endcapture %}


<div class="tooltip-container">

{{cell_emoji}}

{% if include.input3 == "Full Support (send & receive)" or include.input3 == "Send Support" %}
      {% if cell_emoji == "&#x2705;" or cell_emoji == "&#x1F4B8;" %} <!--- Denotes an alternate in addition to a preferred implementation--->
        <font size="4"><b>&#178;</b></font>
      {% endif %}
{% endif %}

<span class="tooltip">{{cell_tooltip}}{{cell_tooltip2}} <br><br> Alternate - {{cell_tooltip3}} - {{cell_tooltip4}} </span>
</div>

</td>
