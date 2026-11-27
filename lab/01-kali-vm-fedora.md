# 01: Kali Linux em VM no Fedora (KVM/libvirt)

## Por que KVM e não VirtualBox

No Fedora, o KVM já vem no kernel e o `virt-manager` está nos repositórios oficiais. O VirtualBox exige módulo de kernel externo, que quebra com atualização de kernel e complica com Secure Boot. O Kali publica uma **imagem QEMU pronta**, então não precisa instalar do ISO.

## 1. Conferir suporte a virtualização

```bash
grep -Ec '(vmx|svm)' /proc/cpuinfo   # > 0 = CPU suporta (vmx = Intel, svm = AMD)
```

Se der `0`, ative VT-x/AMD-V na BIOS/UEFI.

## 2. Instalar o grupo de virtualização

```bash
sudo dnf install @virtualization
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"     # usar o virsh sem sudo; precisa sair e entrar na sessão
virt-host-validate qemu              # tudo deve dar PASS (WARN de IOMMU pode ignorar)
```

Conferir a rede NAT padrão (`default`, interface `virbr0`, 192.168.122.0/24):

```bash
virsh -c qemu:///system net-list --all
# se não estiver ativa:
virsh -c qemu:///system net-start default
virsh -c qemu:///system net-autostart default
```

## 3. Baixar e verificar a imagem do Kali

Em <https://www.kali.org/get-kali/#kali-virtual-machines>, baixe a imagem **QEMU** (arquivo `.7z`) e anote o SHA256 que aparece na página.

```bash
cd ~/Downloads
sha256sum kali-linux-*-qemu-amd64.7z   # tem que bater com o hash da página
sudo dnf install p7zip p7zip-plugins
7z x kali-linux-*-qemu-amd64.7z
```

> Verificar o hash não é burocracia: é a primeira prática de integridade do curso. Imagem de ferramenta ofensiva adulterada é um vetor real.

Mover o disco para o diretório do libvirt. **No Fedora isso importa por causa do SELinux:** um disco dentro de `~/Downloads` não tem o rótulo certo e a VM falha com "Permission denied".

```bash
sudo mv kali-linux-*-qemu-amd64.qcow2 /var/lib/libvirt/images/kali.qcow2
sudo restorecon -v /var/lib/libvirt/images/kali.qcow2
```

## 4. Criar a VM

**Pela interface:** `virt-manager` → *Novo* → *Importar imagem de disco existente* → `/var/lib/libvirt/images/kali.qcow2` → sistema: *Debian testing* → 4096 MB RAM, 2 vCPUs → rede: *NAT (default)* → nome `kali`.

**Pela linha de comando** (mesmo resultado, e fica registrado aqui):

```bash
virt-install --connect qemu:///system \
  --name kali \
  --memory 4096 --vcpus 2 \
  --disk /var/lib/libvirt/images/kali.qcow2,bus=virtio \
  --import --os-variant debiantesting \
  --network network=default \
  --graphics spice \
  --noautoconsole
virt-manager --connect qemu:///system --show-domain-console kali
```

## 5. Primeiro boot

Login padrão: `kali` / `kali`. Primeira coisa:

```bash
passwd                                   # trocar a senha padrão
sudo apt update && sudo apt full-upgrade -y
ip -br a                                 # anotar o IP (192.168.122.x)
ping -c 2 192.168.122.1                  # o host Fedora, visto de dentro da VM
```

Opcional, para copiar e colar entre host e VM: `sudo apt install -y spice-vdagent` e reiniciar.

## 6. Snapshot "limpo"

Desligue a VM e crie o ponto de restauração. Assim, se quebrar algo, você volta em segundos:

```bash
virsh -c qemu:///system shutdown kali
virsh -c qemu:///system snapshot-create-as kali limpo "Kali atualizado, senha trocada"
virsh -c qemu:///system snapshot-list kali
# para voltar: virsh -c qemu:///system snapshot-revert kali limpo
```

## O que deu diferente no meu caso

- **Repositório:** suspendi um `git push` com Ctrl+Z achando que cancelava (Ctrl+Z pausa; Ctrl+C cancela). Resolvido com `kill %1`. Também criei o remote com o texto de exemplo `SEU-USUARIO`; corrigido com `git remote set-url`.
- **Fingerprint do GitHub:** na primeira conexão SSH, conferi o fingerprint ED25519 com o publicado na documentação do GitHub antes de responder `yes`. É a defesa contra man-in-the-middle na primeira conexão.
- **`virt-host-validate`:** dois WARN inofensivos:
  - `cgroup 'devices'`: falso alarme no cgroups v2 (Fedora); o controle de dispositivos é feito via eBPF e o libvirt cuida disso.
  - `Secure Guest support`: computação confidencial (AMD SEV / Intel TDX), irrelevante num host próprio.
- **Hash e assinatura do Kali:** o SHA256 fica atrás de um botão ao lado do download na get-kali; conferi e bateu (integridade). Depois verifiquei a autenticidade com GPG:
  - `SHA256SUMS` e `SHA256SUMS.gpg` baixados de `cdimage.kali.org/current/`, que **redirecionou para um mirror no Equador** (`mirror.cedia.org.ec`). Isso mostra por que o hash da página não basta: os arquivos vêm de servidores de terceiros.
  - Chave `827C 8569 F251 8CC6 77FE CA1A ED65 462E C8D5 E4C5` conferida → `Good signature` → `kali-linux-2026.3-qemu-amd64.7z: OK`.
  - O aviso `This key is not certified with a trusted signature` é esperado: eu não assinei a chave do Kali com uma chave minha; quem garante a autenticidade é a conferência da impressão digital.
  - Pegadinha: `grep nome.7z` também casa com `nome.7z.torrent`. Ancorar com `$`.
- **Nome da VM:** criei pelo virt-manager e ficou `debiantesting`, não `kali`. Ajustei o padrão nos scripts. Para listar VMs: `virsh -c qemu:///system list --all`.
- **Senha perdida:** a senha nova parou de funcionar; `passwd` dava `Authentication token manipulation error`, que significa senha atual não reconhecida. Redefini para uma senha simples, aceitável só porque a VM está em NAT e sem SSH ligado. Lição: com acesso ao disco (`virt-customize`, GRUB), dá para trocar a senha sem saber a atual. Por isso existe criptografia de disco.
- **Snapshot:** recriei o `limpo` depois de redefinir a senha, com a VM desligada.
