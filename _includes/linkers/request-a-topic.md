{% capture gh_base %}https://github.com/{{site.github_username}}/{{site.repository_name}}{% endcapture %}
{:.center}
[Request a topic]({{gh_base}}/issues/new?title={{'Topic request: ' | url_escape }}) \|
[Report an issue]({{gh_base}}/issues/new?body={{'Source file: ' | append: page.path | url_escape }})
