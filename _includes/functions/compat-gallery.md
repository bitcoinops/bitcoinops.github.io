*Click on a thumbnail for a larger image or to play its video.*

{% for example in include.examples %}
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
