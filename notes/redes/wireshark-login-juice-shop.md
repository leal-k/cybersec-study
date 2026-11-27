# Wireshark: capturando meu próprio login no Juice Shop

**Objetivo:** ver com os próprios olhos o que viaja na rede quando alguém faz login numa aplicação HTTP sem TLS.

## Preparação (no Kali)

```bash
sudo usermod -aG wireshark kali   # capturar sem rodar a interface como root; sair e entrar
wireshark &
```

1. No Juice Shop (`http://192.168.122.1:3000`), **registre um usuário de teste** com uma senha descartável.
2. Faça logout.
3. No Wireshark, comece a captura na interface `eth0` com o **filtro de captura** `tcp port 3000`.
4. Faça login. Pare a captura.

## O que investigar

### 1. Handshake TCP
Filtro de exibição: `tcp.flags.syn == 1`

- Identifique SYN → SYN-ACK → ACK. Quais portas de origem e destino?
- Os números de sequência (Wireshark mostra relativos; veja os absolutos também).

### 2. A requisição de login
Filtro: `http.request.method == "POST"`

- Ache o `POST /rest/user/login`. Botão direito → *Follow* → *HTTP Stream*.
- O e-mail e a senha aparecem? Em que formato?

### 3. A resposta e o token
- A resposta traz um `token`. É um **JWT**: três partes separadas por ponto, em base64url.
- Decodifique o header e o payload no terminal:
  ```bash
  echo '<parte>' | tr '_-' '/+' | base64 -d 2>/dev/null; echo
  ```
  (pode faltar `=` de padding no final; adicione até funcionar)
- **Perguntas para quem é de cripto:** que algoritmo de assinatura o header declara? O que tem dentro do payload? Algum campo parece um hash? Que tipo de hash, e o que isso permitiria a quem interceptasse o token?

### 4. ARP
Filtro: `arp`. Como o Kali descobriu o MAC de 192.168.122.1?

## Respostas e conclusões

<!-- Escrever aqui. Inclua prints com a senha borrada. O .pcap NÃO vai pro Git. -->

- O que um atacante na mesma rede veria:
- O que o HTTPS mudaria (e o que ele **não** mudaria):
- Achado(s) sobre o JWT:
