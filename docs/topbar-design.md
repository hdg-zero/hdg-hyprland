# Topbar ardoise

La proposition reprend la palette des popups et du panneau : fond Obsidian, accent bleu grisé `#8297a6`, contour neutre et texte sans-serif. La [maquette interactive](topbar-proposal.html) utilise des données fictives. Le design est implémenté dans la configuration QML. L’icône Arch originale du lanceur est conservée. Les icônes HTML sont des représentations schématiques.

## Encombrement conservé

La hauteur et la réservation de l’espace restent exactement celles de `BarWindow.qml` : `max(24, round(hauteurLogique × 0.024))`. Cela donne 24 px en 720p, 26 px en 1080p et 35 px en 1440p. Largeur entière de l’écran, barre collée au bord supérieur, aucun espace extérieur, aucune seconde ligne. Les marges latérales restent à 8 px et les espaces entre modules à 4 px.

Les modules CPU, RAM, réseau et musique conservent ensemble leur budget horizontal actuel (3,8 % + 3,8 % + 6,8 % + 12 %). Sur les petits écrans, CPU/RAM gardent au moins 72 px et le réseau 90 px ; la zone musicale cède la différence pour que la largeur cumulée ne grandisse pas. Les chiffres utilisent des espacements constants ; le texte passe en sans-serif à 13 px, sans agrandir les icônes de 16 px de la barre. Les icônes des applications restent natives et reconnaissables.

## Dessin implémenté

- Fond ardoise uni, avec une séparation inférieure blanche très atténuée de 1 px.
- Modules transparents au repos. Au survol, une surface claire discrète et une bordure neutre ; aucune lueur bleue.
- Coins de 6–8 px à l’intérieur de cette barre fine, plutôt que de grandes pilules. Les fenêtres flottantes gardent leurs coins de 18 px.
- Bureau et fenêtre actifs : léger fond ardoise, contour fin et icône claire. Bureaux inoccupés plus discrets ; tous les bureaux existants restent accessibles.
- CPU et RAM : icône et pourcentage, sans répéter les mots CPU/RAM à côté d’icônes déjà identifiables ; noms complets accessibles. Débit réseau, titre musical, luminosité, volume et batterie restent visibles.
- Caféine active et DND : état discret mais explicite, avec leurs indicateurs actuels conservés. Notifications : nombre conservé. Énergie : rouge atténué `#c69292`.
- Titre de la fenêtre active : texte secondaire, centré dans l’espace réellement disponible, tronqué avec nom accessible complet. Il ne recouvre pas les commandes latérales.

L’ordre reste : lanceur, bureaux, CPU, RAM, réseau, musique ; titre actif ; fenêtres, tray, Caféine, luminosité, volume, batterie, notifications, horloge, énergie.

## Interactions à conserver

| Module | Comportement actuel à préserver |
| --- | --- |
| Lanceur | Clic : ouverture du lanceur. |
| Bureaux | Clic : changement de bureau ; molette : précédent/suivant ; bureaux supplémentaires dynamiques et état occupé/actif. |
| CPU / RAM | Survol : popup ; clic : maintien de la popup ; clic droit : btop. |
| Réseau | Survol ou clic : popup ; clic droit : nmtui ; état connecté et débit en direct. |
| Musique | Clic : lecture/pause ; clic droit : popup ; clic milieu : piste suivante ; molette : changement de piste ; masquage sans lecteur. |
| Fenêtres | Clic : activation et changement de bureau ; clic milieu : fermeture ; survol : détails de l’application ; toutes les fenêtres conservées. |
| Tray | Activation, activation secondaire et molette transmises aux applications ; filtrage actuel de l’icône réseau conservé. |
| Caféine | Clic : bascule ; survol ou clic droit : popup ; inhibition d’inactivité inchangée. |
| Luminosité | Survol ou clic : popup ; molette : pas de 3 %. |
| Volume | Survol ou clic : popup ; clic droit : pavucontrol ; molette : pas de 5 %, jusqu’à 150 %. |
| Batterie | Survol ou clic : popup ; charge et état en direct ; masquage sans batterie. |
| Notifications | Clic : panneau ; clic droit : DND ; compteur et état conservés. |
| Horloge | Heure à la minute ; survol ou clic : calendrier. |
| Énergie | Survol, clic gauche ou droit : menu compact et cinq actions actuelles. |

Le chargement à la demande, la popup musicale ouverte au clic droit, les délais de survol 140/320 ms, le maintien au clic des popups concernées, leur fermeture par Échap/clic extérieur et les services existants restent inchangés. La simulation HTML illustre le dessin et quelques gestes ; elle ne remplace pas les services Quickshell.

## Petits écrans et nombreuses fenêtres

Le titre et le texte musical se tronquent dans leur espace, avec leurs textes complets comme noms accessibles. Les fenêtres sont conservées dans un `Flickable` horizontal de 160 px maximum, réduit selon la place restante pour laisser le titre visible. La molette permet de parcourir toutes les fenêtres ; une fenêtre qui devient active est ramenée dans la zone visible. Le focus, la fermeture au clic milieu et les popups au survol restent disponibles.

`BarStyle.qml` est une palette locale qui reprend `NotificationStyle.qml`. `BarPillButton.qml` habille les commandes sans remplacer leurs handlers. `BarWindow.qml` et `Theme.qml` sont inchangés.

Validation : rendu Qt offscreen en 1280 × 720, 1920 × 1080 et 2560 × 1440, contrôle de hauteur, absence de chevauchement, valeurs CPU/RAM à 100 %, icône Arch et quinze fenêtres. Les commandes sont simulées : tests de clics et molettes pour le lanceur, les bureaux, la musique, le focus/fermeture des fenêtres, le tray, Caféine, luminosité, volume et notifications. Les surfaces Wayland et services natifs restent à vérifier en session réelle ; aucun rechargement n’a été effectué.
