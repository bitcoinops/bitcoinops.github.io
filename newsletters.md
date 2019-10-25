---
type: pages
layout: page
lang: en
title: Newsletters
name: newsletters
permalink: /en/newsletters/
share: false
version: 1
---

{% include newsletter-signup.html %}

{% assign posts_newsletters_en = site.posts | where:"lang","en" | where:"type","newsletter" %}

<ul class="post-list">
  {%- for post in posts_newsletters_en -%}
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

<p class="rss-subscribe">subscribe <a href="{{ "/feed.xml" | relative_url }}">via RSS</a></p>