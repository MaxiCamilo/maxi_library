import os
import re
import json
import sys

def buscar_textos_en_archivos(directorio, archivo_salida):
    # Patrones para tr() y trc()
    patron_tr = r'tr\((.*?)\)'
    patron_trc = r'trc\((.*?)\)'

    # Diccionario para almacenar las coincidencias
    resultados = {}

    for root, dirs, files in os.walk(directorio):
        for file in files:
            if file.endswith('.dart'):
                ruta_archivo = os.path.join(root, file)
                with open(ruta_archivo, 'r', encoding='utf-8') as f:
                    contenido = f.read()

                    # Buscar tr()
                    coincidencias_tr = re.findall(patron_tr, contenido)
                    for coincidencia in coincidencias_tr:
                        texto = coincidencia.strip().strip("'\"")
                        resultados[texto] = ""

                    # Buscar trc()
                    coincidencias_trc = re.findall(patron_trc, contenido)
                    for coincidencia in coincidencias_trc:
                        # Extraer solo el texto entre comillas simples
                        textos_trc = re.findall(r"'(.*?)'", coincidencia)
                        for texto in textos_trc:
                            resultados[texto] = ""

    # Guardar resultados en archivo JSON
    with open(archivo_salida, 'w', encoding='utf-8') as json_file:
        json.dump(resultados, json_file, ensure_ascii=False, indent=4)

# Cambia 'tu_directorio' y 'archivo_salida.json' según tus necesidades


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python script.py <directorio>")
    else:
        directorio = sys.argv[1]
        buscar_textos_en_archivos(directorio, 'archivo_salida.json')