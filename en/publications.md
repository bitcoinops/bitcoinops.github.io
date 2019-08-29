---
title: Publications
layout: page
permalink: /en/publications/
---
{:.center}
Recent publications from our [blog posts][] and [newsletters][].

[blog posts]: /en/blog/
[newsletters]: /en/newsletters/

<ul class="post-list">
  {%- for post in site.posts limit:20 -%}
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

