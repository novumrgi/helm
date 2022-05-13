# Helm Chart for Glowroot

This is a kubernetes helm chart for Glowroot. It deploys a pod for glowroot-central and one for cassandra database. The glowroot admin section is fully configurable through the values. Ingress is supported as well.

# Content
<!-- vscode-markdown-toc -->
* 1. [Prerequisites](#Prerequisites)
* 2. [Installation](#Installation)
* 3. [Breaking Changes](#Breaking-Changes)
* 4. [Current Limitation](#CurrentLimitation)
* 5. [Configuration](#Configuration)
	* 5.1. [Image](#Image)
	* 5.2. [Service](#Service)
	* 5.3. [Glowroot Cassandra](#GlowrootCassandra)
	* 5.4. [Glowroot UI](#GlowrootUI)
	* 5.5. [Glowroot Admin](#GlowrootAdmin)
	* 5.6. [Cassandra](#Cassandra)
		* 5.6.1. [Ingress](#Ingress)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='Prerequisites'></a>Prerequisites

* Kubernetes cluster 1.10+ (should also work on older versions)
* Helm 2.8.0+

##  2. <a name='Installation'></a>Installation

```
  helm repo add novum-rgi-helm https://novumrgi.github.io/helm/
  helm install glowroot novum-rgi-helm/glowroot
```

## 3. <a name='Breaking-Changes'></a>Breaking Changes

In 1.0.8 the ingress was changed to support higher api version.

You now have to provide a dictionary defining host, path and pathType

```yaml
ingress:
  enabled: false
  className: nginx
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: glowroot.local.com
      paths:
        - path: /
          pathType: Prefix
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local
```

##  4. <a name='CurrentLimitation'></a>Current Limitation

Since this image needs to configure the admin part via values this chart is based on a little patch for glowroot. Thats we this currently only works with novumrgi/glowroot-central image from [dockerhub](https://hub.docker.com/repository/docker/novumrgi/glowroot-central).


## Examples

### Role Creation
For users to be assigned to roles we need to create the roles. The role Administrator is always created.

To get more information on the permissions format simply start glowroot with anonymous and create the desired roles in glowroot itself, have a look at the admin.json after creating the roles and copy the desired permissions.

```
 glowroot:
  admin:
    roles:
      - name: "MyOwnAdmin"
        permissions:
          - admin
          - agent:*:config
          - agent:*:error
          - agent:*:incident
          - agent:*:jvm
          - agent:*:syntheticMonitor
          - agent:*:transaction
```

### User Creation

```
  glowroot:
    admin:
      users:
        - name: MyAdminUser
          password: admin123
          roles:
            - MyOwnAdmin
```

##  5. <a name='Configuration'></a>Configuration

###  5.1. <a name='Image'></a>Image

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|image.repository|Set the repo from where to get the glowroot image.|novumrgi/glowroot-central|
|image.tag|Image Tag to download|0.13.7|
|image.pullPolicy|Image pull policy|Always|

###  5.2. <a name='Service'></a>Service

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|service.type|Kubernetes service type|ClusterIP|
|service.port|Service port for Glowroot|4000|
|service.agentPort|Service port for Glowroot-Agent|8181|

###  5.3. <a name='GlowrootCassandra'></a>Glowroot Cassandra

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|glowroot.cassandra.symmetricEncryptionKey|Database encryption Key, this should be changed when using the chart for security reasons|f8b62a6a4bd37abcc95e2f15d69c7b91|

###  5.4. <a name='GlowrootUI'></a>Glowroot UI

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|glowroot.ui.contextPath|Set ui context path used for reverse Proxy settings||

###  5.5. <a name='GlowrootAdmin'></a>Glowroot Admin

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|glowroot.admin.anonymousUser|Allow anonymous access to glowroot|true|
|glowroot.admin.general.displayName|Set name for glowroot, this will be displayed on alert mails||
|glowroot.admin.users|List of username, password and roles assigned to the user. Example in values.yaml|[]|
|glowroot.admin.roles|List of roles to be created, consist of role name and a list of permissions|[]|
|glowroot.admin.web.sessionTimeoutMin|Session timeout|30|
|glowroot.admin.web.sesssionCookieName|Cookie name for the session|GLOWROOT_SESSION_ID|
|glowroot.admin.storage.responseTimeJvmGaugeHours.oneMinAggregates|The data that is displayed under the transaction response time tab and on the JVM gauge screen is collected continuously by the agents and sent to the central collector (and stored) at 1 minute intervals. This setting defines how long to retain these 1 minute aggregates. (this setting also applies to the 5 second gauge data)|48|
|glowroot.admin.storage.responseTimeJvmGaugeHours.fiveMinAggregates|Response time and JVM gauge data is rolled up at 5 minute intervals. This setting defines how long to retain these 5 minute aggregates. |336|
|glowroot.admin.storage.responseTimeJvmGaugeHours.thirtyMinAggregates|Response time and JVM gauge data is rolled up again at 30 minute intervals. This setting defines how long to retain these 30 minute aggregates. |720|
|glowroot.admin.storage.responseTimeJvmGaugeHours.fourHourAggregates|Response time and JVM gauge data is rolled up again at 4 hour intervals. This setting defines how long to retain these 4 hour aggregates. |720|
|glowroot.admin.storage.queryServiceCallDataHours.oneMinAggregates|The data that is displayed under the transaction queries and service calls tabs is collected continuously by the agents and sent to the central collector (and stored) at 1 minute intervals. This setting defines how long to retain these 1 minute aggregates. |48|
|glowroot.admin.storage.queryServiceCallDataHours.fiveMinAggregates|Query and service call data is rolled up at 5 minute intervals. This setting defines how long to retain these 5 minute aggregates. |168|
|glowroot.admin.storage.queryServiceCallDataHours.thirtyMinAggregates|Query and service call data is rolled up again at 30 minute intervals. This setting defines how long to retain these 30 minute aggregates. |720|
|glowroot.admin.storage.queryServiceCallDataHours.fourHourAggregates|Query and service call data is rolled up again at 4 hour intervals. This setting defines how long to retain these 4 hour aggregates. |720|
|glowroot.admin.storage.profileDataHours.oneMinAggregates|The data that is displayed under the transaction continuous profiling tab is collected continuously by the agents and sent to the central collector (and stored) at 1 minute intervals. This setting defines how long to retain these 1 minute aggregates. |48|
|glowroot.admin.storage.profileDataHours.fiveMinAggregates|Profile data is rolled up at 5 minute intervals. This setting defines how long to retain these 5 minute aggregates. |168|
|glowroot.admin.storage.profileDataHours.thirtyMinAggregates|Profile data is rolled up again at 30 minute intervals. This setting defines how long to retain these 30 minute aggregates. |720|
|glowroot.admin.storage.profileDataHours.fourHourAggregates|Profile data is rolled up again at 4 hour intervals. This setting defines how long to retain these 4 hour aggregates. |720|
|glowroot.admin.storage.traceDataHours|This setting defines how long to retain trace data. This includes individual traces and error message data. |336|
|glowroot.admin.ldap.enabled|Enable or disable ldap|false|
|glowroot.admin.ldap.connection.host|LDAP server hostname or IP address. ||
|glowroot.admin.ldap.connection.port|Port to connect for ldap. Defaults to port 389 for non-SSL, and 636 for SSL. ||
|glowroot.admin.ldap.connection.ssl|Use SSL| false|
|glowroot.admin.ldap.connection.follow|Traverse ldap tree, might slow down your ldap connection| true|
|glowroot.admin.ldap.connection.bindDN|Username that Glowroot uses to bind and run LDAP queries. ||
|glowroot.admin.ldap.connection.bindPw|Password that Glowroot uses to bind and run LDAP queries. ||
|glowroot.ldap.structure.userBaseDN|Base DN for locating users, e.g. ou=Users,dc=example,dc=com||
|glowroot.ldap.structure.userSearchFilter|
This search filter is used to find the user based on the username they enter during login. The placeholder {0} in the filter will be populated with the username. For active directory this filter is likely sAMAccountName={0}
||
|glowroot.ldap.structure.groupBaseDN|Base DN for locating groups, e.g. ou=Groups,dc=example,dc=com||
|glowroot.ldap.structure.groupSearchFilter|This search filter is used to find the groups that a user is a member of. The placeholder {0} in the filter will be populated with the user DN. For active directory this filter is likely member={0}||
|glowroot.ldap.mapping|List of ldapGroupDN to glworootRoles mappings||
|glowroot.admin.smtp.enabled|Enable or disable mailer|false|
|glowroot.admin.smtp.host|SMTP server hostname or IP address. ||
|glowroot.admin.smtp.port|Port to connecto to smtp server ||
|glowroot.admin.smtp.connectionSecurity|Security settings for mailer connection [ssl-tls,starttls]
|glowroot.admin.smtp.username|Username to connect to mailserver||
|glowroot.admin.smtp.password|Password for username to connect to mailserver||
|glowroot.admin.smtp.fromEmailAddress|Mail address for alert mails||
|glowroot.admin.smtp.fromDisplayName|Display name for alert mails||

###  5.6. <a name='Cassandra'></a>Cassandra

Cassandra database is loaded as a dependency from [bitnami](https://github.com/bitnami/charts)
The complete cassandra configuration can be found here: https://github.com/bitnami/charts/tree/master/bitnami/cassandra

The following parameters are set by this charts by default

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|cassandra.dbUser.user|User to be created for cassandra database|cassandra|
|cassandra.dbUser.password|Password to be created for cassandra database|password|
|cassandra.keyspace|Set keyspace for cassandra database||

####  5.6.1. <a name='Ingress'></a>Ingress

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|ingress.enabled| enable ingress | false|
|ingress.annotations| add ingress annotations | |
|ingress.hosts| add hosts for ingress as string list | glowroot.example.com |
|ingress.tls|add ingress tls settings|[]|