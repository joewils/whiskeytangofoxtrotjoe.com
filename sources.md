---
layout: page
title: Sources
permalink: /sources/
---

<ol>
{% for source in site.data.sources %}
  {% if source['feed'] %}
    <li><a href="{{ source.url }}" target="_new">{{ source.title }}</a></li>
  {% endif %}
{% endfor %}
</ol>


<ol>
{% for source in site.data.sources %}
  {% if source['feed'] == nil %}
    <li><a href="{{ source.url }}" target="_new">{{ source.title }}</a></li>
  {% endif %}
{% endfor %}
</ol>