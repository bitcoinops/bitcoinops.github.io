{% capture /dev/null %}
  {% assign entries = include.entries | natural_sort: "title" %}
  {% capture first_link %}[{{entries[0].title}}]({{entries[0].url}}){% endcapture %}
  {% capture last_link %}[{{entries[-1].title}}]({{entries[-1].url}}){% endcapture %}
  {% for entry in entries %}
    {% capture entry_link %}[{{entry.title}}]({{entry.url}}){% endcapture %}
    {% if prev_link %}
      {% assign next_link = entry_link %}
      {% break %}
    {% endif %}
    {% if entry.url == page.url %}
      {% assign prev_link = prev_entry | default: last_link %}
    {% endif %}
    {% assign prev_entry = entry_link %}
  {% endfor %}
{% endcapture %}
