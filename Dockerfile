FROM ghcr.io/redhat-plumbers-in-action/differential-shellcheck:v5

COPY pre-commit.sh /action/

ENTRYPOINT ["/action/pre-commit.sh"]
