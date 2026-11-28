# OverTheWire: Bandit

Jogo: <https://overthewire.org/wargames/bandit/> (crédito à comunidade OverTheWire).

```bash
ssh bandit0@bandit.labs.overthewire.org -p 2220
```

> **Regra do OverTheWire:** write-ups são permitidos, **credenciais não**. As senhas ficam num gerenciador de senhas ou num arquivo fora do repositório (ex.: `~/.local/share/bandit/senhas.txt`), nunca aqui.

## Como anotar cada nível

Não copiar a solução; registrar o **raciocínio**. Formato curto:

```markdown
### Nível N → N+1
- **Pedido:** o que o enunciado quer, nas minhas palavras
- **Tentei:** o que não funcionou e por quê
- **Resolvi com:** comando(s), sem a senha
- **Aprendi:** conceito (ex.: "nome de arquivo começando com '-' é lido como opção")
```

Se travar mais de 30 min, ler só a seção *Commands you may need* e o `man` dos comandos sugeridos antes de procurar dica.

## Meta da fase 1

Níveis 0 → 15 no mínimo (até ~20 se render). Os níveis 0–12 cobrem navegação, arquivos ocultos, `find`, `grep`, `sort | uniq`, `strings`, `base64`, `tr`, `xxd` e arquivos compactados. Os seguintes entram em SSH com chave, `nc`, `openssl s_client` e `nmap`, e conectam direto com a parte de redes.

## Níveis

### Nível 0 → 1
- **Pedido:** The password for the next level is stored in a file called readme located in the home directory.
- **Tentei:** Após as boas vindas, dei um `ls` e vi um readme. Dei um `nano readme` e abri o arquivo com sucesso.
- **Resolvi com:** `ls` e `nano readme`
- **Aprendi:** `~` é a home; `nano` abre um documento no editor de texto e `cat` mostra o conteúdo do arquivo.

### Nível 1 → 2
- **Pedido:** The password for the next level is stored in a file called - located in the home directory
- **Tentei:** Tentei `ls` e vi que o arquivo chamava `-` apenas. Tentei `nano -` mas não funcionou. O - abre a leitura de entrada de dados pelo teclado. 
- **Resolvi com:** Usei o diretório no comando para conseguir abrir o documento, para evitar a leitura de dados pelo teclado. `cat ~/-` 
- **Aprendi:** Comandos com - geralmente abrem um tipo de stdin para receber dados. Quando o arquivo tem um nome problemático assim, há maneiras de contornar, por exemplo, usando o diretório.

### Nível 2 → 3
- **Pedido:** The password for the next level is stored in a file called --spaces in this filename-- located in the home directory
- **Tentei:** Tentei novamente o `cat --spaces in this filename--` e deu erro. 
- **Resolvi com:** Usei a mesma estratégia do nível anterior, usar o diretório como comando: `cat ~/--spaces\ in\ this\ filename--`, usandos barras invertidas como auxílio pra simbolizar o espaço..
- **Aprendi:** Usar barra invertida para acessar documentos com espaços.

### Nível 3 → 4
- **Pedido:** The password for the next level is stored in a hidden file in the inhere directory.
- **Tentei:** Tentei visualizar a pasta com `ls` normal e não funcionou.
- **Resolvi com:** Utilizei `ls -A` para listar os documentos escondidos. Uma vez que achei o nome do doc, um `cat` simples me mostrou a chave.
- **Aprendi:** Utilizar `-A` para listar tudo que está no diretório, mesmo escondido ele aparece.
