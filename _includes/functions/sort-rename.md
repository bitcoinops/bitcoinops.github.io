{% capture /dev/null %}
<!-- rename things for sorting purposes -->
{% assign _result = include.name %}
{% if include.name contains "BIP" %}
  {% assign _strlen = include.name | split: ' ' | first | size %}
  {% case _strlen %}
    {% when 4 %}{% assign _result = include.name | replace: "BIP", "BIP000" %}
    {% when 5 %}{% assign _result = include.name | replace: "BIP", "BIP00" %}
    {% when 6 %}{% assign _result = include.name | replace: "BIP", "BIP0" %}
    {% else %}{% include ERROR675_BIP_STRING_DOESNT_MATCH_EXPECTED_PATTERN %}
  {% endcase %}
{% endif %}
{% endcapture %}{{_result}}
