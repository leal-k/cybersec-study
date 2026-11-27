# nmap no meu laboratório

Escopo: **somente 192.168.122.0/24** (ver `lab/escopo.md`). Salvar toda saída em `scans/` com `-oA`.

## Parte 1: descoberta e portas (semana 2, segunda)

```bash
mkdir -p ~/cybersec-journey/scans && cd ~/cybersec-journey/scans

# 1. Quem está vivo na rede?
sudo nmap -sn 192.168.122.0/24 -oA 01-descoberta

# 2. Portas TCP mais comuns do host
nmap 192.168.122.1 -oA 02-host-top1000
```

### Experimento: `-sT` vs `-sS`, observado no Wireshark

Deixe o Wireshark capturando em `eth0` com filtro de exibição `ip.addr == 192.168.122.1 && tcp.port == 3000` e rode, um de cada vez:

```bash
nmap    -sT -p 3000 192.168.122.1   # connect scan: usa o connect() do sistema
sudo nmap -sS -p 3000 192.168.122.1 # SYN scan: pacotes crus, precisa de root
```

- Quantos pacotes cada um troca?
- Em qual deles o handshake se completa? Em qual o nmap manda **RST** logo depois do SYN-ACK?
- Por que um deles aparece no log da aplicação e o outro tende a não aparecer?
- Por que o `-sS` precisa de root?

## Parte 2: serviços e profundidade (semana 2, terça)

```bash
# 3. Versão e scripts padrão na porta do Juice Shop
nmap -sV -sC -p 3000 192.168.122.1 -oA 03-juice-versao

# 4. Todas as 65535 portas
sudo nmap -p- --min-rate 1000 192.168.122.1 -oA 04-host-todas

# 5. UDP: o que o host oferece às VMs? (dica: quem distribui IP e resolve nomes?)
sudo nmap -sU --top-ports 20 192.168.122.1 -oA 05-host-udp

# 6. Se instalou o Metasploitable 2
sudo nmap -sV -sC -p- 192.168.122.<ip-do-alvo> -oA 06-metasploitable
```

## Conclusões

<!-- Para cada scan: o que encontrou, o que surpreendeu, o que pesquisaria a seguir. -->
