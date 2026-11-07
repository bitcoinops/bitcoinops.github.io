{%- assign feed_lang = page.lang | default: "en" -%}
{%- assign feed_path = "/feed.xml" -%}
{%- if feed_lang != "en" -%}{%- assign feed_path = "/" | append: feed_lang | append: "/feed.xml" -%}{%- endif -%}
<p class="rss-subscribe">subscribe <a href="{{ feed_path | relative_url }}">via RSS</a></p>
