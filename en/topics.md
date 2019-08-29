---
title: Topics
permalink: /en/topics/
layout: page
---
{% include linkers/topic-pages.md %}

{:.center}
Some topics listed multiple times under different names.  Alternative
names are *italicized.*

<div>{% comment %}<!-- enclosing in a div forces this to be interpreted
as HTML rather than Markdown so indentation over 4 characters doesn't
produce code blocks -->{% endcomment %}

{% comment %}<!-- Build an "ENDTOPIC"-separated string with
Markdown-style links for each topic or topic alias.  We use
Markdown-style links, e.g. [Name](URL), instead of HTML-style
links, e.g. <a href=URL>Name</a>, so that it's easy to sort by name
rather than URL. -->{% endcomment %}
{% capture raw_topics_list %}
{%- for topic in site.topics -%}
  <!--{{topic.title}}-->[{{topic.title}}]({{topic.url}})ENDTOPIC
  {%- for alias in topic.aliases -%}
    <!--{{alias}}-->*[{{alias}}]({{topic.url}})*ENDTOPIC
  {%- endfor -%}
{%- endfor -%}
{% endcapture %}

{% assign topics_list = raw_topics_list | split: 'ENDTOPIC' | sort_natural %}
{% for entry in topics_list %}
  {% assign first_character = entry | remove_first: '<!--' | truncate: 1, '' | downcase %}
  {% if first_character != previous_character %}
    {% if previous_character != nil %}</ul>{% endif %}
    <h3 id="{{first_character}}">{{first_character | upcase}}</h3>
    <ul>
  {% endif %}
  <li>{{entry | markdownify | remove: "<p>" | remove: "</p>" | strip }}</li>
  {% assign previous_character = first_character %}
{% endfor %}
</ul>

</div>

{% include linkers/request-a-topic.md %}
