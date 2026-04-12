# Deploy em Oracle Cloud com Kamal

Este guia te orienta como fazer deploy da app Rails no Oracle Cloud Always Free usando Kamal.

## Pré-requisitos

1. Conta Oracle Cloud criada (https://www.oracle.com/cloud/free/)
2. `kamal` instalado localmente: `gem install kamal` ou já deve estar no seu Gemfile
3. Chave SSH para conectar na VM
4. Docker Hub account (grátis em https://hub.docker.com) para hospedar a imagem

## Passo 1: Criar VM no Oracle Cloud

1. Acesse Oracle Cloud Console
2. Vá em Compute → Instances
3. Clique em "Create instance"
4. Configurações:
   - Image: Ubuntu 24.04 (sempre free eligible)
   - Shape: Ampere (ARM) - 4 vCPU, 24 GB RAM (Always Free)
   - SSH Key: gera uma nova ou usa a sua
   - Salve a chave privada em segurança
5. Clique em "Create"
6. Aguarde 2-3 minutos até estar "Running"
7. Copie o IP público (ex: 147.123.45.67)
8. Abra Security Group (VCN) e adicione regra:
   - Port 80 (HTTP)
   - Port 443 (HTTPS)
   - Port 22 (SSH, já deve existir)

## Passo 2: Configurar Docker + Kamal na VM

Via SSH na VM Oracle:

```bash
ssh ubuntu@149.123.45.67  # Use seu IP
```

Instale dependências:

```bash
sudo apt update && sudo apt install -y docker.io git curl
sudo usermod -aG docker ubuntu
newgrp docker
```

Restart SSH session para aplicar grupo:
```bash
exit
ssh ubuntu@149.123.45.67
```

## Passo 3: Preparar Credenciais Localmente

No seu computador, extraia a chave privada:

```bash
# Se recebeu um arquivo .key do Oracle, já está pronto
# Senão, exporte da console Oracle
chmod 600 caminho/para/oracle_key.key
```

Teste conexão:
```bash
ssh -i caminho/para/oracle_key.key ubuntu@149.123.45.67 "uname -a"
```

## Passo 4: Configurar Kamal com Docker Hub

1. Faça login no Docker Hub:
```bash
docker login
```

2. Edite `config/deploy.yml`:

```yaml
service: contem_cafe

# Seu nome de usuário Docker Hub
image: seu-usuario-docker-hub/contem_cafe

servers:
  web:
    - 149.123.45.67  # SUBSTITUA PELO SEU IP ORACLE

registry:
  server: docker.io
  username: seu-usuario-docker-hub
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    SOLID_QUEUE_IN_PUMA: true

volumes:
  - "contem_cafe_storage:/rails/storage"

asset_path: /rails/public/assets

# Quando você tiver SSL configurado
# proxy:
#   ssl: true
#   host: contemcafe.com.br
```

3. Armazene a senha do Docker Hub como secret:

```bash
mkdir -p .kamal/secrets
echo "SEU_TOKEN_OU_SENHA_DOCKER_HUB" > .kamal/secrets/kamal_registry_password
```

4. Adicione sua chave SSH ao Kamal:

```bash
cat >> config/deploy.yml <<EOF

ssh:
  user: ubuntu
EOF
```

5. Configure a chave SSH no seu local:

```bash
export KAMAL_PRIVATE_KEY_PATH=caminho/para/oracle_key.key
```

Ou adicione ao `.env`:
```
KAMAL_PRIVATE_KEY_PATH=/caminho/absoluto/para/oracle_key.key
```

## Passo 5: Configurar variáveis de ambiente

1. Copie seu RAILS_MASTER_KEY:

```bash
cat config/master.key
```

2. Armazene como secret:

```bash
echo "SUA_RAILS_MASTER_KEY_AQUI" > .kamal/secrets/rails_master_key
```

3. Opcionalmente, adicione outras variáveis em `.kamal/secrets` conforme necessário.

## Passo 6: Deploy!

Na raiz do projeto:

```bash
# First deployment - registra tudo
kamal setup

# Depois, para atualizações
kamal deploy
```

Monitore o progresso:

```bash
kamal logs
```

## Passo 7: Apontar o domínio

Edite seu DNS (`contemcafe.com.br`) e aponte para o IP da Oracle:

```
Type: A
Name: @
Value: 149.123.45.67  # Seu IP Oracle
```

Aguarde propagação (5-30 min).

## Passo 8: Configurar SSL (Let's Encrypt)

Após domínio estar apontando, edite `config/deploy.yml`:

```yaml
proxy:
  ssl: true
  host: contemcafe.com.br
```

E em `config/environments/production.rb`:

```ruby
config.assume_ssl = true
config.force_ssl = true
```

Deploy novamente:

```bash
kamal deploy
```

## Comandos úteis

```bash
kamal status          # Verifica status
kamal logs            # Tails logs em tempo real
kamal console         # Rails console na produção
kamal app exec        # Executa comando
kamal deploy          # Deploy novo
kamal redeploy        # Redeploy (sem rebuild)
kamal reboot          # Restart da app
```

## Troubleshooting

**Erro de conexão SSH:**
```bash
ssh -i caminho/chave ubuntu@seu-ip "echo conectado"
```

**Erro ao fazer push para Docker:**
```bash
docker login  # Re-autentica
```

**App não inicia:**
```bash
kamal logs  # Vê o erro
```

**DB migrations falhando:**
```bash
kamal app exec "bin/rails db:create db:migrate"
```

## Próximas otimizações (opcional)

- Adicionar Postgres no Oracle (em vez de SQLite3)
- Configurar backups automáticos
- Monitoramento com Prometheus/Grafana
- CDN para assets (Cloudflare grátis)

---

Qualquer dúvida durante o deploy, confira a documentação oficial:
- Kamal: https://kamal-deploy.org
- Oracle Cloud: https://docs.oracle.com/en-us/iaas/
