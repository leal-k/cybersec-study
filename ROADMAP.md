# Roadmap

## Orçamento de tempo

| Dia | Tempo | Melhor uso |
|---|---|---|
| Segunda | 3 h | bloco de **montar/configurar** (coisas que precisam de foco contínuo) |
| Terça | 4 h | bloco **mais longo**: exercício principal da semana + nota escrita |
| Quinta | 3 h | bloco de **prática + documentação** |
| Madrugadas curtas | 30–60 min | **Bandit**: 1–2 níveis por sessão, e leitura de `man` |

Total: ~15–20 h/semana. Regra: nenhuma sessão termina sem um commit, nem que seja uma linha no `LOG.md`.

---

## Fase 1: Laboratório, Linux e redes (semanas 1–2)

### Semana 1

| Sessão | Tarefa | Entrega |
|---|---|---|
| Seg (3 h) | KVM/libvirt no Fedora, importar a imagem QEMU do Kali, atualizar, criar snapshot `limpo` | `lab/01-kali-vm-fedora.md` revisado com o que deu diferente |
| Ter (4 h) | Rede do lab: Juice Shop exposto só na rede da VM, Kali acessando. Escrever `lab/escopo.md`. Bandit 0→5 | `lab/02-rede-do-lab.md`, primeiro commit grande |
| Qui (3 h) | Wireshark: capturar o meu login no Juice Shop, ver handshake TCP, abrir o JWT | `notes/redes/wireshark-login-juice-shop.md` |
| Madrugadas | Bandit, 1–2 níveis por sessão | `notes/linux/bandit.md` |

### Semana 2

| Sessão | Tarefa | Entrega |
|---|---|---|
| Seg (3 h) | nmap: descoberta de hosts, portas, `-sT` vs `-sS` **observados no Wireshark** | `notes/redes/nmap-lab.md` (parte 1), `scans/` |
| Ter (4 h) | Metasploitable 2 como alvo (opcional), `-sV`, `-sC`, `-p-`, UDP | `notes/redes/nmap-lab.md` (parte 2) |
| Qui (3 h) | Bandit até ~15–20, revisão da fase, organizar repo, `LOG.md` | README com status atualizado |
| Madrugadas | Bandit | |

### Critério de "fase concluída"

- [ ] Consigo recriar o lab do zero só lendo `lab/`.
- [ ] Sei explicar, sem consultar, o que acontece num handshake TCP e por que HTTP expõe a senha.
- [ ] Sei a diferença entre `-sS` e `-sT` porque **vi** no Wireshark.
- [ ] Bandit até pelo menos o nível 15, com notas de método.

---

## Fase 2: Web (semanas 3–8)

PortSwigger Web Security Academy (trilha Apprentice primeiro) + desafios do Juice Shop no mesmo tema da semana. Ordem sugerida: SQLi → autenticação → controle de acesso/IDOR → XSS → CSRF → SSRF → lógica de negócio. Um write-up por semana no mínimo, usando `templates/writeup.md`.

## Fase 3: CTF e máquinas

picoCTF (pontos fortes: cripto/forense; pontos fracos: web/pwn) → TryHackMe → Hack The Box (write-ups só de máquinas **retiradas**).

## Fase 4: Bug bounty

Ler relatórios públicos (HackerOne Hacktivity, write-ups), escolher programas VDP com escopo amplo, primeiro relatório.
