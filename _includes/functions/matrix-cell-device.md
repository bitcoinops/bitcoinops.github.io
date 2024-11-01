{% capture /dev/null %}

    {% assign cell_emoji_original = include.state %} <!--- No --->

    {% assign desktop_icon = "&#128187;" %}
    {% assign mobile_icon = "&#128241;" %}

    {% assign cell_emoji = cell_emoji_original | replace: "Desktop", desktop_icon %}
    {% assign cell_emoji = cell_emoji | replace: "Mobile", mobile_icon %}
    {% assign cell_emoji = cell_emoji | replace: ",", "" %}

    {% if cell_emoji == "" %}
      {% assign cell_emoji = "&#x2796;" %} <!--- Not Applicable --->
      {% assign cell_emoji_original = "Not Applicable" %} <!--- Not Applicable --->
    {% endif %}

    {% assign cell_tooltip = cell_emoji_original %} <!--- No --->

{% endcapture %}

<div class="tooltip-container">
    {{cell_emoji}}
    <span class="tooltip">{{cell_tooltip}}</span>
</div>

</td>
