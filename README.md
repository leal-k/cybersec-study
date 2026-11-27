# cybersec-study

Meu caminho de estudo em segurança ofensiva, do básico ao bug bounty, documentado em público.

**Contexto:** formando em Ciência da Computação, com experiência em backend e QA. Já tenho base de redes, segurança e auditoria de TI, e de criptografia/forense em CTF. Agora estou estudando Linux, redes na prática e web.

> ⚠️ **Ética e escopo.** Tudo aqui é feito contra o **meu próprio laboratório** ou contra plataformas que autorizam explicitamente (OverTheWire, PortSwigger, picoCTF, TryHackMe, HTB, programas de bug bounty/VDP dentro do escopo publicado). Nada de scan ou teste em sistemas de terceiros sem autorização.

## Roadmap

| Fase | Período | Foco | Status |
|---|---|---|---|
| 1 | Semanas 1–2 | Laboratório (Kali em KVM), Linux (Bandit), redes (Wireshark, nmap) | 🟡 em andamento |
| 2 | Semanas 3–8 | Web: PortSwigger Web Security Academy + OWASP Juice Shop | ⚪ |
| 3 | Depois | picoCTF, TryHackMe, Hack The Box | ⚪ |
| 4 | Por último | Bug bounty: leitura de relatórios, programas VDP | ⚪ |

Detalhes e agenda em [`ROADMAP.md`](ROADMAP.md). Diário semanal em [`LOG.md`](LOG.md).

## Estrutura

```
lab/                 como o laboratório foi montado (reproduzível)
  01-kali-vm-fedora.md
  02-rede-do-lab.md
  escopo.md          o que posso e não posso atacar
notes/
  linux/bandit.md    notas do OverTheWire Bandit (sem senhas)
  redes/             Wireshark, nmap
writeups/            write-ups de desafios (PortSwigger, Juice Shop, CTFs)
scans/               saídas do nmap do MEU lab
scripts/             automações do lab (subir/derrubar)
templates/           modelo de write-up
```

## Regras que sigo neste repositório

- **Sem credenciais.** Não publico senhas do OverTheWire (regra deles) nem flags de máquinas ativas do HTB (proibido nos termos de uso). Publico o método.
- **Sem capturas cruas.** Arquivos `.pcap` ficam fora do Git (`.gitignore`) porque contêm senhas, mesmo as de laboratório.
- **Crédito.** Cada write-up linka a plataforma de origem.
