{%- if mention.date == nil -%}
  {% if mention.url contains "/en/newsletters" %}
    {%- assign date = mention.url | remove_first: "/en/newsletters/" | slice: 0, 10 | replace: "/", "-" -%}
  {%- else -%}
    {%- include ERROR_44_MISSING_DATE -%}
  {%- endif -%}
{%- else -%}
  {%- assign date = mention.date -%}
{%- endif -%}
