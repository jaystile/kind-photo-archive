# Postgres

## Helm Chart
```bash
# https://github.com/helm/charts/tree/master/stable/postgresql, says to use the bitnami repo
# https://github.com/bitnami/charts/tree/master/bitnami/postgresql
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo postgres
helm pull bitnami/postgresql --version 10.4.0
tar zxvf  postgresql-10.4.0.tgz
rm postgrsql-10.4.0.tgz
```

## Install
```
cd helm/postgres
helm upgrade -i postgresql -f values-project.yaml --version 10.4.0 .
kubectl logs -f postgres-postgresql-0
```

## Test database connection
```bash
# Get the password from the secret
PGPASSWORD=$(kubectl get secret secrets-postgres -o json | jq -r '.data."project-password"' | base64 --decode)

kubectl port-forward --namespace default svc/postgresql 5432:5432 

kubectl exec -it postgresql-postgresql-0 -- bash

PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432

# Log into the pod and test.
PGPASSWORD="${PROJECT_PASSWORD}" psql -U project -d project
\dt
\q
```

## Clean up
```
helm delete postgres; k delete pvc data-postgres-postgresql-0
```