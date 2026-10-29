# Diagnostiquer les ralentissements de la session

Les corrections de code ne suffisent pas à attribuer des lags à Quickshell. Comparer les mesures au repos, pendant le lag et après le retour à la normale, avec les mêmes applications et écrans. Noter l’heure, le geste déclencheur et si le curseur, toutes les fenêtres ou seulement le shell saccadent.

## Audit de la configuration

L’audit du 2026-10-07 a corrigé :

- Les lectures synchrones des métriques CPU, RAM, réseau, température et uptime : lecture asynchrone puis traitement dans `FileView.onLoaded`.
- Le compte à rebours des toasts : dix mises à jour par seconde pendant leur durée, sans animation JavaScript à chaque image. La pause garde le temps restant ; les alertes critiques ne démarrent pas ce timer. L’expiration peut être détectée jusqu’à environ 100 ms après l’échéance, hors retard de l’event loop, avant le fondu de 150 ms.
- La réassignation du modèle de toasts lorsqu’un identifiant déjà absent est supprimé.
- Le chargement des pochettes MPRIS : asynchrone et taille demandée de 64 × 64.

Les popups, le panneau et les toasts sont chargés à la demande. Les timers des métriques des popups s’arrêtent à leur fermeture ; les fondus durent 150 ms. Aucun effet shader ou flou Qt n’a été ajouté. La barre lit toujours CPU toutes les 2 secondes, RAM et réseau toutes les 3 secondes, et luminosité toutes les 30 secondes, par écran. L’audio et la batterie utilisent les services natifs ; le repli audio passe par `wpctl` toutes les 5 secondes uniquement en l’absence d’objet audio natif.

