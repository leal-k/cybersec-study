# Escopo do laboratório

Hábito de bug bounty desde o dia 1: antes de atacar qualquer coisa, saber exatamente o que está dentro e fora.

## Dentro do escopo

| Alvo | Endereço | Observação |
|---|---|---|
| Rede de VMs libvirt | 192.168.122.0/24 | rede NAT `default` |
| Host Fedora (só pela virbr0) | 192.168.122.1 | Juice Shop :3000, dnsmasq (DNS/DHCP da rede das VMs) |
| Metasploitable 2 | 192.168.122.y | quando instalado |
| OverTheWire Bandit | bandit.labs.overthewire.org:2220 | apenas o que o jogo pede; nada de scan no servidor |

## Fora do escopo

- A rede de casa (192.168.0.0/24 ou similar), o roteador, outros dispositivos.
- Qualquer rede de trabalho ou Wi-Fi público.
- Qualquer IP/domínio que não esteja na tabela acima.
- A rede de casa (192.168.1.0/24), o roteador, outros dispositivos.

## Antes de rodar um scan

Confirmar que o alvo começa com `192.168.122.` ou está listado acima. Na dúvida, não roda.
