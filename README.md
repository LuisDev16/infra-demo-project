# Terraform workflow

El workflow `.github/workflows/terraform.yml` valida los cambios en `push` y
`pull_request` con `terraform fmt`, `init` y `validate`. Estos eventos no tienen
permisos OIDC ni ejecutan `plan`, `apply` o `destroy`.
Usa Terraform 1.9.8, necesario para las validaciones de variables cruzadas del
módulo de red de Azure.

Este workflow está configurado por ahora solo para Azure. Para ejecutarlo, ve a
**Actions → Terraform → Run workflow** y selecciona una operación:

- `plan`: crea un plan y publica un resumen de acciones sin imprimir valores.
- `apply`: crea el plan, espera la aprobación del Environment protegido y aplica
  exactamente ese archivo de plan.
- `destroy`: genera un plan de destrucción explícito, espera una aprobación
  separada y aplica ese mismo plan. Un `push` o `pull_request` nunca destruye.

## Configuración requerida en GitHub

1. Configura OIDC en Microsoft Entra y asigna a la identidad permisos mínimos en
   Azure. Añade `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` y
   `AZURE_SUBSCRIPTION_ID` como **Actions variables** o **Actions secrets** del
   repositorio.
2. Crea el **Actions secret** `TF_PLAN_ENCRYPTION_KEY` con una clave aleatoria
   fuerte. Los planes de Terraform pueden contener valores sensibles; el artefacto
   de plan se cifra y se conserva solo por un día.
3. Crea los GitHub Environments `terraform-apply` y `terraform-destroy` y configura
   **Required reviewers** en ambos (idealmente aprobadores distintos para
   destrucción). El segundo Environment protege específicamente `destroy`.
4. Configura las credenciales federadas de la aplicación de Entra para confiar
   solo en este repositorio y en las referencias/Environments del workflow; no
   uses credenciales cloud permanentes en el repositorio.
5. Configura un **backend remoto con bloqueo de estado** en
   `environments/azure` antes de ejecutar operaciones manuales. El workflow
   rechaza el backend local: es necesario para mantener el estado y evitar
   despliegues concurrentes. El backend debe permitir OIDC al inicializarlo.

El resumen de ejecución muestra las acciones y direcciones de recursos, pero no
los valores marcados como sensibles por Terraform. El archivo cifrado conserva el
plan exacto que consume `apply`; no se genera un plan nuevo después de la
aprobación. Marca como `sensitive` todas las variables y salidas que contengan
secretos. Mantén el repositorio y el acceso a Actions restringidos a colaboradores
autorizados.

Fija las referencias de módulos remotos a tags o commits inmutables para que el
código revisado no cambie entre el plan y el apply.

No guardes secretos en archivos `*.tfvars`; el archivo `terraform.tfvars` de Azure
actual contiene parámetros de ejemplo y permanece versionado en este momento.
