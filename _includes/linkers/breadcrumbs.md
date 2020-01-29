{% capture _breadcrumb %}
{%- assign _paths = include.path | split: '/' -%}
{%- assign _paths_size = _paths | size -%}
{%- if page.breadcrumbs == true and _paths_size > 3 -%}
  {:.center}
  /&nbsp;[{{site.data.localization[page.lang].home | default: "home"}}](/)&nbsp;/&nbsp;
  {%- for _path in _paths -%}
    {%- assign _full_path = _full_path | append: _path | append: "/" -%}
    {%- comment -%}<!-- skip first two iterations, which are (empty) and "<language_code>" -->{%- endcomment -%}
    {%- if forloop.index > 2 %}
      {%- unless forloop.last -%}[{{site.data.localization[page.lang][_path] | default: _path}}]({{_full_path}})&nbsp;/&nbsp;{%- endunless -%}
    {%- endif -%}
  {%- endfor -%}
{%- endif -%}
{% endcapture %}{{_breadcrumb | markdownify}}
