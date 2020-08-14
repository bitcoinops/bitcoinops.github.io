{% if mention.url contains "/en/newsletters" %}
  {%- assign date = mention.url | remove_first: "/en/newsletters/" | slice: 0, 10 | replace: "/", "-" -%}
{%- else -%}
  {%- if mention.date == nil -%}
    {%- include ERROR_44_MISSING_DATE -%}
  {%- else -%}
    {%- assign date = mention.date -%}
  {%- endif -%}
{%- endif -%}
