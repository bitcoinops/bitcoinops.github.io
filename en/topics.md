---
title: Topics
permalink: /en/topics/
layout: page
---
{% include linkers/topic-pages.md %}
{% assign year_ago_date = 'now' | date: "%s" | minus: '31536000' %}

{% comment %}<!-- Build an "ENDTOPIC"-separated string with
Markdown-style links for each topic or topic alias.  We use
Markdown-style links, e.g. [Name](URL), instead of HTML-style
links, e.g. <a href=URL>Name</a>, so that it's easy to sort by name
rather than URL. -->{% endcomment %}
{% capture raw_topics_list %}
{%- for topic in site.topics -%}
  {%- for alias in topic.aliases -%}
    <!--{% include functions/sort-rename.md name=alias %}-->*[{{alias}}]({{topic.url}})*ENDTOPIC
  {%- endfor -%}
  {% assign hot_topic = false %}
  {%- for mention in topic.optech_mentions -%}
    {%- include functions/get-mention-date.md -%}
    {%- assign mydate = date | date: "%s" | plus: 0 -%}
    {%- if mydate > year_ago_date -%}
      {% assign hot_topic = true %}
      {%- break -%}
    {%- endif -%}
  {%- endfor -%}
  {%- if hot_topic == true %}<!--{% include functions/sort-rename.md name=topic.title %}-->**[{{topic.title}}]({{topic.url}})**ENDTOPIC
  {%- else -%}<!--{% include functions/sort-rename.md name=topic.title %}-->[{{topic.title}}]({{topic.url}})ENDTOPIC{%- endif -%}
{%- endfor -%}
{% endcapture %}

{% assign topics_list = raw_topics_list | split: 'ENDTOPIC' | sort_natural %}
{% assign number_of_topics = site.topics | size %}
{% assign number_of_entries = topics_list | size %}
{% assign number_of_aliases = number_of_entries | minus: number_of_topics %}

<div class="center" markdown="1">
{{number_of_topics}} topics (and
{{number_of_aliases}} aliases in *italics* for topics with alternative
names).

{:.center}
{% assign previous_character = '' %}
{% for entry in topics_list %}
  {%- assign first_character = entry | remove_first: '<!--' | truncate: 1, '' | downcase -%}{%- comment -%}close html comment for syntax hilite -->{%- endcomment -%}
  {%- if first_character != previous_character -%}
    {%- if previous_character != nil -%}
      [{{first_character | upcase}}](#{{first_character}}){{' '}}
    {%- endif -%}
  {%- endif -%}
  {%- assign previous_character = first_character -%}
{% endfor %}
</div>

<div>{% comment %}<!-- enclosing in a div forces this to be interpreted
as HTML rather than Markdown so indentation over 4 characters doesn't
produce code blocks -->{% endcomment %}

{% assign previous_character = '' %}
{% for entry in topics_list %}
  {% assign first_character = entry | remove_first: '<!--' | truncate: 1, '' | downcase %}{%- comment -%}close html comment for syntax hilite -->{%- endcomment %}
  {% if first_character != previous_character %}
    {% if previous_character != '' %}</ul>{% endif %}
    <h3 id="{{first_character}}">{{first_character | upcase}}</h3>
    <ul>
  {% endif %}
  <li>{{entry | markdownify | remove: "<p>" | remove: "</p>" | strip }}</li>
  {% assign previous_character = first_character %}
{% endfor %}
</ul>

</div>

{% include linkers/request-a-topic.md %}
