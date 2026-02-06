const fs = require('fs');
const i18n1 = JSON.parse(fs.readFileSync('./scripts/i18n.json'));
const i18n2 = JSON.parse(fs.readFileSync('./scripts/i18n.2.json'));
const i18n = {};

const textEncoder = new TextEncoder();

for (const lang in i18n1) {
    if (lang === '_metadata') {
        continue;
    }
    const data = Object.assign(i18n1[lang], i18n2[lang] || {});
    i18n[lang] = data;
}

let text = JSON.stringify(i18n, null, 4);
text = text.replace(/^\{/, 'return {').replace(/^(\s*)("[^"]+"):/mg, '$1[$2] =');

const bufview = textEncoder.encode(text);
fs.writeFileSync('./data/messages.lua', bufview);
