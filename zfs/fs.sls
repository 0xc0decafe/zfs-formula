{% set zfs = salt.pillar.get('zfs') %}
{% if zfs is defined %}
zfs_enabled:
  service.enabled:
    - name: zfs
{% endif %}

{% for zfs_dataset in zfs.get('fs', ()) %}
zfs_dataset_{{ loop.index0 }}:
  zfs.filesystem_present:
    - name: {{ zfs_dataset.dataset }}
    {%- if zfs_dataset.get('properties') %}
    - properties:
        {{ zfs_dataset.properties|yaml }}
    {%- endif %}
    {%- if loop.index0 > 0 %}
    - require:
      - zfs: zfs_dataset_{{ loop.index0 - 1 }}
    {%- endif %}
{% endfor %}

{% for zfs_volume in zfs.get('vol', ()) %}
zfs_volume_{{ loop.index0 }}:
  zfs.volume_present:
    - name: {{ zfs_volume.dataset }}
    - volume_size: {{ zfs_volume.size }}
    - sparse: {{ zfs_volume.get('sparse', True) }}
    {%- if zfs_volume.get('properties') %}
    - properties:
        {{ zfs_dataset.properties|yaml }}
    {%- endif %}
    #~ {%- if loop.index0 > 0 %}
    #~ - require:
      #~ - zfs: zfs_dataset_{{ loop.index0 - 1 }}
    #~ {%- endif %}
{% endfor %}
