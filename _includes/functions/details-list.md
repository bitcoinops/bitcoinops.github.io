{% capture /dev/null %}
  <!-- Maximum number of params:
     1 include.class (CSS class)
    10 include.q0..q9 (questions)
    10 include.a0..a9 (answers)
    -- -------------------
    21 Total -->
  {% assign includes_size = include | size %}
  {% if includes_size >= 21 %}{% include ERROR143_too_many_params_passed_to_details_list %}{% endif %}
{% endcapture %}
<div class="{{include.class | default: 'qa_details'}} {{jekyll.environment}}" markdown="1">
{% for i in (0..9) %}
  {% capture q %}q{{i}}{% endcapture %}
  {% capture a %}a{{i}}{% endcapture %}
  {% capture al %}a{{i}}link{% endcapture %}
  {% capture alink %}{% if include.[al] != nil %}<a href="{{ include.[al] }}" class="external">➚</a>{% endif %}{% endcapture %}
  {% if include.[q] == nil %}{% break %}{% endif %}
  {% assign qslug = include.[q] | slugify: 'latin' %}
  {% if jekyll.environment == "email" %}
   - <i markdown="1">{{include.[q]}}</i><br>{{include.[a]}}&nbsp;{{alink}}
  {% else %}
   - <details id="{{qslug}}" markdown="1"><summary><span markdown="1">{{include.[q]}}</span></summary>
     {{include.[a]}}&nbsp;{{alink}}
     </details>
  {% endif %}
{% endfor %}
</div>
