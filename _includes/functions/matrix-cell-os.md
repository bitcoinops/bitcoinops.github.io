{% capture /dev/null %}

    {% assign cell_emoji_original = include.state %} <!--- No --->


    {% assign android_icon = "<i class='fab fa-android' style='font-size: 24px; color: green;'></i>" %}
    {% assign linux_icon = "<i class='fab fa-linux' style='font-size: 24px; color: black;'></i>" %}
    {% assign windows_icon = "<i class='fab fa-windows' style='font-size: 24px; color: blue;'></i>" %}
    {% assign apple_icon = "<i class='fab fa-apple' style='font-size: 24px; color: black;'></i>" %}


    {% assign cell_emoji = cell_emoji_original | replace: "Android", android_icon %}
    {% assign cell_emoji = cell_emoji | replace: "Linux", linux_icon %}
    {% assign cell_emoji = cell_emoji | replace: "Windows", windows_icon %}

    <!--- Ensure Apple is only shown once --->
    {% assign cell_emoji = cell_emoji | replace: "iOS, OS", "OS" %}
    {% assign cell_emoji = cell_emoji | replace: "iOS", apple_icon %}
    {% assign cell_emoji = cell_emoji | replace: "OS", apple_icon %}
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
