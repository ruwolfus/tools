import * as fs from 'fs';
import * as path from 'path';

// Pfad zur Input-Datei
const filePath = path.join(__dirname, 'input.txt');

// Funktion: Lesen, Substituieren und Überschreiben der Datei
function replaceInFile(filePath: string, searchValue: string, replaceValue: string): void {
  try {
    // Datei-Inhalt lesen
    const fileContent = fs.readFileSync(filePath, 'utf-8');

    // Inhalt bearbeiten
    const updatedContent = fileContent.replace(new RegExp(searchValue, 'g'), replaceValue);

    // Dateiname und Backup-Datei erstellen
    const backupFilePath = filePath + '.backup';
    fs.writeFileSync(backupFilePath, fileContent);
    console.log(`Backup erstellt: ${backupFilePath}`);

    // Aktualisierte Inhalte zurückschreiben
    fs.writeFileSync(filePath, updatedContent);
    console.log('Datei erfolgreich bearbeitet.');
  } catch (error) {
    // Typprüfung oder Typ-Zuweisung
    if (error instanceof Error) {
      console.error(`Fehler beim Bearbeiten der Datei: ${error.message}`);
    } else {
      console.error(`Unbekannter Fehler: ${error}`);
    }
  }
}

// Aufruf der Funktion
replaceInFile(filePath, 'test', 'testersatz');


