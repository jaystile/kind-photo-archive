# Install

## Secrets
>The secrets have not been added to version control.
```bash
pushd helm/secrets
helm upgrade -i secrets .
popd
```

## Postgres
```bash
pushd postgres/helm
helm upgrade -i postgresql -f values-project.yaml --version 10.4.0 .
popd
```