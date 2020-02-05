---
title: The Bitcoin Optech Scaling Workbook
layout: page
---
The Bitcoin Optech scaling cookbook is a guide to effective practices
and techniques that engineers interacting with the Bitcoin block chain
can adopt today.  The following chapters are currently available:

{% for chapter in site.data.scaling.toc %}
  - [{{chapter.name}}]({{chapter.permalink}})
{% endfor %}

Additional chapters are being written.  When published, they will be
announced in the [newsletter][].

{% include references.md %}
[newsletter]: /{{page.lang | default: 'en'}}/newsletters/
