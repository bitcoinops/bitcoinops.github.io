{% capture raw_items %}
{%- for item in include.collection -%}
  <!--{% include functions/sort-rename.md name=item.title %}-->[{{item.title}}]({{item.url}})ENDITEM
  {%- for alias in item.aliases -%}
    <!--{% include functions/sort-rename.md name=alias %}-->*[{{alias}}]({{item.url}})*ENDITEM
  {%- endfor -%}
{%- endfor -%}
{% endcapture %}
{% assign items = raw_items | split: 'ENDITEM' | sort_natural %}

<div>{% comment %}<!-- enclosing in a div forces this to be interpreted
as HTML rather than Markdown so indentation over 4 characters doesn't
produce code blocks -->{% endcomment %}

{% assign previous_character = '' %}
{% for entry in items %}
  {% assign first_character = entry | remove_first: '<!--' | truncate: 1, '' | downcase %}{%- comment -%}close html comment for syntax hilite -->{%- endcomment %}
  {% if first_character != previous_character %}
    {% if previous_character != '' %}</ul>{% endif %}
    <h3 id="{{first_character}}">{{first_character | upcase}}</h3>
    <ul>
  {% endif %}
  <li>{{entry | markdownify | remove: "<p>" | remove: "</p>" | strip }}</li>
  {% assign previous_character = first_character %}
{% endfor %}
</ul>

</div>
