# 🔔 Serveur de Notifications & Centre de Contrôle Quickshell (`hdg-quickshell-notifications`)

Documentation technique du sous-système de notifications D-Bus et du Centre de Contrôle modulaire développé sous **[Quickshell](https://quickshell.outfoxxed.me/) v0.3.1+** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Vision & Fonctionnalités

Le sous-système de notifications réside dans `.config/quickshell/notifications/` et remplace intégralement SwayNC :
- **Serveur D-Bus Natif :** Implémentation complète de la spécification standard `org.freedesktop.Notifications`.
- **Centre de Contrôle Inspiré d'Apple :** Positionné en **haut au milieu** de l'écran (centré horizontalement sur l'axe X, calé sous la barre d'état sur l'axe Y), avec fond assombri dismissible au clic (`backdrop`) ou via la touche <kbd>Échap</kbd>.
- **Design Obsidian & Ardoise :** Fond sombre en dégradé discret, bordure neutre et accent bleu grisé `#8297a6`. La palette et la typographie sans-serif de `NotificationStyle.qml` sont reprises par les toasts et les popups via `PopupStyle.qml`. La barre conserve son thème propre.
- **Dimensions Fixes & Proportions Carrées :**
  - **Largeur standardisée :** 480 px (`Theme.notificationPanelWidth: 480`) avec réduction uniquement si la largeur disponible est inférieure. La carte est bornée à la hauteur disponible et défile sur les petits écrans.
  - **Toggles tactiles rapides :** Pavés quasi carrés de 64 px de hauteur (Wi-Fi, Bluetooth, Caféine, Micro, Audio), sans libellés permanents ; noms accessibles et commandes accessibles au clavier, sans infobulles au survol.
  - **Curseurs fins :** Volume et luminosité regroupés dans une surface de 84 px, avec icônes, poignées et pourcentages en direct. Réglage par glissement ou au clavier.
  - **Barre d'actions par icônes :** Verrouiller, Éteindre, Ne pas déranger, Effacer les notifications et Fermer (32 px).
  - **Bloc-notes persistant (Scratchpad) :** Zone de saisie proportionnelle à 40% de la hauteur d'écran (`Theme.scratchpadHeightRatio: 0.40`).
  - **Historique groupé par application :** Une notification récente visible par groupe, compteur et dépliage. Suppression individuelle, par groupe ou globale. Hauteur de défilement adaptative de 80 à 200 px pour préserver la place du bloc-notes.
- **Toasts OSD Éphémères :** Alertes visuelles animées de 380 px de large avec ligne de compte à rebours de 1 px, mise à jour à 10 Hz et pause réelle au survol. Quatre cartes au maximum ; une notification remplacée sous le même identifiant n’est pas dupliquée.
- **Lazy Loading & Destructibilité :** Instanciation à la demande par `Loader` dans `shell.qml` et destruction à la fermeture pour une consommation mémoire nulle hors utilisation.
- **Filtrage Anti-Spam :** Rejet immédiat des notifications fantômes sans résumé ni corps issues des mises à jour D-Bus.

---

## 🏛️ 2. Arborescence du Module `notifications/`

```
.config/quickshell/notifications/
├── NotificationService.qml      # Singleton D-Bus (NotificationServer), état DND, historique, IPC
├── NotificationToastWindow.qml  # Fenêtre de toasts flottants OSD avec placement adapté aux popups
├── NotificationCenter.qml       # Carte haut-centrée (480px max), barre d’actions et défilement
├── NotificationStyle.qml        # Palette ardoise et typographie partagées
├── NotificationGroups.js        # Regroupement, tri par réception et temps relatifs
├── ToastLifetime.qml            # Compte à rebours indépendant des cartes
├── qmldir                       # Déclaration de module
└── components/                  # Sous-composants modulaires à responsabilité unique
    ├── ToastCard.qml            # Carte ardoise, actions qui reviennent à la ligne
    ├── PanelIconButton.qml      # Bouton par icône, focus clavier et nom accessible
    ├── QuickSettings.qml        # 5 toggles de 64px (Wi-Fi, BT, Caféine, Micro, Audio)
    ├── VolumeBrightnessSliders.qml # Deux curseurs fins dans une surface de 84px
    ├── NotificationList.qml     # Groupes dépliables (200px max), actions et état vide
    └── Scratchpad.qml           # Mini bloc-notes persistant à hauteur relative 40% (scratchpad.txt)
```

---

## 🔧 3. Composants & Architecture

### 1. `NotificationService.qml` (Singleton D-Bus)
- **Instanciation D-Bus :** `Quickshell.Services.Notifications.NotificationServer` revendique `org.freedesktop.Notifications`.
- **Mode Ne Pas Déranger (DND) :** Filtre l'affichage des popups OSD tout en archivant les notifications dans l'historique.
- **Temps de réception :** Horodatages conservés tant que la notification est suivie, y compris en DND ; nettoyage à la fermeture. L’historique reste en mémoire, sans persistance après redémarrage.
- **Gestionnaire IPC (`target: "notifications"`) :**
  ```bash
  quickshell ipc call notifications toggle
  quickshell ipc call notifications toggleDnd
  quickshell ipc call notifications clear
  ```

### 2. `NotificationToastWindow.qml` (Toasts OSD)
- Surface Layer-Shell `Overlay` dans le coin supérieur droit, largeur maximale de 380 px et hauteur bornée avec défilement.
- Cartes ardoise aux coins de 18 px, application et date discrètes, titre puis message, actions natives focalisables revenant à la ligne.
- `ToastLifetime.qml` est créé par le service : une seule animation pilote le temps restant et sa ligne de progression. Le survol suspend puis reprend ce temps ; l’arrivée d’une autre carte ne le réinitialise pas.
- Expiration normale à 6 s, faible urgence à 3,5 s ; les alertes critiques restent jusqu’à leur fermeture et portent un repère ambre discret.
- La fermeture du toast conserve la notification dans l’historique. Les actions appellent seulement `invoke()` pour respecter les notifications résidentes ; la fermeture distante nettoie aussi le toast.
- Si une popup occupe le coin droit, les toasts passent à gauche lorsque la place le permet, sinon sous la popup.
- Rendu d’icône via `IconImage`, avec repli sur la cloche.

### 3. `NotificationCenter.qml` & Sous-Composants
- **`QuickSettings.qml` :** 5 pavés de 64 px, état actif teinté ardoise et icônes sans libellés. Les commandes système se trouvent dans la barre supérieure du panneau.
- **`VolumeBrightnessSliders.qml` :** Curseurs Qt Quick Controls stylisés, volume réactif via PipeWire et luminosité via brightnessctl avec debounce de 40 ms.
- **`NotificationList.qml` :** Groupes triés par réception récente ; identité `desktopEntry` avec repli sur `appName`. Un groupe replié affiche sa notification la plus récente. L’état déplié survit aux changements de la liste pendant l’ouverture. Les actions reviennent à la ligne ; `invoke()` respecte le comportement des notifications résidentes.
- **`NotificationGroups.js` :** Fonctions de regroupement et de temps relatif, testables sans session graphique. Les compteurs indiquent le nombre de notifications suivies, sans distinction lu/non lu.
- **`Scratchpad.qml` :** Bloc-notes persistant à hauteur relative (40% de la hauteur d'écran via `Theme.scratchpadHeightRatio`) synchronisé automatiquement dans `$XDG_STATE_HOME/quickshell/scratchpad.txt` avec raccourci de copie instantanée dans le presse-papier (`wl-copy`).


## Validation

```bash
node --test tests/notification-groups.test.cjs
```

Sur une session Quickshell, vérifier la réception de plusieurs notifications de la même application, le dépliage, la suppression individuelle et par groupe, le mode DND, le réglage des curseurs et la persistance des notes après fermeture. Tester aussi une résolution basse et une mise à l’échelle élevée : la zone de notes conserve 40 % de la hauteur logique de l’écran.
