# Schreibe ein Bash-Skript `backup.sh`, das:
# - ein Verzeichnis (`./data`) zippt,
# - das Archiv mit Zeitstempel versieht (z. B. `backup_2025-08-08.zip`) und
# - es in einen Ordner `./backups` verschiebt.

#!/bin/bash

# Definiere Konstanten
SOURCE_DIR="./data"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="backup_${TIMESTAMP}.zip"

# Funktion zur Prüfung der Zugriffsrechte
check_permissions() {
    local dir=$1
    if [ ! -r "$dir" ]; then
        echo "FEHLER: Keine Leserechte für '$dir'"
        return 1
    fi
    if [ ! -w "$dir" ]; then
        echo "FEHLER: Keine Schreibrechte für '$dir'"
        return 1
    fi
    return 0
}

# Hauptprogramm mit Fehlerbehandlung
main() {
    # aufm root?
    if [ "$EUID" -eq 0 ]; then
        echo "WARNUNG: Dieses Skript sollte nicht als root ausgeführt werden!"
        exit 1
    }

    # Quellordner existiert?
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "FEHLER: Quellordner '$SOURCE_DIR' existiert nicht!"
        exit 1
    fi

    # Quellordner leer?
    if [ -z "$(ls -A $SOURCE_DIR)" ]; then
        echo "FEHLER: Quellordner '$SOURCE_DIR' ist leer!"
        exit 1
    fi

    # Zugriffsrechte für Quellordner?
    if ! check_permissions "$SOURCE_DIR"; then
        exit 1
    fi

    # Versuche Backup-Verzeichnis zu erstellen, fals nicht vorhanden
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Backup-Verzeichnis wird erstellt..."
        if ! mkdir -p "$BACKUP_DIR"; then
            echo "FEHLER: Konnte Backup-Verzeichnis nicht erstellen!"
            exit 1
        fi
    fi

    # Prüfe Zugriffsrechte für Backup-Verzeichnis
    if ! check_permissions "$BACKUP_DIR"; then
        exit 1
    fi

    # Prüfe verfügbaren Speicherplatz
    required_space=$(du -s "$SOURCE_DIR" | awk '{print $1}')
    available_space=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
    if [ "$required_space" -gt "$available_space" ]; then
        echo "FEHLER: Nicht genügend Speicherplatz verfügbar!"
        exit 1
    fi

    # Erstelle Backup
    echo "Starte Backup-Erstellung..."
    if zip -r "$BACKUP_DIR/$BACKUP_NAME" "$SOURCE_DIR" 2>/dev/null; then
        # war es erfolgreich?
        if [ -f "$BACKUP_DIR/$BACKUP_NAME" ]; then
            # Prüfe die Zip-Datei
            if unzip -t "$BACKUP_DIR/$BACKUP_NAME" &>/dev/null; then
                echo "Backup erfolgreich erstellt: $BACKUP_NAME"
                echo "Speicherort: $BACKUP_DIR/$BACKUP_NAME"
                echo "Backup-Größe: $(du -h "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)"
            else
                echo "FEHLER: Backup-Datei ist beschädigt!"
                rm -f "$BACKUP_DIR/$BACKUP_NAME"
                exit 1
            fi
        else
            echo "FEHLER: Backup-Datei wurde nicht erstellt!"
            exit 1
        fi
    else
        echo "FEHLER: Zip-Prozess fehlgeschlagen!"
        # Lösche unvollständige Backup-Datei falls vorhanden
        rm -f "$BACKUP_DIR/$BACKUP_NAME"
        exit 1
    fi

}

# gib ihm Zucker
main
exit 0
