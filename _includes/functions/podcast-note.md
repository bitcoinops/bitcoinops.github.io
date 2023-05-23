(<a title="Play this segment of the podcast" onClick="seek('{{reference.timestamp}}')" class="seek">{{reference.timestamp}}</a><noscript>{{reference.timestamp}}</noscript>)
<a href="{{page.reference}}{{reference.slug}}">
    <i class="fa fa-link" title="Link to related content"></i>
</a>
{% if reference.has_transcript_section %}
    <a href="{{reference.slug}}-transcript">
        <i class="fa fa-file-text-o" title="Read this segment of the transcription"></i>
    </a>
{% endif %}
