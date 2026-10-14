EMURB Desk
==========

Sistema de gestão de TI e helpdesk baseado no GLPI 12.0.0.

Autores
-------
- João Oliveira
- Varlei Oliveira

Localização
-----------
Projeto: C:\EMURB-Desk
Acesso web: http://localhost:8080

Arquitetura
-----------
- web: GLPI 12.0.0 em Apache/PHP 8.3.
- db: MariaDB 10.11.
- cron: execução periódica das tarefas agendadas do GLPI.
- Volumes persistentes: banco de dados, configuração e arquivos do GLPI.

Arquivos principais
-------------------
- Dockerfile: imagem personalizada do GLPI.
- docker-compose.yml: serviços, rede, volumes e verificações de saúde.
- glpi-12.0.0.tgz: pacote da aplicação usado na construção da imagem.
- emurb-desk-logo.png: arquivo original do logotipo.
- emurb-desk-favicon.png: favicon personalizado.
- branding-fixed: versões transparentes e dimensionadas dos logotipos.
- .env: credenciais e configurações locais. Não versionar este arquivo.
- .env.example: modelo de variáveis de ambiente, quando disponível.

Como iniciar
------------
Abra o PowerShell e execute:

cd C:\EMURB-Desk
docker compose up --pull always -d

Acesse http://localhost:8080 no navegador.

Como parar
----------
Para parar os containers sem apagar os dados:

docker compose stop

Para remover os containers e manter os volumes:

docker compose down

Não use "docker compose down -v" sem confirmar antes. Essa opção remove os volumes e pode apagar o banco de dados, a configuração e os arquivos enviados.

Verificação de saúde
--------------------
Ver status dos serviços:

"docker compose ps"

Ver logs:

docker compose logs --tail 100

Ver logs de um serviço específico:

docker compose logs --tail 100 web
docker compose logs --tail 100 db
docker compose logs --tail 100 cron

Verificar o esquema do banco:

docker compose exec -u www-data web php bin/console database:check_schema_integrity

Atualização do GLPI
-------------------
A versão atual é GLPI 12.0.0. Antes de atualizar:

1. Faça backup do volume do banco de dados.
2. Faça backup dos volumes de configuração e arquivos.
3. Substitua o pacote glpi-12.0.0.tgz pelo novo pacote.
4. Atualize as referências de versão no Dockerfile e no docker-compose.yml.
5. Construa a nova imagem.
6. Inicie os serviços.
7. Execute a migração do banco:

   docker compose exec -u www-data web php bin/console database:update --no-interaction

8. Valide o esquema:

   docker compose exec -u www-data web php bin/console database:check_schema_integrity

Volumes persistentes
--------------------
Os volumes atualmente reutilizados pelo projeto são:

- teste-emurb_dbdata
- teste-emurb_glpi_config
- teste-emurb_glpi_files

As credenciais ficam no arquivo .env. Não publique esse arquivo nem incorpore senhas em imagens Docker.

Observações
-----------
- O serviço web usa o nome db para acessar o MariaDB dentro da rede Compose.
- O cron executa as tarefas agendadas do GLPI a cada 60 segundos.
- O favicon e os logotipos personalizados são incorporados durante a construção da imagem.
- O Apache utiliza /var/www/glpi/public como raiz pública.
