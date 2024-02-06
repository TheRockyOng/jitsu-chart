{{/*
Expand the name of the chart.
*/}}
{{- define "jitsu.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jitsu.fullname" -}}
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
{{- define "jitsu.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "jitsu.labels" -}}
helm.sh/chart: {{ include "jitsu.chart" . }}
{{ include "jitsu.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "jitsu.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jitsu.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "jitsu.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "jitsu.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "jitsu.databaseUrl" -}}
{{- if and (not .Values.config.databaseUrl) .Values.postgresql.enabled }}
{{- with $.Values.postgresql.auth -}}
{{ printf "postgres://%s:%s@%s:%d/%s?schema=newjitsu"
  .username
  .password
  (printf "%s-postgresql" $.Release.Name)
  5432
  .database
}}
{{- end }}
{{- else -}}
{{ .Values.config.databaseUrl }}
{{- end }}
{{- end }}

{{- define "jitsu.redisUrl" -}}
{{- if and (not .Values.config.redisUrl) .Values.redis.enabled }}
{{- with $.Values.redis -}}
{{ printf "redis://:%s@%s:%d"
  .auth.password
  (printf "%s-redis-master" $.Release.Name)
  6379
}}
{{- end }}
{{- else -}}
{{ .Values.config.redisUrl }}
{{- end }}
{{- end }}

{{- define "jitsu.mongodbUrl" -}}
{{- if and (not .Values.config.mongodbUrl) .Values.mongodb.enabled }}
{{- with $.Values.mongodb.auth -}}
{{ printf "mongodb://%s:%s@%s:%d/%s"
  (index .usernames 0)
  (index .passwords 0)
  (printf "%s-mongodb" $.Release.Name)
  27017
  (index .databases 0)
}}
{{- end }}
{{- else -}}
{{ .Values.config.mongodbUrl }}
{{- end }}
{{- end }}
