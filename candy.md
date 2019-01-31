---
layout: page
title: Candy
---

## Burst
{% for source in site.data.stock %}
  {% if source['slug'] %}
  <h2> ({{forloop.index}}) <a href="/candy/{{ source['slug'] }}">/images/stock/{{ source['slug'] }}.jpg</a></h2>
  <img src="/images/stock/{{ source['slug'] }}.jpg" />
  {% endif %}
{% endfor %}

- alt: Woman in Red Shirt Sitting on Fitness Equipment
  href: https://images.pexels.com/photos/1103242/pexels-photo-1103242.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260
  pexel_id: '1103242'
  source: https://www.pexels.com/photo/woman-in-red-shirt-sitting-on-fitness-equipment-1103242/
  slug: woman-in-red-shirt-sitting-on-fitness-equipment-1103242
  local_href: images/stock/woman-in-red-shirt-sitting-on-fitness-equipment-1103242.jpg
  image_got: true

## Pexels
{% for source in site.data.pexels %}
  {% if source['local_href'] and source['image_got'] == true %}
  <h2> ({{forloop.index}}) <a href="/candy/{{ source['slug'] }}">{{ source['local_href'] }}</a></h2>
  <img src="/{{source['local_href']}}" />
  {% endif %}
{% endfor %}