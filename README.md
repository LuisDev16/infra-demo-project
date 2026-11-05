# Infra Demo Project

Este repositorio consume módulos Terraform compartidos de
`LuisDev16/modulos-terraform`. El intake de issues soporta AWS y Azure; GCP aún no
está habilitado.

## Flujo de solicitud

1. Asegúrate de que exista la etiqueta `infrastructure-request` y abre un issue
   usando **Infrastructure request**. Selecciona AWS o Azure y describe lo que
   necesitas en lenguaje normal.
2. El asistente consulta el catálogo real de módulos y pregunta por las entradas
   obligatorias que falten.
3. Con los datos completos, crea o actualiza la rama `copilot/issue-<número>` y
   abre un PR a `main`. La instancia generada se agrega a
   `environments/<cloud>/main.tf`; los módulos base existentes se conservan.
4. El workflow correspondiente valida el PR. Protege `main` para exigir aprobación
   antes de fusionarlo.
5. Al fusionarlo, Azure usa su backend Blob y AWS el workspace HCP
   `luisdcm/infra-demo-project-aws`. AWS genera un plan remoto guardado; el job de
   apply espera la aprobación del Environment GitHub `terraform-apply` y aplica ese
   mismo plan. No se necesita otra confirmación en la UI de HCP.

El módulo `aws/network` solo crea una VPC y una subnet. La región de AWS es fija
por workspace (`us-east-1` actualmente). Solicitudes de S3, EC2/VM u otros
servicios requieren módulos que los implementen; el bot no debe crear un PR para
un recurso que no encuentre en el catálogo.

Al terminar un despliegue automático o un reintento manual, el workflow cierra el
issue asociado y comenta el resultado y el enlace a Actions, incluso si algún job
falla. No se hace rollback automático del código ni de la infraestructura.

## Configuración requerida en GitHub y HCP

Actions secrets/variables:

- `LLM_API_KEY` (secret); opcionalmente `LLM_BASE_URL` y `LLM_MODEL` (variables).
- `GH_PLATFORM_TOKEN` (secret): permisos Contents y Pull requests write para crear
  ramas y PRs en este repositorio.
- `HCP_TERRAFORM_TOKEN` (secret a nivel de repositorio): token con permisos de
  plan/apply para el workspace HCP AWS. El workflow lo entrega a Terraform CLI como
  `TF_TOKEN_app_terraform_io`.
- `AWS_REGION` (Actions variable): debe coincidir con `aws_region` en el workspace
  HCP; actualmente `us-east-1`.
- `TF_PLAN_ENCRYPTION_KEY` (secret): clave fuerte para cifrar los planes guardados.
- `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` y `AZURE_SUBSCRIPTION_ID` para Azure OIDC.

En HCP configura las credenciales dinámicas AWS y los permisos IAM de VPC/subnet.
Mantén las variables base `aws_region` y `name` en el workspace; las instancias
creadas por issues reciben sus argumentos en sus propios bloques de módulo. El
provider raíz usa la región del workspace.

Configura el backend Azure Blob con bloqueo de estado y autenticación OIDC.
Protege `main` con aprobación de PR y configura `terraform-apply` con Required
reviewers para aprobar los applies de ambos proveedores.

`terraform.tfvars` está ignorado por Git; no guardes credenciales en ese archivo.
El módulo AWS actual no implementa S3, EC2/VM ni almacenamiento. Añade y publica
esos módulos en `modulos-terraform` antes de habilitar solicitudes para ellos.
