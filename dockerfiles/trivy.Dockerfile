FROM ghcr.io/aquasecurity/trivy:0.48.0

RUN trivy image --download-db-only