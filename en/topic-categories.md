---
title: Topics
permalink: /en/topic-categories/
layout: page
---
{% include linkers/topic-pages.md %}

<div>{% comment %}<!-- enclosing in a div forces this to be interpreted
as HTML rather than Markdown so indentation over 4 characters doesn't
produce code blocks -->{% endcomment %}

{% capture raw_categories %}
{%- for topic in site.topics -%}
  {%- if topic.categories == empty -%}
    {% include ERROR_92_MISSING_TOPIC_CATEGORY %}
  {%- endif -%}
  {%- for category in topic.categories -%}
    {{category}}|
  {%- endfor -%}
{%- endfor -%}
{% endcapture %}
{% assign categories = raw_categories | split: "|" | sort_natural | uniq %}

{% for category in categories %}
  <h3 id="{{category | slugify}}">{{category}}</h3>
  <ul>
  {% for topic in site.topics %}
    {% if topic.categories contains category %}
      <li><a href="{{topic.url}}">{{topic.title}}</a></li>
    {% endif %}
  {% endfor %}
  </ul>
{% endfor %}

</div>

{% include linkers/request-a-topic.md %}
