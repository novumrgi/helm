# Gitea Helm Chart

[Gitea](https://gitea.io/en-us/) is a community managed lightweight code hosting solution written in Go. It is published under the MIT license.

Readme will be updated with examples in the next few days

# Content
<!-- vscode-markdown-toc -->
* 1. [Introduction](#Introduction)
	* 1.1. [Dependencies](#Dependencies)
* 2. [Installing](#Installing)
* 3. [Prerequisites](#Prerequisites)
* 4. [Examples](#Examples)
	* 4.1. [Ports and external url](#Portsandexternalurl)
	* 4.2. [Persistence](#Persistence)
	* 4.3. [Admin User](#AdminUser)
	* 4.4. [Ldap Settings](#LdapSettings)
* 5. [Configuration](#Configuration)
	* 5.1. [Image](#Image)
	* 5.2. [Persistence](#Persistence-1)
	* 5.3. [Ingress](#Ingress)
	* 5.4. [Service](#Service)
	* 5.5. [Gitea Configuration](#GiteaConfiguration)
	* 5.6. [Gitea repository](#Gitearepository)
	* 5.7. [Gitea Ldap](#GiteaLdap)
	* 5.8. [Gitea Server](#GiteaServer)
	* 5.9. [Gitea Repository](#GiteaRepository)
	* 5.10. [Gitea UI](#GiteaUI)
	* 5.11. [Gitea Database](#GiteaDatabase)
	* 5.12. [Gitea Admin](#GiteaAdmin)
	* 5.13. [Gitea Security](#GiteaSecurity)
	* 5.14. [Gitea OpenID](#GiteaOpenID)
	* 5.15. [Gitea Service](#GiteaService)
	* 5.16. [Gitea Webhook](#GiteaWebhook)
	* 5.17. [Gitea Mailer](#GiteaMailer)
	* 5.18. [Gitea Cache](#GiteaCache)
	* 5.19. [Gitea Attachment](#GiteaAttachment)
	* 5.20. [Gitea Log](#GiteaLog)
	* 5.21. [Gitea Git](#GiteaGit)
	* 5.22. [Gitea Extra Config](#GiteaExtraConfig)
	* 5.23. [Memcached BuiltIn](#MemcachedBuiltIn)
	* 5.24. [Mysql BuiltIn](#MysqlBuiltIn)
	* 5.25. [Postgresql BuiltIn](#PostgresqlBuiltIn)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='Introduction'></a>Introduction

This helm chart has taken some inspiration from https://github.com/jfelten/gitea-helm-chart
But takes a completly different approach in providing database and cache with dependencies.
Also this chart provides ldap and admin user configuration with values as well as it is deployed as statefulset to retain stored repositories.

###  1.1. <a name='Dependencies'></a>Dependencies

Gitea can be run with external database and cache. This chart provides those dependencies, which can be
enabled, or disabled via [configuration](#3-configuration).

Dependencies:

* Postgresql
* Memcached
* Mysql

##  2. <a name='Installing'></a>Installing

```
  helm repo add novum-rgi-helm https://novumrgi.github.io/helm/
  helm install gitea novum-rgi-helm/gitea
```

##  3. <a name='Prerequisites'></a>Prerequisites

* Kubernetes 1.12+
* Helm 3.0+
* PV provisioner for persistent data support

##  4. <a name='Examples'></a>Examples

###  4.1. <a name='Portsandexternalurl'></a>Ports and external url

By default port 3000 is used for web traffic and 22 for ssh. Those can be changed:

```yaml
  service:
    http: 
      port: 3000
    ssh:
      port: 22
```

For git to display the clone urls correctly the externalDomain setting has to be used. However the externalDomain does not change where gitea is published (Use ingress for this). ExternalDomain is just for displaying the correct clone URL. Same for externalPorts. Those are only used for display the correct clone URL.

```yaml
  gitea:
    server:
      http:
        externalDomain: gitea.example.com
        externalPort: 3000
      ssh:
        externalDomain: gitea.example.com
        externalPort: 22
```

###  4.2. <a name='Persistence'></a>Persistence

Gitea will be deployed as a statefulset. By simply enabling the persistence and setting the storage class according to your cluster
everything else will be taken care of. The following example will create a PVC as a part of the statefulset. This PVC will not be deleted
even if you uninstall the chart.
When using Postgresql as dependency, this will also be deployed as a statefulset by default. 

If you want to manage your own PVC you can simply pass the PVC name to the chart. 

```yaml
  persistence:
    enabled: true
    existingClaim: MyAwesomeGiteaClaim
```

In case that peristence has been disabled it will simply use an empty dir volume.

Postgresql handles the persistence in the exact same way. 
You can interact with the postgres settings as displayed in the following example:

```yaml
  postgresql:
    persistence:
      enabled: true
      existingClaim: MyAwesomeGiteaPostgresClaim
```

Mysql also handles persistence the same, even though it is not deployed as a statefulset.
You can interact with the postgres settings as displayed in the following example:

```yaml
  mysql:
    persistence:
      enabled: true
      existingClaim: MyAwesomeGiteaMysqlClaim
```

###  4.3. <a name='AdminUser'></a>Admin User

This chart enables you to create a default admin user. It is also possible to update the password for this user by upgrading or redeloying the chart.
It is not possible to delete an admin user after it has been created. This has to be done in the ui.

```yaml
  gitea:
    config:
      adminUser: "MyAwesomeGiteaAdmin"
      adminPassword: "AReallyAwesomeGiteaPassword"
      adminEmail: "gi@tea.com"
```

###  4.4. <a name='LdapSettings'></a>Ldap Settings

Like the admin user the ldap settings can be updated but also disabled or deleted.

```yaml
  gitea:
    ldap:
      enabled: true
      name: 'MyAwesomeGiteaLdap'
      securityProtocol: unencrypted
      host: "127.0.0.1"
      port: "389"
      userSearchBase: ou=Users,dc=example,dc=com
      userFilter: sAMAccountName=%s
      adminFilter: CN=Admin,CN=Group,DC=example,DC=com
      emailAttribute: mail
      bindDn: CN=ldap read,OU=Spezial,DC=example,DC=com
      bindPassword: JustAnotherBindPw
      usernameAttribute: CN
```

##  5. <a name='Configuration'></a>Configuration

###  5.1. <a name='Image'></a>Image

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|image.repository| Image to start for this pod | gitea/gitea |
|image.version| Image Version | 1.12.2 |
|image.pullPolicy| Image pull policy | Always |

###  5.2. <a name='Persistence-1'></a>Persistence

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|persistence.enabled| Enable persistence for Gitea |true|
|persistence.existingClaim| Use an existing claim to store repository information | |
|persistence.size| Size for persistence to store repo information | 10Gi |
|persistence.accessModes|AccessMode for persistence||
|persistence.storageClass|Storage class for repository persistence|standard|

###  5.3. <a name='Ingress'></a>Ingress

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|ingress.enabled| enable ingress | false|
|ingress.annotations| add ingress annotations | |
|ingress.hosts| add hosts for ingress as string list | git.example.com |
|ingress.tls|add ingress tls settings|[]|

###  5.4. <a name='Service'></a>Service

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|service.http.type| Kubernetes service type for web traffic | ClusterIP |
|service.http.port| Port for web traffic | 3000 |
|service.ssh.type| Kubernetes service type for ssh traffic | ClusterIP |
|service.ssh.port| Port for ssh traffic | 22 |
|service.ssh.annotations| Additional ssh annotations for the ssh service ||

###  5.5. <a name='GiteaConfiguration'></a>Gitea Configuration

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.config.appName | App name that shows in every Page | Gitea: Git with a cup of tea |
|gitea.config.runMode | Run Mode for Gitea, either dev, prod or test | dev               |
|gitea.config.runUser | User for gitea container to run   | git                          |
|gitea.config.adminUser | Admin user to login in gitea   | gitea_admin |
|gitea.config.adminPassword | Password for admin user   | gitea123456                         |
|gitea.config.adminEmail | Email for admin user   | example@gitea.com                   |

###  5.6. <a name='Gitearepository'></a>Gitea repository

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.repository.root| Root path for storing all repository data. It must be an absolute path. | nil |
|gitea.repository.forcePrivate | Force every new repository to be private. | false       |
|gitea.repository.defaultPrivate| Default private when creating a new repository. [last, private, public] | false |
|gitea.repository.maxCreationLimit| Global maximum creation limit of repositories per user, -1 means no limit.| -1 |
|gitea.repository.mirrorQueueLength| Patch test queue length, increase if pull request patch testing starts hanging. | 1000 |
|gitea.repository.pullRequestQueueLength| Length of pull request patch test queue, make it as large as possible. Use caution when editing this value. | 1000|
|preferredLicenses| Preferred Licenses to place at the top of the list. Name must match file name in conf/license or custom/conf/license in container.| Apache License 2.0,MIT License |
|gitea.repository.disableHttpGit|Disable the ability to interact with repositories over the HTTP protocol.| false|
|gitea.repository.useCompatSSHUri|Force ssh:// clone url instead of scp-style uri when default SSH port is used.|false|

###  5.7. <a name='GiteaLdap'></a>Gitea Ldap

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.ldap.enabled| enable ldap config | false|
|gitea.ldap.name| unique name to store ldap config| ""|
|gitea.ldap.securityProtocol| ldap security protocol | "" |
|gitea.ldap.host | Ip or url to connect to ldap | "" |
|gitea.ldap.port | Port to connecto to ldap server | "" |
|gitea.ldap.userSearchBase| The LDAP base at which user accounts will be searched for. | "" |
|gitea.ldap.userFilter| An LDAP filter declaring how to find the user record that is attempting to authenticate. The %s matching parameter will be substituted with login name given on sign-in form. | "" |
|gitea.ldap.adminFilter | An LDAP filter specifying if a user should be given administrator privileges. If a user account passes the filter, the user will be privileged as an administrator. | "" |
|gitea.ldap.emailAttribute | The attribute of the user’s LDAP record containing the user’s email address. This will be used to populate their account information. | "" |
|gitea.ldap.bindDn | The DN to bind to the LDAP server with when searching for the user. This may be left blank to perform an anonymous search. | "" |
|gitea.ldap.bindPassword | The password for the Bind DN specified above, if any. Note: The password is stored in plaintext at the server. As such, ensure that the Bind DN has as few privileges as possible. | "" |
|gitea.ldap.usernameAttribute | The attribute of the user’s LDAP record containing the user name. Given attribute value will be used for new Gitea account user name after first successful sign-in. Leave empty to use login name given on sign-in form. | "" |

###  5.8. <a name='GiteaServer'></a>Gitea Server

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.server.http.externalDomain | Http clone setting for which address gitea will be available on clone | git.example.com|
|gitea.server.http.externalPort | Http clone setting for which port gitea will be available on clone | |
|gitea.server.ssh.externalDomain | SSH clone setting for which address gitea will be available on clone | git.example.com|
|gitea.server.ssh.externalPort | SSH clone setting for which port gitea will be available on clone | |
|gitea.server.offlineMode | Disables use of CDN for static files and Gravatar for profile pictures. | false|

###  5.9. <a name='GiteaRepository'></a>Gitea Repository

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.repository.root| Root path for storing all repository data. It must be an absolute path. | "" |
|gitea.repository.forcePrivate| Force every new repository to be private. | "" |
|gitea.repository.defaultPrivate| Default private when creating a new repository. [last, private, public] | last |
|gitea.repository.maxCreationLimit| Global maximum creation limit of repositories per user, -1 means no limit. | -1 |
|gitea.repository.mirrorQueueLength| Patch test queue length, increase if pull request patch testing starts hanging. | 1000 |
|gitea.repository.pullRequestQueueLength| Length of pull request patch test queue, make it as large as possible. Use caution when editing this value. | 1000 |
|gitea.repository.preferredLicenses| Apache License 2.0,MIT License: Preferred Licenses to place at the top of the list. Name must match file name in conf/license or custom/conf/license. | Apache License 2.0,MIT License |
|gitea.repository.disableHttpGit| Disable the ability to interact with repositories over the HTTP protocol. | false |
|gitea.repository.useCompatSSHUri| Force ssh:// clone url instead of scp-style uri when default SSH port is used. | false |
|gitea.repository.local.copyPath| Path for local repository copy. | tmp/local-repo |
|gitea.repository.local.wikiPath| Path for local wiki copy. | tmp/local-wiki |
|gitea.repository.upload.enabled| Whether repository file uploads are enabled. | true |
|gitea.repository.upload.tempPath| Path for uploads. | data/tmp/uploads |
|gitea.repository.upload.allowedTypes| One or more allowed types, e.g. image/jpeg|image/png. Nothing means any file type |  |
|gitea.repository.upload.fileMaxSize|Max size of each file in megabytes.| 3 |
|gitea.repository.upload.maxFiles| Max number of files per upload. | 5 |
|gitea.repository.pullRequest.workInProgressPrefixes|  List of prefixes used in Pull Request title to mark them as Work In Progress | WIP:,[WIP] |
|gitea.repository.pullRequest.closeKeywords| Max number of files per upload. | 5 |
|gitea.repository.pullRequest.reopenKeywords| Max number of files per upload. | 5 |
|gitea.repository.pullRequest.defaultMergeMessageCommitsLimit| Max number of files per upload. | 5 |
|gitea.repository.pullRequest.defaultMergeMessageSize| Max number of files per upload. | 5 |
|gitea.repository.pullRequest.defaultMergeMessageAllAuthors| Max number of files per upload. | 5 |
|gitea.repository.pullRequest.defaultMergeMessageMaxApprovers| Max number of files per upload. | 5 |
|gitea.repository.pullRequest.defaultMergeMessageOfficialApproversOnly| Max number of files per upload. | 5 |
|gitea.repository.signing.signingKey| Key to sign with. [none, KEYID, default ] | default |
|gitea.repository.signing.signingName|  if a KEYID is provided as the SIGNING_KEY, use these as the Name of the signer. These should match publicized name for the key. |  |
|gitea.repository.signing.signingEmail|  if a KEYID is provided as the SIGNING_KEY, use these as the Email address of the signer. These should match publicized email address for the key. |  |
|gitea.repository.signing.initialCommit|  [never, pubkey, twofa, always]: Sign initial commit. | always |
|gitea.repository.signing.crudActions| [never, pubkey, twofa, parentsigned, always]: Sign CRUD actions. | pubkey, twofa, parentsigned |
|gitea.repository.signing.wiki| [never, pubkey, twofa, always, parentsigned]: Sign commits to wiki. | never |
|gitea.repository.signing.merges|  [never, pubkey, twofa, approved, basesigned, commitssigned, always]: Sign merges.  | pubkey, twofa, basesigned, commitssigned |gitea.ui.explorePagingNum|Number of repositories that are shown in one explore page.|20|

###  5.10. <a name='GiteaUI'></a>Gitea UI

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.ui.issuePagingNum|Number of issues that are shown in one page (for all pages that list issues).|10|
|gitea.ui.membersPagingNum| Number of members that are shown in organization members.|20|
|gitea.ui.feedMaxCommitNum|Number of maximum commits shown in one activity feed.|5|
|gitea.ui.graphMaxCommitNum|Number of maximum commits shown in the commit graph.|100|
|gitea.ui.codeCommentLines| Number of line of codes shown for a code comment |4|
|gitea.ui.themeColorMetaTag|Value of `theme-color` meta tag, used by Android >= 5.0 An invalid color like "none" or "disable" will have the default style More info: https://developers.google.com/web/updates/201411Support-for-theme-color-in-Chrome-39-for-Android|#6cc644|
|gitea.ui.maxDisplayFileSize| Max size of files to be displayed in Bytes |8388608|
|gitea.ui.defaultTheme| [gitea, arc-green]: Set the default theme for the Gitea install.|gitea|
|gitea.ui.showUserMail|Whether the email of the user should be shown in the Explore Users page|true|
|gitea.ui.defaultShowFullName|Whether the full name of the users should be shown where possible. If the full name isn't set, the username will be used.|false|
|gitea.ui.searchRepoDescription|Whether to search within description at repository search on explore page.|true|
|gitea.ui.useServiceWorker|Whether to enable a Service Worker to cache frontend assets|true|

###  5.11. <a name='GiteaDatabase'></a>Gitea Database

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.database.builtIn.postgresql.enabled| Enable built in postgresql database, either postgres or mysql can be enabled. Not both!| true|
|gitea.database.builtIn.mysql.enabled| Enable built in mysql database, either postgres or mysql can be enabled. Not both!| false |
|gitea.database.external.type| database type if no built in is enabled | postgres |
|gitea.database.external.port| port to connect to database | 5432 |
|gitea.database.external.host| address to connect to database | |
|gitea.database.external.name| database name | gitea |
|gitea.database.external.user| database user | gitea |
|gitea.database.external.password| database password for defined user | gitea |
|gitea.database.external.schema| database schema to deploy db data | |
|gitea.database.sslMode|SSL/TLS encryption mode for connecting to the database. This option is only applied for PostgreSQL and MySQL|disable|
|gitea.database.charset|For MySQL only, either “utf8” or “utf8mb4”. NOTICE: for “utf8mb4” you must use MySQL InnoDB > 5.6. Gitea is unable to check this.|utf8mb4|
|gitea.database.path|For SQLite3 only, the database file path.|data/gitea.db|
|gitea.database.sqlLiteTimeout|For "sqlite3" only. Query timeout|500|
|gitea.database.iterateBufferSize|For iterate buffer|50|
|gitea.database.logSql|Show the database generated SQL|true|
|gitea.database.dbRetries|Maximum number of DB Connect retries|10|
|gitea.database.dbRetryBackoff|Backoff time per DB retry (time.Duration)|3s|
|gitea.database.maxIdleConns|Max idle database connections on connnection pool|2|
|gitea.database.connMaxLifetime|Database connection max life time|3s|
|gitea.database.maxOpenConns|Database maximum number of open connections|0|

###  5.12. <a name='GiteaAdmin'></a>Gitea Admin

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.admin.disableRegularOrgCreation|Disallow regular (non-admin) users from creating organizations.|false|
|gitea.admin.defaultEmailNotifications|Default configuration for email notifications for users (user configurable). Options: enabled, onmention, disabled|enabled|

###  5.13. <a name='GiteaSecurity'></a>Gitea Security

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.security.installLock|Disallow access to the install page.|true|
|gitea.security.secretKey|Global secret key. This should be changed.|!#@FDEWREWR&*(|
|gitea.security.loginRememberDays|Cookie lifetime, in days.|7|
|gitea.security.cookieUsername|Name of the cookie used to store the current username.|gitea_awesome|
|gitea.security.cookieRememberName|Name of cookie used to store authentication information.|gitea_incredible|
|gitea.security.reverseProxyAuthUser|Header name for reverse proxy authentication.|X-WEBAUTH-USER|
|gitea.security.reverseProxyAuthEmail|Header name for reverse proxy authentication provided email.|X-WEBAUTH-EMAIL|
|gitea.security.minPasswordLength|The minimum password length for new Users|6|
|gitea.security.importLocalPaths|Set to false to prevent all users (including admin) from importing local path on server.|false|
|gitea.security.disabledGitHooks|Set to true to prevent all users (including admin) from creating custom git hooks|false|
|gitea.security.onlyAllowPushIfGiteaEnvSet|Set to false to allow pushes to gitea repositories despite having an incomplete environment - NOT RECOMMENDED|true|
|gitea.security.passwordComplexity|Comma separated list of character classes required to pass minimum complexity. [lower,upper,digit,spec]|off|
|gitea.security.passwordHashAlgo|Password Hash algorithm, either "pbkdf2", "argon2", "scrypt" or "bcrypt"|pbkdf2|
|gitea.security.crsfCookieHttpOnly|Set false to allow JavaScript to read CSRF cookie|true|

###  5.14. <a name='GiteaOpenID'></a>Gitea OpenID

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.openid.enableOpenidSignin|Whether to allow signin in via OpenID|true|
|gitea.openid.enableOpenidSignup|Whether to allow registering via OpenID|true|
|gitea.openid.whitelistedUris|Allowed URI patterns (POSIX regexp). Space seperated||
|gitea.openid.blacklistedUris|Forbidden URI patterns (POSIX regexp). Space seperated||

###  5.15. <a name='GiteaService'></a>Gitea Service

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.service.activeCodeLiveMinutes|Time limit (min) to confirm account/email registration.|180|
|gitea.service.resetPasswordCodeLiveMinutes|Time limit (min) to confirm forgot password reset process.|180|
|gitea.service.registerEmailConfirm|Enable this to ask for mail confirmation of registration. Requires Mailer to be enabled.|false|
|gitea.service.emailDomainWhitelist|List of domain names that are allowed to be used to register on a Gitea instance||
|gitea.service.disableRegistration|Disallow registration, only allow admins to create accounts.|false|
|gitea.service.allowOnlyExternalRegistration|Allow registration only using third-party services, it works only when DISABLE_REGISTRATION is false|false|
|gitea.service.requireSigninView|User must sign in to view anything.|false|
|gitea.service.enableNotifyMail|Mail notification|false|
|gitea.service.enableBasicAuth|This setting enables gitea to be signed in with HTTP BASIC Authentication using the user's password|true|
|gitea.service.enableReverseProxyAuth|Enable this to allow reverse proxy authentication.|false|
|gitea.service.enableReverseProxyAutoRegistration| Enable this to allow auto-registration for reverse authentication.|false|
|gitea.service.enableReverseProxyEmail|Enable this to allow to auto-registration with a provided email rather than a generated email.|false|
|gitea.service.enableCaptcha|Enable this to use captcha validation for registration.|false|
|gitea.service.captchaType|[image, recaptcha]|image|
|gitea.service.recaptchaSecret|Go to https://www.google.com/recaptcha/admin to get a secret for recaptcha.||
|gitea.service.recaptchaSiteKey|Go to https://www.google.com/recaptcha/admin to get a sitekey for recaptcha.||
|gitea.service.racaptchaUrl|Set the recaptcha url - allows the use of recaptcha net.|https://www.google.com/recaptcha/|
|gitea.service.defaultKeepEmailPrivate|Default value for KeepEmailPrivate|false|
|gitea.service.deaultAllowCreateOrg|Default value for AllowCreateOrganization|true|
|gitea.service.defaultOrgVisibility|Either "public", "limited" or "private", limited is for signed user only|public|
|gitea.service.defaultOrgMemberVisible|Default value for DefaultOrgMemberVisible|false|
|gitea.service.defaultEnableDependencies|Default value for EnableDependencies|true|
|gitea.service.allowCrossRepositoryDependencies|Dependencies can be added from any repository where the user is granted access or only from the current repository depending on this setting.|true|
|gitea.service.enableUserHeatmap|Enable heatmap on users profiles.|true|
|gitea.service.enableTimeTracking|Enable Timetracking|true|
|gitea.service.defaultEnableTimeTracking|Default value for EnableTimetracking|true|
|gitea.service.defaultAllowOnlyContributorsToTrackTime|Default value for AllowOnlyContributorsToTrackTime|true|
|gitea.service.noReplyAddress|Default value for the domain part of the user's email address in the git log|noreply.example.org|
|gitea.service.showRegistrationButton|Show Registration button|true|
|gitea.service.showMilestonesDashboardPage|Show milestones dashboard page - a view of all the user's milestones|true|
|gitea.service.autoWatchNewRepos|Default value for AutoWatchNewRepos|true|
|gitea.service.autoWatchOnChanges|Default value for AutoWatchOnChanges|false|

###  5.16. <a name='GiteaWebhook'></a>Gitea Webhook

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.webhook.queueLength|Hook task queue length, increase if webhook shooting starts hanging|1000|
|gitea.webhook.deliverTimeout|Deliver timeout in seconds|5|
|gitea.webhook.skipTlsVerify|Allow insecure certification|false|
|gitea.webhook.pagingNum|Number of history information in each page|10|

###  5.17. <a name='GiteaMailer'></a>Gitea Mailer

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.mailer.enabled|Enable mailer settings|false|
|gitea.mailer.sendBufferLen|Buffer length of channel, keep it as it is if you don't know what it is.|100|
|gitea.mailer.subjectPrefix|Prefix displayed before subject in mail||
|gitea.mailer.host|Mail server||
|gitea.mailer.disableHelo|Disable HELO operation when hostnames are different.||
|gitea.mailer.heloHostname|Custom hostname for HELO operation, if no value is provided, one is retrieved from system.||
|gitea.mailer.skipVerify|Do not verify the certificate of the server. Only use this for self-signed certificates||
|gitea.mailer.useCertificate|Use client certificate|false|
|gitea.mailer.certFile|Path to cert file|custom/mailer/cert.pem|
|gitea.mailer.keyFile|Path to key file|custom/mailer/key.pem|
|gitea.mailer.isTlsEnabled|Should SMTP connect with TLS, (if port ends with 465 TLS will always be used.)|false|
|gitea.mailer.from|Mail from address, RFC 5322. This can be just an email address, or the `"Name" <email@example.com>` format||
|gitea.mailer.user|Mailer user name||
|gitea.mailer.password|Mailer password||
|gitea.mailer.sendAsPlainText|Send mails as plain text|false|
|gitea.mailer.mailerType|Set Mailer Type (either SMTP, sendmail or dummy to just send to the log)|smtp|
|gitea.mailer.sendMailPath|Specify an alternative sendmail binary|sendmail|
|gitea.mailer.sendMailArgs|Specify any extra sendmail arguments||
|gitea.mailer.sendMailTimeout|Timeout for Sendmail|5m|

###  5.18. <a name='GiteaCache'></a>Gitea Cache

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.cache.enabled| Enable cache | true |
|gitea.cache.builtIn.enabled | Use built in memcached | true |
|gitea.cache.external.adapter| If built in is not enabled use this to chhose cache adapter [memory, redis, memcache] | memory |
|gitea.cache.external.host| If built in is not enabled use this to connect to an external cache | |
|gitea.cache.interval| Garbage Collection interval (sec), for memory cache only. | 60 |
|gitea.cache.itemTTL| Time to keep items in cache if not used, Setting it to 0 disables caching.| 16h |
|gitea.cache.lastCommit.enabled | Enable last commit cache | true |
|gitea.cache.lastCommit.itemTTL| Time to keep items in cache if not used, Setting it to 0 disables caching. | 8760h |
|gitea.cache.lastCommit.commitCount| Only enable the cache when repository’s commits count great than. | 1000 |

###  5.19. <a name='GiteaAttachment'></a>Gitea Attachment

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.attachment.enabled|Enable this to allow uploading attachments.|true|
|gitea.attachment.path|Path to store attachments.|data/attachments|
|gitea.attachment.allowedTypes||image/jpeg|image/png|application/zip|application/gzip|
|gitea.attachment.maxSize|Maximum size (MB).|4|
|gitea.attachment.maxFiles|Maximum number of attachments that can be uploaded at once.|5|

###  5.20. <a name='GiteaLog'></a>Gitea Log

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.log.rootPath|Root path for log files.||
|gitea.log.mode|Logging mode. For multiple modes, use a comma to separate values. You can configure each mode in per mode log subsections |console|
|gitea.log.bufferLen|Buffer length of the channel, keep it as it is if you don't know what it is.|10000|
|gitea.log.redirectMacaronLog|Redirects the Macaron log to its own logger or the default logger. |false|
|gitea.log.macaron|Logging mode for the macaron logger, use a comma to separate values. Configure each mode in per mode log subsections |file|
|gitea.log.routerLogLevel|The log level that the router should log at. (If you are setting the access log, its recommended to place this at Debug.)|Info|
|gitea.log.router|The mode or name of the log the router should log to. (If you set this to , it will log to default gitea logger.) NB: You must REDIRECT_MACARON_LOG and have DISABLE_ROUTER_LOG set to false for this option to take effect. Configure each mode in per mode log subsections|console|
|gitea.log.enableAccessLog|Creates an access.log in NCSA common log format, or as per the following template|false|
|gitea.log.access|Logging mode for the access logger, use a comma to separate values. Configure each mode in per mode log subsections |file|
|gitea.log.level| General log level. [Trace, Debug, Info, Warn, Error, Critical, Fatal, None]|Info|
|gitea.log.stackTraceLevel|Default log level at which to log create stack traces. [Trace, Debug, Info, Warn, Error, Critical, Fatal, None]|None|
|gitea.log.x.flags|A comma separated string representing the log flags.|stdflags|
|gitea.log.x.expression| regular expression to match either the function name, file or message. Defaults to empty. Only log messages that match the expression will be saved in the logger.||
|gitea.log.x.prefix|An additional prefix for every log line in this logger. Defaults to empty.||
|gitea.log.x.colorize| Colorize the log lines by default|false|
|gitea.log.console.level|Log Level [Trace, Debug, Info, Warn, Error, Critical, Fatal, None]|None|
|gitea.log.console.stderr|Use Stderr instead of Stdout.|false|
|gitea.log.file.level|Log Level [Trace, Debug, Info, Warn, Error, Critical, Fatal, None]|None|
|gitea.log.file.fileName|Set the file_name for the logger. If this is a relative path this will be relative to ROOT_PATH||
|gitea.log.file.logRotate|This enables automated log rotate(switch of following options)|true|
|gitea.log.file.maxLines|Max number of lines in a single file|1000000|
|gitea.log.file.maxSizeShift|Max size shift of a single file, default is 28 means 1 << 28, 256MB|28|
|gitea.log.file.dailyRotate|Segment log daily|true|
|gitea.log.file.maxDays|delete the log file after n days|7|
|gitea.log.file.compress|compress logs with gzip|true|
|gitea.log.file.compressionLeveL|compression level see godoc for compress/gzip|-1|
|gitea.log.conn.level|Log Level [Trace, Debug, Info, Warn, Error, Critical, Fatal, None]|None|
|gitea.log.conn.reconnOnMsg|Reconnect host for every single message, default is false|false|
|gitea.log.conn.reconnect|Try to reconnect when connection is lost, default is false|false|
|gitea.log.conn.protocol|Either "tcp", "unix" or "udp", default is "tcp"|tcp|
|gitea.log.conn.addr|Host address||
|gitea.log.smtp.level|Log Level [Trace, Debug, Info, Warn, Error, Critical, Fatal, None]|None|
|gitea.log.smtp.subject|Name displayed in mail title, default is "Diagnostic message from server"|Diagnostic message from server|
|gitea.log.smtp.host|Mail server||
|gitea.log.smtp.user|Mailer user name||
|gitea.log.smtp.password|Mailer password||
|gitea.log.smtp.receivers|Receivers, can be one or more, e.g. 1@example.com,2@example.com|false|

###  5.21. <a name='GiteaGit'></a>Gitea Git

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.git.path|The path of git executable. If empty, Gitea searches through the PATH environment.||
|gitea.git.disableDiffHighlight|Disables highlight of added and removed changes|1000|
|gitea.git.maxGitDiffLines|Max number of lines allowed in a single file in diff view|5000|
|gitea.git.maxGitDiffLineChars|Max number of allowed characters in a line in diff view|100|
|gitea.git.maxGitDiffFiles|Max number of files shown in diff view||
|gitea.git.gcArgs|Arguments for command 'git gc', e.g. "--aggressive --auto"||
|gitea.git.enableAutoGitWireProt|If use git wire protocol version 2 when git version >= 2.18, default is true, set to false when you always want git wire protocol version 1|true|
|gitea.git.pullRequestPushMessage|Respond to pushes to a non-default branch with a URL for creating a Pull Request (if the repository has them enabled)|true|
|gitea.git.timeout.default|Git operations default timeout seconds.|360|
|gitea.git.timeout.migrate|Migrate external repositories timeout seconds.|600|
|gitea.git.timeout.mirror|Mirror external repositories timeout seconds.|300|
|gitea.git.timeout.clone|Git clone from internal repositories timeout seconds.|300|
|gitea.git.timeout.pull|Git pull from internal repositories timeout seconds.|300|
|gitea.git.timeout.gc|Git repository GC timeout seconds.|60|
|gitea.git.metrics.enabled| Enables /metrics endpoint for prometheus.|false|
|gitea.git.metrics.token|You need to specify the token, if you want to include in the authorization the metrics . The same token need to be used in prometheus parameters bearer_token or bearer_token_file.||

###  5.22. <a name='GiteaExtraConfig'></a>Gitea Extra Config

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|gitea.extraConfig|If you want anymore configuration you need to do it here as a multiline string. For example look at https://docs.gitea.io/en-us/config-cheat-sheet/||

###  5.23. <a name='MemcachedBuiltIn'></a>Memcached BuiltIn

Memcached is loaded as a dependency from [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami/memcached) if enabled in the values. Complete Configuration can be taken from their website.

The following parameters are the defaults set by this chart

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|memcached.service.port|Memcached Port| 11211|

###  5.24. <a name='MysqlBuiltIn'></a>Mysql BuiltIn

Mysql is loaded as a dependency from stable. Configuration can be found from this [website](https://github.com/helm/charts/tree/master/stable/mysql)

The following parameters are the defaults set by this chart

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|mysql.mysqlRootPassword|Password for the root user. Ignored if existing secret is provided|gitea|
|mysql.mysqlUser|Username of new user to create.|gitea|
|mysql.mysqlPassword|Password for the new user. Ignored if existing secret is provided|gitea|
|mysql.mysqlDatabase|Name for new database to create.|gitea|
|mysql.service.port|Port to connect to mysql service|3306|
|mysql.persistence|Persistence size for mysql |10Gi|

###  5.25. <a name='PostgresqlBuiltIn'></a>Postgresql BuiltIn

Postgresql is loaded as a dependency from bitnami. Configuration can be found from this [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami/postgresql)

The following parameters are the defaults set by this chart

| Parameter           | Description                       | Default                      |
|---------------------|-----------------------------------|------------------------------|
|postgresql.global.postgresql.postgresqlDatabase| PostgreSQL database (overrides postgresqlDatabase)|gitea|
|postgresql.global.postgresql.postgresqlUsername| PostgreSQL username (overrides postgresqlUsername)|gitea|
|postgresql.global.postgresql.postgresqlPassword| PostgreSQL admin password (overrides postgresqlPassword)|gitea|
|postgresql.global.postgresql.servicePort|PostgreSQL port (overrides service.port)|5432|
|postgresql.persistence.size| PVC Storage Request for PostgreSQL volume |10Gi|
