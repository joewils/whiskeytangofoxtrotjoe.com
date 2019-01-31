---
layout: page
title: Eye Candy
---

## Sourced from Pexels.com
{% for source in site.data.pexels %}
  {% if source['local_href'] and source['image_got'] == true %}
  <h2> ({{forloop.index}}) <a href="/candy/{{ source['slug'] }}">{{ source['local_href'] }}</a></h2>
  <img src="/{{source['local_href']}}" />
  {% endif %}
{% endfor %}

## Sourced from Burst.com (no longer used)
{% for source in site.data.stock %}
  {% if source['slug'] %}
  <h2> ({{forloop.index}}) <a href="/candy/{{ source['slug'] }}">/images/stock/{{ source['slug'] }}.jpg</a></h2>
  <img src="/images/stock/{{ source['slug'] }}.jpg" />
  {% endif %}
{% endfor %}