---
title: Topics
permalink: /en/topic-dates/
layout: page
---
{% include linkers/topic-pages.md %}
<!-- Build a list of months in reverse chronological order -->
{% assign this_year = site.time | date: "%Y" | plus: 0 %}<!-- "plus: 0" casts string to int -->
{% capture months %}
{%- for year in (2018..2099) -%}
  {%- if year > this_year -%}{% break %}{%- endif -%}
  {%- for month in (1..9) -%}
    {{year}}-0{{month}}|
  {%- endfor -%}
  {%- for month in (10..12) -%}
    {{year}}-{{month}}|
  {%- endfor -%}
{%- endfor -%}
{% endcapture %}
{% assign months = months | split: "|" | reverse %}

<!-- initialize some globals -->
{% assign number_of_events = 0 %}
{% assign number_of_months = 0 %}

<!-- capture the main content instead of rendering it immediately so
we can compute some metadata in the loops and then display that metadata
before the main content -->
{% capture list %}
  {%- for month in months -%}
    {%- assign month_topics = "" -%}
    {%- for topic in site.topics -%}
    {%- assign mymentions = '' -%}
      {%- for mention in topic.optech_mentions -%}
        {%- include functions/get-mention-date.md -%}
        {%- assign mydate = date | date: "%Y-%m-%d" -%}
        {%- if mydate contains month -%}
          {% capture mymentions %}{{mymentions}}{{mention.title | markdownify | remove: "<p>" | remove: "</p>" | strip }}&nbsp;<a href="{{mention.url}}">🔗</a>ENDMENTION{% endcapture %}
          {% assign number_of_events = number_of_events | plus: 1 %}
        {%- endif -%}
      {%- endfor -%}

      {%- assign mymentions = mymentions | split: "ENDMENTION" -%}
      {%- assign mymentions_size = mymentions | size -%}
      {%- assign mentions_countdown = 999 | minus: mymentions_size -%}
      {%- if mymentions_size > 0 -%}
        {% capture month_topics %}{{month_topics}}{{mentions_countdown}}SIZE_DELIMITER<b><a href="{{topic.url}}">{{topic.title}}</a></b>TITLE_DELIMITER{{mymentions | join: "ENDMENTION"}}TOPIC_DELIMITER{% endcapture %}
      {%- endif -%}
    {%- endfor -%}

    {%- assign month_topics = month_topics | split: "TOPIC_DELIMITER" | sort -%}
    {% assign month_topics_size = month_topics | size %}
    {%- if month_topics_size > 0 -%}<h3 id="d{{month}}">{{month | append: "-01" | date: "%B %Y" }}</h3>
      {% assign number_of_months = number_of_months | plus: 1 %}
      <ul>
      {% for month_topic in month_topics -%}
        {%- assign topic_data = month_topic | split: "SIZE_DELIMITER" -%}
        {%- assign topic_data = topic_data[1] | split: "TITLE_DELIMITER" -%}
        {%- assign topic_title = topic_data[0] -%}
        {%- assign topic_mentions = topic_data[1] | split: "ENDMENTION" -%}
        {%- assign topic_size = topic_mentions | size -%}

        <li>{{topic_title}}
          <ul>
          {%- for topic_mention in topic_mentions -%}
            <li>{{topic_mention}}</li>
          {%- endfor -%}
          </ul>
        </li>
      {%- endfor -%}
      </ul>
    {% endif %}
  {%- endfor -%}
{% endcapture %}

<div class="center" markdown="1">
{{number_of_events}} indexed events in {{number_of_months}} months <!-- {{mentions | size}} events including duplicates -->

[2018](#d2018-12) | [2019](#d2019-12) | [2020](#d2020-12) |
[2021](#d2021-12)
</div>

<div>{% comment %}<!-- enclosing in a div forces this to be interpreted
as HTML rather than Markdown so indentation over 4 characters doesn't
produce code blocks -->{% endcomment %}
{{list}}
</div>

{% include linkers/request-a-topic.md %}