Les validations Qt utilisent des services Quickshell simulés. Elles vérifient le comportement, pas les performances du pilote GPU ni de la session réelle. La documentation [FileView](https://quickshell.org/docs/v0.3.1/types/Quickshell.Io/FileView/) décrit les risques de blocage de l’interface ; Qt recommande la mesure avec son [QML Profiler](https://doc.qt.io/qtcreator/creator-qml-performance-monitor.html).

## Mesurer pendant un lag

Les commandes ci-dessous lisent l’état de la session. Si l’exécutable s’appelle `qs`, remplacer `quickshell` par `qs`. `pidstat` et `iostat` sont fournis par `sysstat` ; s’ils sont absents, commencer avec `top` et `vmstat`.

Dans un premier terminal, pendant 30 secondes :

```bash
pidstat -u -r -d -G '^(quickshell|qs|Hyprland)$' 1 30
```

Observer `%CPU`, `RSS`, les défauts majeurs de pages et les entrées/sorties au moment des saccades. Une consommation CPU faible n’exclut pas une attente GPU ou une lecture matérielle lente. RSS inclut des caches : une augmentation qui se stabilise n’établit pas une fuite. Pour repérer un autre processus responsable :

```bash
top
vmstat 1 30
```

La première ligne de `vmstat` résume la période depuis le démarrage : lire les suivantes pour le lag actuel. `r` indique les tâches exécutables, `si`/`so` les échanges avec le swap et `wa` l’attente d’entrées/sorties. Du swap occupé seul ne prouve pas un manque de mémoire ; les échanges répétés pendant le lag sont plus utiles.

La [pression mesurée par le noyau](https://docs.kernel.org/accounting/psi.html) indique le temps perdu en attente de CPU, mémoire ou entrées/sorties :

```bash
watch -n 1 'cat /proc/pressure/cpu /proc/pressure/memory /proc/pressure/io'
```

Lire dans l’ordre CPU, mémoire, I/O. `avg10` est une moyenne sur dix secondes : elle lisse les pics brefs. Si ces fichiers sont absents, le noyau peut ne pas exposer PSI. Une hausse de la pression mémoire ou I/O pendant les lags oriente vers la mémoire/swap ou le stockage ; une hausse CPU vers la contention de calcul.

Pour le disque :

```bash
iostat -xz 1 30
```

Corréler la latence `await`, les files d’attente et la pression I/O. `%util` seul ne suffit pas à conclure à la saturation d’un SSD moderne. Référence des options : [manuel sysstat de pidstat](https://github.com/sysstat/sysstat/blob/master/man/pidstat.1).

## Journaux Quickshell et noyau

```bash
quickshell --version
quickshell list --all
quickshell log --tail 100 --follow --log-times
```

La liste aide à repérer plusieurs instances de la même configuration sur la même session. Plusieurs threads d’une instance ne sont pas plusieurs shells. Si plusieurs instances existent, sélectionner celle de la barre avec `quickshell log --pid PID --tail 100 --follow --log-times`, en remplaçant `PID` par son identifiant de processus. Vérifier `quickshell log --help` si les options diffèrent sur la version installée. Référence : [CLI officielle](https://github.com/quickshell-mirror/quickshell/blob/master/src/launch/parsecommand.cpp).

Chercher des messages répétés `Binding loop`, `ReferenceError`, `TypeError`, des redémarrages ou des erreurs graphiques, surtout à l’heure du lag. Sans journal disponible dans Quickshell :

```bash
journalctl --user -b --since '10 minutes ago' --no-pager
journalctl -k -b --since '10 minutes ago' --no-pager
```

Le journal noyau peut nécessiter des droits supplémentaires. Chercher des erreurs/reset GPU, des erreurs de disque, des OOM et du throttling. Si les journaux sont partagés, fournir l’extrait autour du lag.

## Si les ressources CPU/RAM/disque ne l’expliquent pas

```bash
hyprctl monitors
sensors
```

Vérifier les modes et fréquences réellement appliqués. Le profil de ce dépôt demande actuellement 2880 × 1800 à 90 Hz, échelle 1.33 et 10 bits ; cela constitue une piste à mesurer, pas une cause démontrée. Observer aussi les températures et, selon le matériel, l’utilisation GPU avec `nvtop`, `intel_gpu_top` ou `nvidia-smi`. Ces outils peuvent ne pas être installés ou ne pas prendre en charge le GPU utilisé.

Si Quickshell reste peu actif mais que toute la session saccade, examiner Hyprland, le pilote graphique, les températures et les fréquences d’écran. Un coût de rendu Quickshell peut aussi charger le compositeur : ne pas innocenter le shell sur son seul `%CPU`.

## Comparaison temporaire avec Quickshell arrêté

Pour isoler le shell, un essai manuel consiste à arrêter uniquement son instance, refaire le même geste pendant 30 secondes, puis la relancer. La barre et les notifications disparaissent pendant cet essai ; les fenêtres applicatives restent ouvertes. Ne pas lancer une seconde instance par-dessus la première.

Après avoir identifié le PID dans `quickshell list --all` :

```bash
quickshell kill --pid PID
```

Puis, pour cette configuration lancée par UWSM :

```bash
uwsm app -- quickshell --no-duplicate
```

Si le superviseur relance automatiquement Quickshell, l’essai n’isole pas le shell : vérifier la liste des instances. Une amélioration répétable à l’arrêt puis une réapparition à la relance désigne Quickshell ou son interaction avec le compositeur comme piste prioritaire. Des lags identiques à l’arrêt orientent vers une autre cause, sans prouver que tous les composants du shell sont optimaux.

À rapporter : heure du lag, scénario déclencheur, GPU et modes d’écran, sortie `pidstat` pendant le lag, pression mémoire/I/O et extrait des journaux correspondant.

## Suite de l’audit : lanceur et listes

Les champs de recherche des applications sont désormais normalisés dans un index réactif, actualisé lors d’un changement de métadonnées. La frappe filtre cet index sans recréer les chaînes normalisées ; le tri MRU et la priorité des noms commençant par la recherche restent identiques. Les cartes de groupes de notifications sont réutilisées lors du défilement et leurs icônes sont chargées en arrière-plan à taille bornée. Le panneau rafraîchit ses états une seule fois à la création. Ces choix suivent les recommandations officielles [Qt sur les images et bindings](https://doc.qt.io/qt-6.8/qtquick-performance.html) et [la réutilisation des delegates](https://doc.qt.io/qt-6.8/qml-qtquick-listview.html#reusing-items).

Les popups CPU, RAM, luminosité, batterie et son sont retirées ; leurs indicateurs et les interactions de barre restantes sont conservés. Les anciennes descriptions de leurs lectures détaillées dans cet audit décrivent l’état avant leur suppression.

Une régression des lecteurs asynchrones a également été corrigée : `preload: false` empêchait `reload()` seul de démarrer une lecture. Les lecteurs restants utilisent explicitement `preload: true`, puis traitent le résultat dans `onLoaded`. Vérification dans le [code natif de FileView](https://github.com/quickshell-mirror/quickshell/blob/master/src/io/fileview.cpp), fonctions `updatePath()` et `reload()`. Les simulations initiales n’exerçaient pas cette condition.
