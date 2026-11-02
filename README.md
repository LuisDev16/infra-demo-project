# Infra Demo Project

Este repositorio consume módulos Terraform compartidos. La automatización de
solicitudes y despliegues está habilitada inicialmente para Azure, porque
`environments/azure` es el único entorno con provider, backend remoto y
autenticación OIDC configurados.

## Flujo de solicitud

1. Asegúrate de que exista la etiqueta `infrastructure-request` y abre un issue
   usando **Infrastructure request**.
2. El asistente inspecciona el catálogo del repositorio
   `LuisDev16/modulos-terraform` y pregunta en el issue por las variables
   obligatorias que falten.
3. Al completar la información, crea o actualiza la rama
   `copilot/issue-<número>` y abre un PR a `main`. Para el módulo Azure `network`,
   el bloque se agrega en `environments/azure/main.tf`; ese módulo crea el grupo
   de recursos, VNet, subnet y NSG (y la VM solo si se habilita explícitamente).
4. El PR ejecuta `terraform fmt`, `init` sin backend y `validate`. Configura una
   regla de protección de `main` que exija aprobación antes de fusionar.
5. Después de fusionar el PR aprobado, el workflow genera un plan con el backend
   remoto. El job de apply espera la aprobación del GitHub Environment
   `terraform-apply` y aplica exactamente ese plan.

Desde **Actions → Infrastructure Copilot and Terraform → Run workflow**, en la
rama `main`, puedes reintentar un `apply`; indica `issue_number` para cerrar el
issue asociado. El plan se genera de nuevo y el apply requiere la aprobación de
`terraform-apply`.

Al terminar un despliegue automático o un reintento manual `apply`, un job
finalizador cierra el issue asociado y comenta el resultado (estados de
validate/plan/apply y enlace a Actions), incluso si algún job falla. No se hace
rollback automático del commit ni de la infraestructura.

El workflow de intake no ejecuta `terraform apply`. La aprobación del PR y la
aprobación del Environment son controles distintos: el PR debe aprobarse y
fusionarse primero; luego un revisor debe aprobar el despliegue. Configura
**Required reviewers** en `terraform-apply`.

## Configuración requerida en GitHub

Configura estos Actions secrets/variables:

- `LLM_API_KEY` (secret), y opcionalmente `LLM_BASE_URL` / `LLM_MODEL` (variables).
- `GH_PLATFORM_TOKEN` (secret): token limitado a este repositorio con permisos
  de escritura de Contents y Pull requests. Se usa para publicar la rama/PR; un
  push hecho con `GITHUB_TOKEN` no iniciaría los checks de PR.
- `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` y `AZURE_SUBSCRIPTION_ID` como variables
  o secrets, con federación OIDC configurada para este repositorio.
- `TF_PLAN_ENCRYPTION_KEY` (secret): clave aleatoria fuerte para cifrar el plan
  temporal de Terraform.

Configura además el backend Azure Blob de `environments/azure` con bloqueo de
estado y autenticación OIDC. El workflow rechaza el backend local. Protege la
rama `main` para requerir PR aprobado y configura el GitHub Environment
`terraform-apply` con Required reviewers. La identidad federada de Azure debe
confiar en el workflow desde `refs/heads/main` y desde el Environment protegido
`terraform-apply`.

No compartas secretos, claves privadas ni datos sensibles en los issues. La
automatización de issues solo soporta Azure por ahora; AWS y GCP requieren
configurar sus providers, credenciales OIDC y backends antes de habilitar esos
entornos. No guardes secretos en `terraform.tfvars`; el archivo existente de Azure
está versionado y debe contener solo valores no sensibles. Marca como `sensitive`
las variables y salidas Terraform que puedan contener información confidencial.
