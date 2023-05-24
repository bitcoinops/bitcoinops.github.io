---
title: People
permalink: /en/people/
layout: page
---
{% capture raw_people_list %}
{%- for person in site.people -%}
  <!--{% include functions/sort-rename.md name=topic.title %}-->[{{person.title}}]({{person.url}})ENDTOPIC
{%- endfor -%}
{% endcapture %}

{% assign people_list = raw_people_list | split: 'ENDTOPIC' | sort_natural %}
{% assign number_of_people = site.people | size %}

<div class="center" markdown="1">
{{number_of_people}} people
</div>

<div>{% comment %}<!-- enclosing in a div forces this to be interpreted
as HTML rather than Markdown so indentation over 4 characters doesn't
produce code blocks -->{% endcomment %}

{% assign previous_character = '' %}
{% for entry in people_list %}
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
