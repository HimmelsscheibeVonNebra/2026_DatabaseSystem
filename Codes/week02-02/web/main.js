"use strict";
// Week 02: SQLite in browser memory.
// Open index.html, select ../test.db, and run SQL. Internet access is required.
// main.js is the compiled browser entry point; browsers do not execute TypeScript.
// Rebuild: npx --yes --package typescript@5.9.3 tsc main.ts --target ES2020 --module none --lib ES2020,DOM --strict
const fileInput = document.querySelector('#database');
const editor = document.querySelector('#sql');
const runButton = document.querySelector('#run');
const resetButton = document.querySelector('#reset');
const statusElement = document.querySelector('#status');
const resultsElement = document.querySelector('#results');
const tablesElement = document.querySelector('#tables');
const fileNameElement = document.querySelector('#file-name');
const examples = document.querySelectorAll('[data-example]');
let runtime;
let database;
let originalBytes;
const queries = {
    all: 'SELECT * FROM student ORDER BY id;',
    filter: "SELECT id, name, tot_cred\nFROM student\nWHERE dept_name = 'Computer Science'\nORDER BY id;",
    join: 'SELECT s.name, c.title, e.grade\nFROM student AS s\nJOIN enroll AS e ON s.id = e.student_id\nJOIN course AS c ON c.code = e.course_code\nORDER BY s.id, c.code;',
    update: '-- Only the in-memory copy changes. Use Reset memory to undo.\nUPDATE student SET tot_cred = 38 WHERE id = 1003;\nSELECT * FROM student WHERE id = 1003;'
};
function setStatus(message, error = false) {
    statusElement.textContent = message;
    statusElement.dataset.error = String(error);
}
// File bytes become a new SQLite database in WASM memory, not a writable file handle.
function openMemoryDatabase(bytes) {
    const candidate = new runtime.Database(bytes.slice());
    try {
        candidate.exec('PRAGMA foreign_keys = ON;');
        candidate.exec('SELECT name FROM sqlite_schema;');
    }
    catch (error) {
        candidate.close();
        throw error;
    }
    database?.close();
    database = candidate;
    runButton.disabled = resetButton.disabled = false;
    examples.forEach(button => { button.disabled = false; });
    resultsElement.replaceChildren();
    refreshTables();
}
function refreshTables() {
    tablesElement.replaceChildren();
    const rows = database?.exec("SELECT name FROM sqlite_schema WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name;")[0]?.values ?? [];
    for (const [value] of rows) {
        const name = String(value);
        const button = document.createElement('button');
        button.textContent = name;
        button.addEventListener('click', () => {
            // Quote identifiers so even table names containing quotes are handled safely.
            editor.value = `SELECT * FROM "${name.replace(/"/g, '""')}" LIMIT 200;`;
            runQuery();
        });
        tablesElement.append(button);
    }
}
// Render values as text, never HTML. NULL is distinct from an empty string.
function renderResults(results) {
    resultsElement.replaceChildren();
    results.forEach((result, index) => {
        const section = document.createElement('section');
        section.className = 'result';
        const title = document.createElement('h3');
        title.textContent = `Result ${index + 1} / ${result.values.length} rows`;
        const table = document.createElement('table');
        const header = table.createTHead().insertRow();
        result.columns.forEach(column => {
            const cell = document.createElement('th');
            cell.scope = 'col';
            cell.textContent = column;
            header.append(cell);
        });
        const body = table.createTBody();
        // Limit DOM size for readability. SQL itself runs fully; use small lab queries.
        result.values.slice(0, 200).forEach(values => {
            const row = body.insertRow();
            values.forEach(value => {
                const cell = row.insertCell();
                cell.textContent = value === null ? 'NULL' : value instanceof Uint8Array ? `[BLOB: ${value.length} bytes]` : String(value);
                if (value === null)
                    cell.className = 'null';
            });
        });
        section.append(title, table);
        if (result.values.length > 200) {
            const note = document.createElement('p');
            note.textContent = 'Showing the first 200 rows. Add LIMIT to restrict your query.';
            section.append(note);
        }
        resultsElement.append(section);
    });
}
function runQuery() {
    if (!database)
        return;
    if (!editor.value.trim()) {
        setStatus('Enter a SQL statement first.', true);
        return;
    }
    try {
        const results = database.exec(editor.value);
        renderResults(results);
        refreshTables();
        setStatus(results.length ? `Executed / ${results.length} result sets. Original file unchanged.` : 'Executed / no result rows returned. Original file unchanged.');
    }
    catch (error) {
        resultsElement.replaceChildren();
        setStatus(`${String(error)}. Earlier statements may have run. Reset memory to start over.`, true);
    }
}
fileInput.addEventListener('change', async () => {
    const file = fileInput.files?.[0];
    if (!file)
        return;
    fileInput.disabled = true;
    resetButton.disabled = runButton.disabled = true;
    try {
        const bytes = new Uint8Array(await file.arrayBuffer());
        openMemoryDatabase(bytes);
        originalBytes = bytes;
        fileNameElement.textContent = `${file.name} / ${(file.size / 1024).toFixed(1)} KB`;
        setStatus('Database loaded into memory. Choose a table or run your SQL.');
    }
    catch (error) {
        setStatus(`Could not open database: ${String(error)}`, true);
    }
    finally {
        fileInput.disabled = false;
        resetButton.disabled = runButton.disabled = !database;
        fileInput.value = '';
    }
});
resetButton.addEventListener('click', () => {
    if (!originalBytes)
        return;
    try {
        openMemoryDatabase(originalBytes);
        setStatus('Memory reset to the selected file\'s original data.');
    }
    catch (error) {
        setStatus(String(error), true);
    }
});
runButton.addEventListener('click', runQuery);
editor.addEventListener('keydown', event => {
    if ((event.ctrlKey || event.metaKey) && event.key === 'Enter') {
        event.preventDefault();
        if (!runButton.disabled)
            runQuery();
    }
});
examples.forEach(button => button.addEventListener('click', () => {
    editor.value = queries[button.dataset.example];
    editor.focus();
}));
async function initialize() {
    try {
        runtime = await initSqlJs({ locateFile: file => `https://cdn.jsdelivr.net/npm/sql.js@1.13.0/dist/${file}` });
        fileInput.disabled = false;
        setStatus('SQLite ready. Select test.db to begin.');
    }
    catch (error) {
        setStatus(`SQLite could not load. Check your internet connection and refresh. ${String(error)}`, true);
    }
}
void initialize();
