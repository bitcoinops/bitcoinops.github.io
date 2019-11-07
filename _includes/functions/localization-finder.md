{% assign baseurl = page.permalink | remove_first: "/" | remove_first: page.lang %}

{% for lang in site.languages %}
  {% assign localization = "/" | append: lang | append:baseurl %}
  {% assign locale = site.posts | where:"permalink", localization %}
  {% assign localizations = localizations | concat: locale %}
{% endfor %}