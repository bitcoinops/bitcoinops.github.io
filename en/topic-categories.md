---
title: Topics
permalink: /en/topic-categories/
layout: page
---
{% include linkers/topic-pages.md %}

{% capture raw_categories %}
{%- for topic in site.topics -%}
  {%- if topic.topic-categories == empty -%}
    {% include ERROR_92_MISSING_TOPIC_CATEGORY %}
  {%- endif -%}
  {%- for category in topic.topic-categories -%}
    {{category}}|
  {%- endfor -%}
{%- endfor -%}
{% endcapture %}
{% assign categories = raw_categories | split: "|" | sort_natural | uniq %}

<div class="center" markdown="1">

{{ categories | size }} categories for {{site.topics | size}} unique
topics, with many topics appearing in multiple categories.

{% for category in categories %} [{{category | replace: ' ', '&nbsp;'}}](#{{category | slugify}})&nbsp;{% unless forloop.last %}\|{% endunless %}{% endfor %}
</div>

<div>{% comment %}<!-- enclosing in a div forces this to be interpreted
as HTML rather than Markdown so indentation over 4 characters doesn't
produce code blocks -->{% endcomment %}

{% for category in categories %}
  <h3 id="{{category | slugify}}">{{category}}</h3>
  <ul>
  {% for topic in site.topics %}
    {% if topic.topic-categories contains category %}
      <li><a href="{{topic.url}}">{{topic.title}}</a></li>
    {% endif %}
  {% endfor %}
  </ul>
{% endfor %}

</div>

{% include linkers/request-a-topic.md %}
