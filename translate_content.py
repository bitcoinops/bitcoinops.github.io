import os
import re
import sys
import deepl
from pathlib import Path

def extract_frontmatter_and_content(file_content):
    """Extrahiert Front Matter und Content aus einer Markdown-Datei."""
    parts = re.split(r'^---\s*$', file_content.strip(), maxsplit=2, flags=re.MULTILINE)
    if len(parts) < 3:
        return None, file_content
    return f"---\n{parts[1]}---\n", parts[2]

def translate_file(input_file, output_file, target_lang, auth_key):
    """Übersetzt den Inhalt einer Datei, behält aber Front Matter bei."""
    try:
        # DeepL Translator initialisieren
        translator = deepl.Translator(auth_key)
        
        # Datei einlesen
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Front Matter und Content trennen
        front_matter, main_content = extract_frontmatter_and_content(content)
        
        # Nur den Hauptinhalt übersetzen
        translated_content = translator.translate_text(
            main_content,
            target_lang=target_lang
        )
        
        # Front Matter anpassen (Sprache und Permalink)
        modified_front_matter = front_matter.replace(
            'lang: en',
            f'lang: {target_lang.lower()}'
        ).replace(
            '/en/',
            f'/{target_lang.lower()}/'
        )
        
        # Übersetzten Inhalt in neue Datei schreiben
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(modified_front_matter)
            f.write(str(translated_content))
            
        print(f"Übersetzung erfolgreich gespeichert in: {output_file}")
        
    except Exception as e:
        print(f"Fehler bei der Übersetzung: {str(e)}")

def main():
    if len(sys.argv) != 4:
        print("Verwendung: python translate_content.py <input_file> <target_lang> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    target_lang = sys.argv[2]
    output_file = sys.argv[3]
    
    # DeepL API Key aus Umgebungsvariable lesen
    auth_key = os.getenv('DEEPL_API_KEY')
    if not auth_key:
        print("DEEPL_API_KEY nicht gesetzt")
        sys.exit(1)

    translate_file(input_file, output_file, target_lang, auth_key)

if __name__ == "__main__":
    main() 