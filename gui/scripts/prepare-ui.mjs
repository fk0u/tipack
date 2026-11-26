// Salin data katalog, ikon dan logo dari web/ ke gui/ui supaya aplikasi GUI memakai data yang sama dengan website.
import { cpSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const ui = join(root, 'gui', 'ui');
mkdirSync(join(ui, 'data'), { recursive: true });
cpSync(join(root, 'web', 'catalog.json'), join(ui, 'data', 'catalog.json'));
cpSync(join(root, 'web', 'icons'), join(ui, 'icons'), { recursive: true });
cpSync(join(root, 'web', 'brand', 'logo.svg'), join(ui, 'logo.svg'));
console.log('ui disiapkan: catalog.json, icons/, logo.svg');
