{{page.review-club.summary}}

<div class="{{include.class | default: 'qa_details'}} {{jekyll.environment}}" markdown="1">
{% for qa in page.review-club.qa %}
  {% capture alink %}{% if qa.link != nil %}<a href="{{ qa.link }}" class="external">➚</a>{% endif %}{% endcapture %}
  {% if jekyll.environment == "email" %}
   - <i markdown="1">{{qa.question}}</i><br>{{qa.answer}}&nbsp;{{alink}}
  {% else %}
   - <details id="{{qslug}}" markdown="1"><summary><span markdown="1">{{qa.question}}</span></summary>
     {{qa.answer}}&nbsp;{{alink}}
     </details>
  {% endif %}
{% endfor %}
</div>
