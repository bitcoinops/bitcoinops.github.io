---
title: Topics
permalink: /en/topic-dates/
layout: page
---
{% include linkers/topic-pages.md %}
<div>{% comment %}<!-- enclosing in a div forces this to be interpreted
as HTML rather than Markdown so indentation over 4 characters doesn't
produce code blocks -->{% endcomment %}

{% capture raw_mentions %}
{%- for topic in site.topics -%}
  {%- for mention in topic.optech_mentions -%}
    {{mention.date}} <a href="{{topic.url}}">{{topic.title}}</a>&#8212;{{mention.title}}&nbsp;<a href="{{mention.url}}">🔗</a>ENDMENTION
  {%- endfor -%}
{%- endfor -%}
{% endcapture %}
{% assign mentions = raw_mentions | split: 'ENDMENTION' | sort | reverse %}

{% for mention in mentions %}
  {% assign mention_date = mention | truncate: 10, '' %}
  {% assign year_month = mention | truncate: 7, '' %}
  {% if year_month != lastym %}
    {% if lastym != nil %}</ul>{% endif %}
    <h3>{{mention_date | date: '%B %Y'}}</h3>
    <ul>
  {% endif %}
<li>{{mention | slice: 11, 99999999 | markdownify | remove: "<p>" | remove: "</p>" | strip }}</li>
{% assign lastym = year_month %}
{% endfor %}
</ul>

</div>

{% include linkers/request-a-topic.md %}
