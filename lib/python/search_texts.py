import os
import re

def buscar_textos_tr_trc(directorio):
    # Expresiones regulares para encontrar los textos dentro de tr() y trc()
    patron_tr = re.compile(r'tr\("([^"]+)"\)')
    patron_trc = re.compile(r'trc\("([^"]+)"\)')

    # Recorrer todos los archivos en el directorio
    for root, _, files in os.walk(directorio):
        for file in files:
            if file.endswith(".dart"):
                ruta_archivo = os.path.join(root, file)
                with open(ruta_archivo, 'r', encoding='utf-8') as f:
                    contenido = f.read()

                    # Buscar y mostrar los textos encontrados en tr() y trc()
                    textos_tr = patron_tr.findall(contenido)
                    textos_trc = patron_trc.findall(contenido)

                    if textos_tr or textos_trc:
                        print(f"\nArchivo: {ruta_archivo}")
                        for texto in textos_tr:
                            print(f"tr(): {texto}")
                        for texto in textos_trc:
                            print(f"trc(): {texto}")

# Especificar el directorio donde buscar los archivos .dart
directorio = '/ruta/al/directorio'
buscar_textos_tr_trc(directorio)