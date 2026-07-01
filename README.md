# Windows Dotfiles

Repository contenant mes dotfiles Windows pour :

* PowerShell
* Fastfetch
* Neovim
* Oh My Posh
* GlazeWM / YASB
* VSCode

## Installation

Cloner le repository :

```powershell
git clone https://github.com/redt974/windows-dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
```

Exécuter ensuite :

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

Le script :

* copie automatiquement les dossiers cachés (`.config`, `.glzr`, `.oh-my-posh`, `.vscode`)
* configure PowerShell
* crée le lien symbolique pour Neovim
* évite d’écraser une configuration existante

---

## Dépendances à installer

### Oh My Posh

Installer [Oh My Posh](https://ohmyposh.dev/?utm_source=chatgpt.com) :

**Winget**

```powershell
winget install JanDeDobbeleer.OhMyPosh
```

**Chocolatey**

```powershell
choco install oh-my-posh
```

---

### Fastfetch

Installer [fastfetch](https://github.com/fastfetch-cli/fastfetch?utm_source=chatgpt.com) :

**Winget**

```powershell
winget install fastfetch
winget install sharkdp.fd
```

**Chocolatey**

```powershell
choco install fastfetch
```

---

### Neovim

Installer [Neovim](https://neovim.io/?utm_source=chatgpt.com) :

**Winget**

```powershell
winget install Neovim.Neovim
```

**Chocolatey**

```powershell
choco install neovim
```

Le symlink est créé automatiquement par `setup.ps1`.

---

### NTop

Installer [NTop](https://github.com/gsass1/NTop?utm_source=chatgpt.com) :

**Winget**

```powershell
winget install gsass1.NTop
```

**Chocolatey**

```powershell
choco install ntop.portable
```

---

## Fastfetch

Alias disponibles :

```powershell
ff
ff-ascii
ff-pokemon
```

Au démarrage d’un terminal PowerShell, Fastfetch affiche par défaut :

* un ASCII art Elden Ring
* une citation aléatoire

Pour utiliser la version Pokémon :

```powershell
ff pokemon
```