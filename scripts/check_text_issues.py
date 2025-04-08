"""
Dieses Programm führt mehrere Prüfungen auf einer angegebenen Datei durch:

1. Überprüfung auf nachgestellte Leerzeichen oder Tabs am Ende von Zeilen.
2. Überprüfung auf doppelte deutsche Artikel (z. B. "der der", "die die", "das das").
3. Überprüfung auf unterbrochene Markdown-Links, bei denen der Linktext in eckigen Klammern über Zeilenumbrüche verteilt ist.

Usage: python3 check_text_issues.py <filename>
# Beispiel: vollständiger Pfad für das Skript und die Markdown-Datei -> python3 /home/tower/projekt/github/oss-work/bitcoinops.github.io/scripts/check_text_issues.py /home/tower/projekt/github/oss-work/bitcoinops.github.io/_posts/de/newsletters/2025-04-04-newsletter.md
"""

import sys
import re

def check_trailing_whitespace(filename):
    count = 0
    with open(filename, encoding='utf-8') as file:
        for lineno, line in enumerate(file, start=1):
            # Überprüfe, ob die Zeile ein oder mehrere Leerzeichen oder Tabs vor dem Zeilenumbruch hat.
            if re.search(r"[ \t]+$", line):
                print(f"[Trailing Whitespace] Zeile {lineno}: {repr(line)}")
                count += 1
    if count:
        print(f"\n[Info] Gesamt: {count} Zeile(n) mit nachgestellten Leerzeichen gefunden.")
    else:
        print("[Info] Es wurden keine Zeilen mit nachgestellten Leerzeichen gefunden.")

def check_duplicate_articles(filename):
    pattern = re.compile(r'\b(der|die|das)\s+\1\b', re.IGNORECASE)
    count = 0
    with open(filename, encoding='utf-8') as file:
        for lineno, line in enumerate(file, start=1):
            if pattern.search(line):
                print(f"[Duplicate Articles] Zeile {lineno}: {repr(line)}")
                count += 1
    if count:
        print(f"\n[Info] Gesamt: {count} Zeile(n) mit doppelten Artikeln gefunden.")
    else:
        print("[Info] Es wurden keine doppelten Artikel gefunden.")

def check_broken_links(filename):
    with open(filename, encoding='utf-8') as file:
        content = file.read()
    # Suche nach [ ... \n ... ] (also Linktexte, die einen Zeilenumbruch enthalten)
    pattern = re.compile(r'\[[^\]\n]*\n[^\]]*\]')
    matches = list(pattern.finditer(content))
    if matches:
        print("\n[Broken Links] Folgende Markdown-Links sind über Zeilenumbrüche verteilt:")
        for match in matches:
            lineno = content[:match.start()].count('\n') + 1
            snippet = match.group().replace('\n', '\\n')
            print(f"Zeile {lineno}: {snippet}")
        print(f"\n[Info] Insgesamt {len(matches)} Link(s) gefunden, die Zeilenumbrüche enthalten.")
    else:
        print("\n[Info] Es wurden keine unterbrochenen Markdown-Links gefunden.")

def main(filename):
    print(f"[Info] Starte Prüfungen in der Datei: {filename}\n")
    check_trailing_whitespace(filename)
    print("\n" + "-" * 50 + "\n")
    check_duplicate_articles(filename)
    print("\n" + "-" * 50 + "\n")
    check_broken_links(filename)
    print("\n[Info] Prüfungen abgeschlossen.")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python check_text_issues.py <filename>")
        sys.exit(1)
    main(sys.argv[1])