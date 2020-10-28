{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "awx.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "awx.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "awx.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "awx.labels" -}}
helm.sh/chart: {{ include "awx.chart" . }}
{{ include "awx.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "awx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "awx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "awx.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "awx.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "postgresql.servicename" -}}
{{- printf "%s-postgresql" .Release.Name -}}
{{- end -}}


{{- define "awx.volumeMounts" -}}
- name: "{{ include "awx.fullname" . }}-application-credentials"
  mountPath: "/etc/tower/conf.d/"
  readOnly: true

- name: {{ include "awx.fullname" . }}-application-config
  mountPath: "/etc/tower/settings.py"
  subPath: settings.py
  readOnly: true

- name: {{ include "awx.fullname" . }}-nginx-config
  mountPath: /etc/nginx/nginx.conf
  subPath: nginx.conf
  readOnly: true

- name: {{ include "awx.fullname" . }}-launch-awx-web
  mountPath: "/usr/bin/launch_awx.sh"
  subPath: "launch_awx.sh"
  readOnly: true

- name: {{ include "awx.fullname" . }}-launch-awx-task
  mountPath: "/usr/bin/launch_awx_task.sh"
  subPath: "launch_awx_task.sh"
  readOnly: true

- name: {{ include "awx.fullname" . }}-supervisor-web-config
  mountPath: "/etc/supervisord.conf"
  subPath: supervisor.conf
  readOnly: true

- name: {{ include "awx.fullname" . }}-supervisor-task-config
  mountPath: "/etc/supervisord_task.conf"
  subPath: supervisor_task.conf
  readOnly: true

- name: {{ include "awx.fullname" . }}-secret-key
  mountPath: "/etc/tower/SECRET_KEY"
  subPath: SECRET_KEY
  readOnly: true

- name: {{ include "awx.fullname" . }}-redis-socket
  mountPath: "/var/run/redis"
- name: supervisor-socket
  mountPath: "/var/run/supervisor"
- name: rsyslog-socket
  mountPath: "/var/run/awx-rsyslog"
- name: rsyslog-dir
  mountPath: "/var/lib/awx/rsyslog"
{{- end -}}

{{- define "awx.taskAbsCpu" -}}
  {{- if .Values.awx.settings.systemTaskAbsCpu }}
    {{- .Values.awx.settings.systemTaskAbsCpu }}
  {{- else }}
    {{- $cpu := .Values.resources.task.requests.cpu | replace "m" "" -}}
    {{- div $cpu 1000 | mul 4 | int }}
  {{- end }}
{{- end -}}

{{- define "awx.taskAbsMem" -}}
  {{- if .Values.awx.settings.systemTaskAbsMem }}
    {{- .Values.awx.settings.systemTaskAbsMem }}
  {{- else }}
    {{- $mem := .Values.resources.task.requests.memory | replace "Mi" "" }}
    {{- div $mem 100 | int }}
  {{- end }}
{{- end -}}