{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dependency-track.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dependency-track.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dependency-track.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dependency-track.labels" -}}
helm.sh/chart: {{ include "dependency-track.chart" . }}
{{ include "dependency-track.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dependency-track.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dependency-track.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dependency-track.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dependency-track.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "dependency-track.configParse" -}}
{{- range $key, $value := .data  }}
{{- if kindIs "map" $value }}
{{- $newName := eq $.currentName "" | ternary (printf "%s" $key) (printf "%s.%s" $.currentName $key) }}
{{- include "dependency-track.configParse" (  dict "data" $value "currentName" $newName ) }}
{{- else }}
{{- if eq $key "driverPath" }}
{{ printf "%s.driver.path=" $.currentName }}{{ $value }}
{{- else }}
{{ printf "%s.%s=" $.currentName $key }}{{ $value }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "postgresql.dns" -}}
{{- printf "%s-postgresql.%s.svc.cluster.local:%g" .Release.Name .Release.Namespace .Values.postgresql.global.postgresql.servicePort -}}
{{- end -}}
{{- define "mysql.dns" -}}
{{- printf "%s-mysql.%s.svc.cluster.local:%g" .Release.Name .Release.Namespace .Values.mysql.service.port | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "mariadb.dns" -}}
{{- printf "%s-mariadb.%s.svc.cluster.local:%g" .Release.Name .Release.Namespace .Values.mysql.service.port | trunc 63 | trimSuffix "-" -}}
{{- end -}}