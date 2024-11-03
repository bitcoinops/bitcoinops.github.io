(<a title="Play this segment of the podcast" onClick="seek('{{include.timestamp}}')" class="seek">{{include.timestamp}}</a><noscript>{{include.timestamp}}</noscript>)
{% if include.reference %}<a href="{{include.reference}}{{include.slug}}">
    <i class="fa fa-link" title="Link to related content"></i>
</a>{% endif %}
{% if include.has_transcript_section %}
    <a href="{{include.slug}}-transcript">
        <i class="fa fa-file-text-o" title="Read this segment of the transcription"></i>
    </a>
{% endif %}
