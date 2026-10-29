# Design validé A : popups de la topbar et notifications flottantes

La variante A est implémentée dans la configuration Quickshell. Ce document conserve les deux variantes présentées pour référence. Les exemples de la [maquette interactive](floating-popups-proposal.html) sont fictifs.

## Deux variantes

**A — Obsidian / ardoise, recommandée.** Fond sombre légèrement dégradé, contour neutre très fin, coins de 18 px, accent `#8297a6` et texte sans-serif. Les valeurs et le contenu priment sur les titres. Boutons par icônes avec infobulles, dans la continuité du panneau.

**B — Compact / contours.** Même contenu et même bleu grisé, fond uniforme, coins de 12 px et bordure ardoise plus visible. Marges de 14 px plutôt que 16 px. Cette variante donne des cartes un peu plus denses et mieux délimitées.

Les deux variantes sont accessibles via les boutons A/B de la maquette. Survoler les modules affiche chaque popup ; le clic la maintient ouverte dans cet aperçu. Échap ou un clic sur le fond la ferme.

## Déclinaisons proposées

Les dimensions sont des cibles en pixels logiques, bornées à la place disponible. CPU, RAM, réseau, luminosité, batterie et volume partagent désormais un format horizontal de 300 × 150 px (2:1), stable lors du dépliage. La popup reste ancrée sous son module, avec une marge de 8–12 px et correction du placement près des bords. La hauteur est bornée et le contenu peut défiler.

| Popup | Largeur cible | Présentation |
| --- | ---: | --- |
| Volume | 300 × 150 px | Icône, pourcentage, curseur fin avec grande cible de saisie, mute et réglages par icônes. Plage actuelle 0–150 % conservée ; suramplification distinguée au-delà de 100 %. |
| Luminosité | 300 × 150 px | Même curseur ; quatre paliers actuels, sans titre redondant. |
| Caféine | 220 px | Une ligne avec icône, nom et bascule ; état actif confirmé visuellement. |
| Réseau | 300 × 150 px | Nom du réseau, signal et débits ; adresse locale directement visible ; connexions, terminal et VPN par icônes. |
| Processeur | 300 × 150 px | Charge et température ; détail des cœurs dépliable en grille compacte. |
| Mémoire | 300 × 150 px | Mémoire utilisée, capacité et jauge ; détail du swap dépliable. |
| Batterie | 300 × 150 px | Charge, autonomie et watts ; trois profils d’énergie avec infobulles et indication du profil actif. |
| Musique | 300 px | Petite pochette de 64 px, titre/artiste/album et trois commandes ; hauteur réduite par rapport à la grande pochette actuelle. |
| Horloge | 300 px | Heure, date, calendrier et uptime discret ; aujourd’hui teinté ardoise. |
| Application | 280 px | Application, espace de travail et titre de fenêtre ; fermeture par icône séparée. |
| Session | 220 px | Liste compacte. Les libellés Verrouiller, Veille, Déconnexion, Redémarrer et Éteindre restent visibles pour identifier les actions. |

Les infobulles et noms accessibles remplacent les libellés permanents des commandes évidentes. Les informations nécessaires à la lecture restent visibles. Les états absents (pas de lecteur, pas de batterie, déconnexion) devront avoir une présentation simple, sans valeurs inventées.

## Toasts de notification

- Largeur conservée à 380 px, coins de 16–18 px et marge interne de 14–16 px.
- En-tête discret : icône, application, temps de réception et fermeture. Titre en 13–14 px, corps en 12–13 px ; accent ardoise réservé aux commandes et à une jauge de 1 px.
- Actions courtes avec retour à la ligne si nécessaire. Garder la sémantique native des actions, notamment les notifications résidentes.
- Alerte critique : marqueur latéral ambre ou rouge atténué et icône distincte. Elle reste affichée jusqu’à fermeture, sans jauge d’expiration.
- Pause au survol avec reprise du temps restant, puis disparition discrète. L’historique conserve son regroupement par application.
- Conserver la limite actuelle de quatre toasts ; gérer le placement pour éviter qu’une pile masque la popup utilisée dans la topbar.

Le bouton « Tester l’expiration » permet de simuler six secondes d’affichage et la pause au survol. Les deux exemples montrent une notification ordinaire et une alerte critique. Ils sont présentés à côté de la scène topbar pour comparer les surfaces.

## Optimisations proposées pour l’implémentation

Le chargement à la demande et la destruction après fermeture existent déjà dans `LazyPopup.qml` : les conserver. Garder les délais de survol de 140 ms à l’ouverture et 320 ms à la fermeture, avec des transitions brèves de 120–160 ms. Éviter des animations permanentes ou des effets de flou supplémentaires.

La maquette propose aussi une ouverture maintenue après clic, utile pour régler un curseur. Ce comportement est implémenté, avec fermeture par second clic, Échap ou clic extérieur.

Pour les toasts, un temps restant commun au délai d’expiration et à la jauge évitera leur désynchronisation. Suspendre les mises à jour pendant le survol et au repos. Vérifier les notifications remplacées sous le même identifiant pour éviter d’empiler plusieurs exemplaires.

Pour les données, privilégier les services réactifs existants, limiter les rafraîchissements à la popup ouverte et regrouper les lectures déjà effectuées par les modules lorsque cela est utile. Débouncer les commandes de luminosité pendant le glissement ; rafraîchir l’uptime moins souvent que l’heure. Mesurer le nombre de lectures et de processus avant et après, sans annoncer de gain chiffré à ce stade.

La palette des popups et des toasts pourra partager les tokens ardoise du panneau. Les icônes et accents de la topbar elle-même restent hors de cette proposition.

## Vérifications

Passage de la barre vers la popup sans fermeture accidentelle, déplacement entre modules, fermeture pendant une animation, clic puis glissement d’un curseur, mise à l’échelle et petits écrans. Pour les notifications : expiration, survol répété, alerte critique, remplacement d’une notification, action native et fermeture distante. Vérifier que les timers et surfaces sont bien arrêtés ou détruits hors utilisation.


Validation de l’implémentation : rendu Qt offscreen des onze popups et des détails dépliables, compte à rebours des toasts, pause/reprise, remplacement d’identifiant, limite de quatre, exclusivité et destruction après fermeture. Les surfaces Wayland et les services système sont simulés dans cette validation ; le placement et les commandes natives restent à vérifier dans la session réelle. La mutualisation des métriques entre barre et popup et le choix du capteur CPU restent des pistes dans `roadmap.md`.
