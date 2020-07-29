{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gitea.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gitea.fullname" -}}
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
{{- define "gitea.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "gitea.labels" -}}
helm.sh/chart: {{ include "gitea.chart" . }}
{{ include "gitea.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "gitea.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gitea.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "postgresql.dns" -}}
{{- printf "%s-postgresql.%s.svc.cluster.local:%g" .Release.Name .Release.Namespace .Values.postgresql.global.postgresql.servicePort -}}
{{- end -}}

{{- define "postgresql.servicename" -}}
{{- printf "%s-postgresql" .Release.Name -}}
{{- end -}}

{{- define "mysql.dns" -}}
{{- printf "%s-mysql.%s.svc.cluster.local:%g" .Release.Name .Release.Namespace .Values.mysql.service.port | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "memcached.dns" -}}
{{- printf "%s-memcached.%s.svc.cluster.local:%g" .Release.Name .Release.Namespace .Values.memcached.service.port | trunc 63 | trimSuffix "-" -}}
{{- end -}}

