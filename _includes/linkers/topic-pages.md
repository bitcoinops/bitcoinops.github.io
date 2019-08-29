{% capture /dev/null %}
{% if page.url == "/en/topics/" %}
  {% assign _index_links = "**Alphabetically**" %}
{% else %}
  {% assign _index_links = "[Alphabetically](/en/topics/)" %}
{% endif %}
{% if page.url == "/en/topic-dates/" %}
  {% assign _index_links = _index_links | append: " \| **By date**" %}
{% else %}
  {% assign _index_links = _index_links | append: " \| [By date](/en/topic-dates/)" %}
{% endif %}
{% if page.url == "/en/topic-categories/" %}
  {% assign _index_links = _index_links | append: " \| **By category**" %}
{% else %}
  {% assign _index_links = _index_links | append: " \| [By category](/en/topic-categories/)" %}
{% endif %}
{% endcapture %}
{:.center}
{{_index_links}}
