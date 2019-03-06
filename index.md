---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---

{:.logo}
![Optech Logo](/img/logos/optech-notext.png)

The Bitcoin Operations Technology Group (Optech) works to bring the best
open source technologies and techniques to Bitcoin-using businesses in
order to lower costs and improve customer experiences.

An initial focus for the group is working with its member organizations to
reduce transaction sizes and minimize the effect of subsequent transaction fee
increases.  We provide [workshops][], [documentation][scaling book],
[weekly newsletters][], [original research][dashboard], [case studies
and announcements][blog], and help facilitate improved relations between
businesses and the open source community.

[scaling book]: https://github.com/bitcoinops/scaling-book
[workshops]: /workshops
[weekly newsletters]: /en/newsletters/
[dashboard]: https://dashboard.bitcoinops.org/
[blog]: /en/blog/

Optech does not exist to make a profit, and all materials and documentation
produced are released under the MIT license. We are supported by our generous
founding sponsors and contributions from member companies.

If you're an engineer or manager at a Bitcoin company or an open source contributor and you'd like to be a part of this, please
contact us at [info@bitcoinops.org](mailto:info@bitcoinops.org).

{% include newsletter-signup.html %}

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

{% include members.html %}

{% include sponsors.html %}
