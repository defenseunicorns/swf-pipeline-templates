FROM ghcr.io/anchore/grype:v0.73.4

RUN ["/grype", "db", "update"]