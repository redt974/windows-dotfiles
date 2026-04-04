# Windows Dotfiles :

Copier le contenu du repository dans le dossier `C:/Users/<USERNAME>` pour les dossiers commençant avec un point.

Puis, ajouter ou modifier le ou les fichiers suivants : `C:/Users/<USERNAME>/WindowsPowerShell/Microsoft.PowerShell_profile.ps1` ou `C:/Users/<USERNAME>/PowerShell/Microsoft.PowerShell_profile.ps1` et

Copier / Coller le contenu du fichier suivant : `windows-dotfiles/powershell/profile.ps1`.

---

Installer [oh-my-posh](https://ohmyposh.dev/) avec cette commande dans un PowerShell en tant qu'Administrateur :

- Winget :

```powershell
winget install ohmyposh
```
- Choco :

```powershell
choco install ohmyposh
```

---

Installer [fastfetch](https://github.com/fastfetch-cli/fastfetch) avec cette commande dans un PowerShell en tant qu'Administrateur :

- Winget :

```powershell
winget install fastfetch
winget install sharkdp.fd
```
- Choco :

```powershell
choco install fastfetch
```

---

Installer [neovim](https://neovim.io/) avec cette commande et on va créer un lien symbolique pour le lier la config avec neovim : 

- Winget :

```powershell
winget install neovim
```
- Choco :

```powershell
choco install neovim
```

```powershell
New-Item -ItemType SymbolicLink `
  -Path $env:LOCALAPPDATA\nvim `
  -Target C:\Users\<USERNAME>\dotfiles\nvim\
```

---

## Fastfetch :

Pour utiliser `fastfetch`, on peut utiliser le raccourci configuré : `ff` ou `ff-ascii` ou `ff-pokemon`

A l'ouverture d'un terminal Powershell


, vous aurez donc un fastfetch en ascii Elden Ring par défaut avec une citation aléatoire.

Mais si vous préférez Pokémon, faites la commande : `ff pokemon`