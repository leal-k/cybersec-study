# 02: Rede do laboratório

## Topologia

```
            Internet
               │
        [ roteador de casa ]  ← rede real: NÃO é alvo
               │
     ┌─────────┴──────────┐
     │  Fedora (host)     │
     │                    │
     │  virbr0 192.168.122.1 ──── Juice Shop (Docker) :3000
     │     │              │
     │     └── kali  192.168.122.x   (atacante)
     │     └── metasploitable 192.168.122.y  (alvo, opcional, semana 2)
     └────────────────────┘
```

A rede `default` do libvirt é um NAT: as VMs saem para a internet (atualizar o Kali, acessar o Bandit), mas ninguém de fora entra nelas. O alvo do lab inteiro é **192.168.122.0/24**.

## Juice Shop visível só para a VM

Seu Juice Shop do projeto de QA provavelmente foi criado com `-p 3000:3000`. Isso publica a porta em **todas** as interfaces do notebook. E o Docker cria as próprias regras de firewall, que podem passar por cima do firewalld: em qualquer Wi-Fi em que você estiver, outra pessoa consegue abrir uma aplicação propositalmente vulnerável no seu computador.

Troque por um bind só na interface da rede das VMs:

```bash
docker ps -a --filter ancestor=bkimminich/juice-shop   # achar o container antigo
docker rm -f <nome-do-container-antigo>

# virbr0 precisa existir antes (rede default ativa)
docker run -d --name juice-shop -p 192.168.122.1:3000:3000 bkimminich/juice-shop
ss -ltnp | grep 3000    # deve mostrar 192.168.122.1:3000, não 0.0.0.0:3000
```

Para acessar do próprio Fedora: `http://192.168.122.1:3000`.

> Esse é o primeiro "achado" do curso: um serviço exposto além do necessário. Vale um parágrafo no LOG.

## Testar a partir do Kali

```bash
curl -sI http://192.168.122.1:3000 | head -n1    # esperado: HTTP/1.1 200 OK
```

**Se der timeout**, o firewalld do Fedora pode estar bloqueando o tráfego que vem da VM. Teste liberando só em tempo de execução (some no reboot):

```bash
# no Fedora
sudo firewall-cmd --zone=libvirt --add-port=3000/tcp
```

Se resolver, torne permanente com `--permanent` e `sudo firewall-cmd --reload`. Se não resolver, use o **plano B**: rodar o Juice Shop dentro do próprio Kali (`sudo apt install -y docker.io`, `sudo docker run -d -p 127.0.0.1:3000:3000 bkimminich/juice-shop`) e capturar na interface `lo` no Wireshark. Funciona igual para a fase de web; só perde o tráfego passando por uma rede "de verdade".


## O que deu diferente no meu caso

### Teste de acesso: positivo e negativo
Isolamento só está provado quando os dois lados são testados:

| Teste | Comando | Esperado | Resultado |
|---|---|---|---|
| Positivo (Kali → lab) | `curl -sI http://192.168.122.1:3000` | `200 OK` | ✅ `200 OK` de primeira |
| Negativo (rede de casa) | `curl -m 3 -sI http://192.168.1.101:3000` | sem resposta | ✅ sem resposta |
| Bind conferido | `ss -ltnp \| grep 3000` | `192.168.122.1:3000` | ✅ |

O firewalld **não** bloqueou o acesso da VM ao Juice Shop, então o plano B (Juice Shop dentro do Kali) não foi necessário. Minha rede de casa é `192.168.1.0/24` (Fedora em `192.168.1.101`, interface `enp6s0`), registrada como fora do escopo em `lab/escopo.md`.

### `virbr0` DOWN com IP
Com a VM desligada, `ip -br a` mostra `virbr0 DOWN 192.168.122.1/24`. É normal: uma ponte sem nada conectado fica sem portadora, como um switch sem cabos. Ao ligar a VM, o libvirt cria a interface `vnetN` da VM, pluga na ponte, e ela fica `UP`. O Docker consegue usar o IP mesmo com a ponte `DOWN`.

### `< >` não se digitam
Digitei `curl http://<192.168.1.101>:3000` e recebi `No such file or directory`. No bash, `<` é redirecionamento de entrada (`comando <arquivo`): o shell tentou abrir um arquivo chamado `192.168.1.101`. Os sinais na documentação marcavam só onde substituir o valor.

### Achado: stack do testeTecnico exposto para a rede inteira
Ao ver um `br-29358dd211c3` e 8 interfaces `veth` no `ip -br a`, listei os containers:

```bash
docker ps --format 'table {{.Names}}\t{{.Ports}}'
```

O stack do desafio técnico em Go estava publicado em `0.0.0.0` e `[::]` (todas as interfaces, IPv4 e IPv6), acessível a qualquer dispositivo da `192.168.1.0/24`:

| Porta | Serviço | Risco |
|---|---|---|
| 5432 | Postgres | banco acessível de fora |
| 8080 | Keycloak | console de administração de identidade |
| 4566 | MiniStack | emulador de AWS, sem autenticação |
| 9090 | Prometheus | métricas e configuração, sem autenticação |
| 8081–8083 | app Go | as três réplicas |

**Causa:** `ports: "5432:5432"` no compose, sem IP, faz o Docker publicar em todas as interfaces. As regras de NAT do Docker ficam fora do controle do firewalld.
**Ação:** derrubei com `docker compose down`.
**Correção para a próxima vez:** `ports: "127.0.0.1:5432:5432"`.
**Lição:** o mesmo processo de reconhecimento de um pentest (sinal indireto → serviço → risco), aplicado à minha própria máquina.

### Bug no `lab-up.sh`: `pipefail` + `grep -q`
A primeira versão falhou com `Requested operation is not valid: network is already active`. A linha era:

```bash
if ! virsh ... net-info default | grep -Eq 'Active:\s+yes'; then
```

O `grep -q` sai assim que encontra o padrão. Se o `virsh` ainda estiver escrevendo, recebe SIGPIPE e termina com erro. Com `set -o pipefail`, o pipeline inteiro conta como falha, e o `if !` interpretou isso como "rede inativa". O erro depende de timing (intermitente, como um teste *flaky*).

**Correção:** guardar a saída numa variável e procurar nela, sem pipe:

```bash
redes_ativas=$(virsh -c "$CONN" net-list --name)
if ! grep -qx default <<<"$redes_ativas"; then
```

Também adicionei `LC_ALL=C` (saídas sempre em inglês) e apliquei o mesmo padrão à checagem do container. Validado com `bash -x scripts/lab-up.sh` (saída `0`).

## Scripts

`scripts/lab-up.sh` sobe rede, Juice Shop e Kali na ordem certa; `scripts/lab-down.sh` derruba tudo.

## Metasploitable 2 (semana 2, opcional)

Alvo clássico, cheio de serviços vulneráveis, ótimo para o nmap ter o que encontrar. Vem como disco VMware; converta para qcow2:

```bash
qemu-img convert -f vmdk -O qcow2 Metasploitable.vmdk /var/lib/libvirt/images/metasploitable.qcow2
sudo restorecon -v /var/lib/libvirt/images/metasploitable.qcow2
```

Importe como no doc 01 (`--os-variant generic`, 512 MB RAM, **rede `default`**). **Nunca** coloque essa VM em modo bridge na rede de casa.
