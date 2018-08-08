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
increases.

Long-term goals include providing documentation and training materials, a
weekly newsletter, original research, and facilitating improved relations
between businesses and the open source community.

Optech does not exist to make a profit, and all materials and documentation
produced are released under the MIT license. We are supported by our generous
founding sponsors and contributions from member companies.

If you're an engineer or manager at a Bitcoin company or an open source contributor and you'd like to be a part of this, please
contact us at [info@bitcoinops.org](mailto:info@bitcoinops.org).

{% include newsletter-signup.html %}

<h2>{{ page.list_title | default: "Posts" }}</h2>
<ul class="post-list">
  {%- for post in site.posts -%}
  {%- if post.type == 'posts' -%}
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
  {%- endif -%}
  {%- endfor -%}
</ul>

<p class="rss-subscribe">subscribe <a href="{{ "/feed.xml" | relative_url }}">via RSS</a></p>

{% include members.html %}

{% include sponsors.html %}
