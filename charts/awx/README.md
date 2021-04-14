# AWX Helm chart

[AWX](https://github.com/ansible/awx) provides a web-based user interface, REST API, and task engine built on top of Ansible. It is the upstream project for Tower, a commercial derivative of AWX.

This chart supports AWX version 12.0.0 and above and currently defaults to 14.0.0

The chart is based on the original AWX ansible repository: https://github.com/ansible/awx

## Installation

```
  helm repo add novum-rgi-helm https://novumrgi.github.io/helm/
  helm install gitea novum-rgi-helm/awx
```

## Dependencies

AWX can be run with external database. This chart provides a database (postgresql from bitnami) as dependency, which can be enabled via configuration

## Prerequisites

* Kubernetes 1.12+
* Helm 3.0+

## Examples

### LDAP

To configure LDAP for AWX a list of ldap configurations is required.
AWX supports up to 6 LDAP configurations. The passed list with LDAP configurations
goes from 0: default to 6. (LDAP Optional 1-5)

Complete documentation can be found in the AWX API <your_url>/api/v2/settings/ldap/

```yaml
awx:
  ldap:
  - enabled: true
    subTree: false
    tls: false
    host: ldap://ldap.example.com:389
    bindDn: CN=ldap read,OU=Spezial,DC=example,DC=com
    bindPassword: awxPassword123
    userSearch: 
      - "OU=Users,DC=northamerica,DC=acme,DC=com"
      - "SCOPE_SUBTREE"
      - "(sAMAccountName=%(user)s)"
    groupSearch: 
      - "dc=example,dc=com"
      - "SCOPE_SUBTREE"
      - "(objectClass=group)"
    userDnTemplate: uid=%(user)s,OU=Users,DC=example,DC=com
    denyGroup: CN=Disabled Users,OU=Users,DC=example,DC=com
    requireGroup: CN=Tower Users,OU=Users,DC=example,DC=com
    userAttributeMap: |
      {
        "first_name": "givenName",
        "last_name": "sn",
        "email": "mail"
      }
    groupTypeParams: |
      {
        "name_attr": "cn",
        "member_attr": "member"
      }
    flagsByGroup: |
      {
        "is_superuser": ["n=superusers,ou=groups,dc=website,dc=com"],
        "is_system_auditor": ["cn=auditors,ou=groups,dc=website,dc=com"]
      }
    orgMap: |
      {
        "LDAP Organization": {
          "admins": "cn=engineering_admins,ou=groups,dc=example,dc=com",
          "remove_admins": False,
          "users": [
            "cn=engineering,ou=groups,dc=example,dc=com",
            "cn=sales,ou=groups,dc=example,dc=com",
            "cn=it,ou=groups,dc=example,dc=com"
          ],
          "remove_users": False
        }
      }
    teamMap: |
      {
        "LDAP Engineering": {
          "organization": "LDAP Organization",
          "users": "cn=engineering,ou=groups,dc=example,dc=com",
          "remove": True
        }
      }
```

## Configuration 

### Image

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|image.repository|Set the repo from where to get the awx image.|ansible/awx|
|image.tag|Image Tag to download|14.0.0|
|image.pullPolicy|Image pull policy|Always|

### Ingress

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|ingress.enabled| enable ingress | false|
|ingress.annotations| add ingress annotations | |
|ingress.hosts| add hosts for ingress as string list | git.example.com |
|ingress.tls|add ingress tls settings|[]|

### Service

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|service.type| Kubernetes service type | ClusterIP |
|service.port| Port for web traffic | 8052 |
|service.annotations| Additional ssh annotations for the ssh service ||

### Resources

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|resources.web.limits.cpu|cpu limit for web container||
|resources.web.limits.memory|memory limit for web container||
|resources.web.requests.cpu|cpu request for web container||
|resources.web.requests.memory|memory request for web container||
|resources.task.limits.cpu|cpu limit for task container||
|resources.task.limits.memory|memory limit for task container||
|resources.task.requests.cpu|cpu request for task container|1500m|
|resources.task.requests.memory|memory request for task container, only use Mi here since it is parsed in the task configmap|2048Mi|
|resources.redis.limits.cpu|cpu limit for redis container||
|resources.redis.limits.memory|memory limit for redis container||
|resources.redis.requests.cpu|cpu request for redis container||
|resources.redis.requests.memory|memory request for redis container||

### AWX
| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|awx.adminUser|Username for awx admin account|admin|
|awx.adminPassword|Userpassword for awx admin account|awxPassword123|
|awx.adminMail|Mail address for awx admin account|admin@awx.com|
|awx.secretKey|Secret key for AWX, change this to be secure|qQoYusTYgMLThyQH|
|awx.ldap|list of ldap settings, described in |[]|
|awx.metrics.enabled| enable metrics | false|
|awx.metrics.annotations| annotations for prometheus metrics|prometheus.io/scrape: "true"<br>prometheus.io/port: "9090"|
|awx.metrics.serviceMonitor.enabled|Enable serviceMonitor for Prometheus operator|false|
|awx.metrics.serviceMonitor.scrapeTimeout|Scrape timeout for serviceMonitor|30s|
|awx.metrics.serviceMonitor.interval|interval time for serviceMonitor|30s|
|awx.metrics.serviceMonitor.relabellings|Relabellings for serviceMonitor||
|awx.metrics.serviceMonitor.honorLabels|Enabled or disable Honor Labels for service Monitor|false|
|awx.metrics.serviceMonitor.additionalLabels|Add additional labels to serviceMonitor|{}|
|awx.redis.image|Select image to load for redis container|redis|
|awx.redis.tag|Select redis image tag to load for redis container|latest|
|awx.database.builtIn.enabled|Use postgresql dependency database, no need to configure anymore|true|
|awx.database.username|Username for external database, only used if builtIn is false||
|awx.database.name|Database name for external database, only used if builtIn is false||
|awx.database.password|Password for external database, only used if builtIn is false||
|awx.database.host|Address for external database, only used if builtIn is false||
|awx.database.port|Port for external database, only used if builtIn is false||
|awx.insights.urlBase|TBD|https://awx.example.com|
|awx.insights.agentMime|TBD|application/example|
|awx.insights.automationAnalyticsUrl|TBD|https://awx.example.com|
|awx.containerGroupDefaultImage|TBD|ansible/ansible-runner|
|awx.candlePin.host|TBD||
|awx.candlePin.verify|TBD||

### Postgresql

Postgresql is loaded as a dependency from bitnami. Configuration can be found from this [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami/postgresql)

The following parameters are the defaults set by this chart

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|postgresql.global.postgresql.postgresqlDatabase| PostgreSQL database (overrides postgresqlDatabase)|awx|
|postgresql.global.postgresql.postgresqlUsername| PostgreSQL username (overrides postgresqlUsername)|awx|
|postgresql.global.postgresql.postgresqlPassword| PostgreSQL admin password (overrides postgresqlPassword)|awx|
|postgresql.global.postgresql.servicePort|PostgreSQL port (overrides service.port)|5432|
|postgresql.persistence.size| PVC Storage Request for PostgreSQL volume |20Gi|