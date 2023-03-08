---
type: pages
layout: default
---
<link rel="stylesheet" href="/assets/css/main.css">

<!-- turn off podcast localization for now
<div class="localization">
  <a href="/en/podcast/">en</a>
  {% for lang in site.languages %}
    | <a href="/{{ lang.code }}/podcast/">{{lang.code}}</a>
  {% endfor %}
</div>-->

<h1 class="post-title">Podcast</h1>

Join Bitcoin Optech as we discuss Bitcoin and Lightning technology each week and review our newsletters.

{% include functions/podcast-links.md %}

{% if content != ""%}
  <div class="post-content">
    {{ content }}
  </div>
{%- endif -%}

{% assign posts_podcast = site.posts | where:"lang", page.lang | where:"type","podcast" %}

<ul class="post-list">
  {%- for post in posts_podcast -%}
  <li>
    {%- assign date_format = site.minima.date_format | default: "%b %-d, %Y" -%}
    <span class="post-meta">{{ post.date | date: date_format }}</span>
    <h3>
      <a class="post-link" href="{{ post.url | relative_url }}">
        {{ post.title | escape }}
      </a>
    </h3>
    {%- if site.show_excerpts -%}
      {{ post.excerpt }}
    {%- endif -%}
  </li>
  {%- endfor -%}
</ul>
