# ShellCheck pre-commit hook

This is NOT an official [pre-commit hook](https://pre-commit.com/) for
[differential-shellcheck](https://github.com/redhat-plumbers-in-action/differential-shellcheck),
the static analysis tool for changed shell scripts.

Activate by adding it to your `.pre-commit-config.yaml`:

```sh
repos:
-   repo: https://github.com/mpoberezhniy/differential-shellcheck-precommit
    rev: v5.2.0
    hooks:
    -   id: differential-shellcheck
#       args: ["--severity=warning"]  # Optionally only show errors and warnings
```

#### Why a separate repo?

This repo keeps the pre-commit hook out of the critical path of differential-shellcheck
releases, reducing the number of things that can go wrong. This in turn helps
ensure a smoother `pre-commit autoupdate`. 

