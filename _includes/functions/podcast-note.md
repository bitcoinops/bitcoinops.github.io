{% auto_anchor %}
- **{{include.title}}** (<a title="Play this segment of the podcast" onClick="seek('{{include.timestamp}}')"
class="seek">{{include.timestamp}}</a><noscript>{{include.timestamp}}</noscript>) {% if include.url != "" %}[<i class="fa fa-link"
title="Link to related content"></i>][{{include.url}}]{% endif %}
  <!--<a onClick="seek('{{include.timestamp}}')" class="seek"><i class="fa
  fa-headphones" title="Play this segment of the podcast"></i></a>-->
  {% if include.anchor != "" %}[<i class="fa fa-file-text-o" title="Read this segment of the transcription"></i>](#{{include.anchor}}){% endif %}
{% endauto_anchor %}
