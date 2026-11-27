# Diário

Uma entrada por semana (e linhas curtas por sessão, se quiser). Formato:

```
## Semana N (dd/mm–dd/mm), ~X h
- Feito:
- Travei em:
- Aprendi:
- Próxima semana:
```

---

## Semana 1 (26/11–), ~3,5 h até agora

### Sessão 1: qui 26/11 → sex 27/11 (madrugada), ~3,5 h
- **Feito:**
  - Repositório `cybersec-study` criado e publicado no GitHub.
  - KVM/libvirt instalado e validado (`virt-host-validate`).
  - Imagem QEMU do Kali baixada, SHA256 conferido, VM `debiantesting` criada e atualizada, snapshot `limpo`.
  - Juice Shop recriado escutando só na rede das VMs (`192.168.122.1:3000`); acesso pelo Kali validado (teste positivo) e bloqueio pela rede de casa validado (teste negativo).
  - Descoberto e derrubado o stack do `testeTecnico` exposto em `0.0.0.0` (Postgres, Keycloak, MiniStack, Prometheus).
  - `lab-up.sh` corrigido e validado com `bash -x`.
- **Travei em:**
  - Ctrl+Z no `git push` (pausa, não cancela) e remote criado com o placeholder `SEU-USUARIO`.
  - Senha do Kali que parou de funcionar (`Authentication token manipulation error`).
  - Histórico divergente no Git depois de editar o README pelo site; resolvido com `git pull --rebase`.
  - Bug intermitente no `lab-up.sh`: `pipefail` + `grep -q` em pipe.
- **Aprendi:**
  - Fingerprint SSH na primeira conexão = defesa contra MITM.
  - Hash da página prova integridade, não autenticidade; GPG prova autenticidade.
  - Acesso ao disco = acesso ao sistema (por isso existe criptografia de disco).
  - Docker publica portas em todas as interfaces por padrão e pode passar por cima do firewalld.
  - Teste positivo + teste negativo para validar isolamento.
- **Próxima sessão:** Bandit 0→5 e/ou Wireshark capturando o login no Juice Shop.