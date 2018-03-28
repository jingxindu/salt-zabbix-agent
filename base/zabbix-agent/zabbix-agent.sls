install-repo:
  cmd.run:
    - names:
      - rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm 
      - yum clean all
      - yum makecache

install-pkg:
  pkg.installed:
    - name: zabbix-agent
    - require:
      - cmd: install-repo

zabbix_agentd.conf:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://zabbix-agent/files/zabbix_agentd.conf.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defualts:
      ZABBIX_SERVER: 192.168.56.11 
      AGENT_HOSTNAME: {{ grains['fqdn'] }}
    - require:
      - pkg: install-pkg  

zabbix_agent_service:
  service.running:
    - name: zabbix-agent
    - enable: True
    - require:
      - pkg: install-pkg
      - file: zabbix_agentd.conf
    - watch:
      - file: zabbix_agentd.conf
      - pkg: zabbix-agent
