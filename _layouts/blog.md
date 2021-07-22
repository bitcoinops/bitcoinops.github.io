---
type: pages
layout: default
---
<link rel="stylesheet" href="/assets/css/main.css">

<div class="localization">
  <a href="/en/blog/">en</a>
  {% for lang in site.languages %}
    | <a href="/{{ lang.code }}/blog/">{{lang.code}}</a>
  {% endfor %}
</div>

<h1 class="post-title">Blog</h1>

{% if content != ""%}
  <div class="post-content">
    {{ content }}
  </div>
{%- endif -%}

{% assign posts_blog = site.posts | where:"lang", page.lang | where:"type","posts" %}

<ul class="post-list">
  {%- for post in posts_blog -%}
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

{%- if page.lang == "en" -%}
  <p class="rss-subscribe">subscribe <a href="{{ "/feed.xml" | relative_url }}">via RSS</a></p>
{%- endif -%}
