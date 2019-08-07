---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---

{:.logo}
![Optech Logo](/img/logos/optech-notext.png)

Bitcoin Optech helps Bitcoin users and businesses integrate scaling
technologies.

We provide [workshops][], [documentation][scaling book], [weekly
newsletters][], [original research][dashboard], [case studies and
announcements][blog], [analysis of Bitcoin software and services][compatibility], and help facilitate improved relations between businesses
and the open source community.

[Learn more about us][about].

[scaling book]: https://github.com/bitcoinops/scaling-book
[workshops]: /workshops
[weekly newsletters]: /en/newsletters/
[dashboard]: https://dashboard.bitcoinops.org/
[blog]: /en/blog/
[about]: /about
[compatibility]: /en/compatibility/

<h2>Recent newsletters and blog posts</h2>
<ul class="post-list">
  {%- for post in site.posts limit:3 -%}
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

<p class="rss-subscribe">View more <a href="/en/newsletters/">newsletters</a> or <a href="/en/blog">blog posts</a>. Learn about new content by subscribing via email or <a href="{{ "/feed.xml" | relative_url }}">RSS</a>.</p>

{% include newsletter-signup.html %}

{% include members.html %}
