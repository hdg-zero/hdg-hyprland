const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { runInNewContext } = require('node:vm');
const { test } = require('node:test');
const assert = require('node:assert/strict');

const groups = {};
runInNewContext(readFileSync(join(__dirname,
    '../.config/quickshell/notifications/NotificationGroups.js'), 'utf8')
    .replace(/^\.pragma library\s*/, ''), groups);

function notification(id, appName, desktopEntry = '') {
    return { id, appName, desktopEntry, appIcon: '' };
}

test('regroupe par desktop entry malgré des noms différents et trie par réception', () => {
    const first = notification(1, 'Messages', 'chat');
    const latest = notification(2, 'Conversation privée', 'chat');
    const browser = notification(3, 'Firefox', 'firefox');
    const input = [first, latest, browser];
    const result = groups.groupNotifications(input, { 1: 1000, 2: 3000, 3: 2000 });
    assert.equal(result.length, 2);
    assert.equal(result[0].key, 'desktop:chat');
    assert.equal(result[0].notifications[0], latest);
    assert.equal(result[0].notifications[1], first);
    assert.equal(result[1].notifications[0], browser);
    assert.deepEqual(input, [first, latest, browser]);
});

test('utilise le nom en repli sans fusionner deux desktop entries différents', () => {
    const result = groups.groupNotifications([
        notification(1, 'Terminal'), notification(2, 'Terminal'),
        notification(3, 'Terminal', 'kitty'), notification(4, 'Terminal', 'foot'),
        notification(5, '__proto__'), notification(6, ''), notification(7, '')
    ], {});
    assert.equal(result.length, 5);
    assert.equal(result.find(g => g.key === 'name:Terminal').notifications.length, 2);
    assert.equal(result.find(g => g.key === 'name:Application').notifications.length, 2);
    assert.equal(result.find(g => g.key === 'name:__proto__').notifications.length, 1);
});

test('conserve une icône disponible et promeut le message suivant après suppression', () => {
    const older = notification(1, 'Messages', 'chat');
    older.appIcon = 'chat-icon';
    const latest = notification(2, 'Messages', 'chat');
    let result = groups.groupNotifications([older, latest], { 1: 1000, 2: 2000 });
    assert.equal(result[0].appIcon, 'chat-icon');
    result = groups.groupNotifications([older], { 1: 1000 });
    assert.equal(result[0].notifications[0], older);
    assert.equal(groups.groupNotifications([], {}).length, 0);
});

test('départage les réceptions simultanées par identifiant décroissant', () => {
    const result = groups.groupNotifications([
        notification(1, 'Messages'), notification(2, 'Messages')
    ], { 1: 1000, 2: 1000 });
    assert.equal(result[0].notifications[0].id, 2);
});

test('formate les temps relatifs et masque une réception inconnue', () => {
    const received = 1000;
    assert.equal(groups.relativeTime(undefined, 61000), '');
    assert.equal(groups.relativeTime(received, received - 1), "À l'instant");
    assert.equal(groups.relativeTime(received, received + 120000), '2 min');
    assert.equal(groups.relativeTime(received, received + 7200000), '2 h');
    assert.equal(groups.relativeTime(received, received + 172800000), '2 j');
});
