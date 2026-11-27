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

Anote aqui qual caminho funcionou e por quê.

## Scripts

`scripts/lab-up.sh` sobe rede, Juice Shop e Kali na ordem certa; `scripts/lab-down.sh` derruba tudo.

## Metasploitable 2 (semana 2, opcional)

Alvo clássico, cheio de serviços vulneráveis, ótimo para o nmap ter o que encontrar. Vem como disco VMware; converta para qcow2:

```bash
qemu-img convert -f vmdk -O qcow2 Metasploitable.vmdk /var/lib/libvirt/images/metasploitable.qcow2
sudo restorecon -v /var/lib/libvirt/images/metasploitable.qcow2
```

Importe como no doc 01 (`--os-variant generic`, 512 MB RAM, **rede `default`**). **Nunca** coloque essa VM em modo bridge na rede de casa.
