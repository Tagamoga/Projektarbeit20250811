# Erstelle eine Python-Datei `json_sorter.py`, die:
# - eine Datei `data.json` lädt (enthält ein Array von Objekten),
# - nach einem bestimmten Feld (z. B. "name") sortiert und
# - das Ergebnis in `sorted.json` speichert.

import json
import os
from typing import List, Dict
from pathlib import Path

# Sortiert JSON-Daten nach einem bestimmten Feldnamen und speichert das Ergebnis.
def sortiere_json_daten(feldname: str, input_datei: str = "data.json", output_datei: str = "sorted.json") -> None:

    try:
        # gibt es die Datendatei?
        if not Path(input_datei).is_file():
            raise FileNotFoundError(f"Die Datei '{input_datei}' wurde nicht gefunden.")

        # Darfst Du die lesen?
        if not os.access(input_datei, os.R_OK):
            raise PermissionError(f"Keine Leserechte für die Datei '{input_datei}'.")

        # Darfst Du schreiben, wo Du gerade willst?
        output_path = Path(output_datei)
        if not os.access(output_path.parent, os.W_OK):
            raise PermissionError(f"Keine Schreibrechte im Verzeichnis für '{output_datei}'.")

        # Daten einlsen
        with open(input_datei, 'r', encoding='utf-8') as f:
            try:
                daten: List[Dict] = json.load(f)
            except json.JSONDecodeError:
                raise json.JSONDecodeError(f"Die Datei '{input_datei}' enthält kein gültiges JSON-Format.", "", 0)

        # Ist es ein Array?
        if not isinstance(daten, list):
            raise TypeError("Die JSON-Datei muss ein Array von Objekten enthalten.")

        # Ist die Liste leer
        if not daten:
            raise ValueError("Die JSON-Datei enthält keine Daten.")

        # Ist der Feldname in allen Objekten existent
        if not all(feldname in item for item in daten):
            raise KeyError(f"Der Feldname '{feldname}' existiert nicht in allen Objekten.")

        # endlich sortieren
        sortierte_daten = sorted(daten, key=lambda x: x[feldname])

        # Dump out!
        with open(output_datei, 'w', encoding='utf-8') as f:
            json.dump(sortierte_daten, f, indent=2, ensure_ascii=False)

        # Freue Dich und jubel
        print(f"Daten wurden erfolgreich nach '{feldname}' sortiert und in '{output_datei}' gespeichert.")

    except FileNotFoundError as e:
        print(f"Fehler: {e}")
    except PermissionError as e:
        print(f"Fehler: {e}")
    except json.JSONDecodeError as e:
        print(f"Fehler beim Lesen der JSON-Datei: {e}")
    except KeyError as e:
        print(f"Fehler: {e}")
    except TypeError as e:
        print(f"Fehler: {e}")
    except ValueError as e:
        print(f"Fehler: {e}")
    except Exception as e:
        print(f"Ein unerwarteter Fehler ist aufgetreten: {e}")


if __name__ == "__main__":
    sortiere_json_daten("Name")         # Sortierung nach Name
    # sortiere_json_daten("Nachname")   # Sortierung nach Nachname
    # sortiere_json_daten("PLZ")        # Sortierung nach PLZ
    # sortiere_json_daten("Mumpitz!")   # Soll einen Fehler werfen.

# Anmerkung:    Das Sortieren nach dem Index ist nicht sinnvoll, da der Index in unterschiedlichen Elementen, unterschiedliche
#               Elemente ansprechen kann. JSON ist nicht immer "stabil" einer Ebene und kann die Reihenfolge ändern.
