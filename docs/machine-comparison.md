# Machine Comparison: Studio vs Air

## Homebrew Formulae

| Formula | Studio | Air | Recommendation |
|---------|--------|-----|----------------|
| aribb24 | - | ✓ | Air only (ffmpeg dep) |
| automake | ✓ | ✓ | Common |
| bison | ✓ | ✓ | Common |
| chruby | ✓ | ✓ | Common |
| czmq | ✓ | ✓ | Common |
| djvu2pdf | ✓ | - | Studio only |
| ffmpeg | - | ✓ | Air only (video work) |
| frei0r | - | ✓ | Air only (ffmpeg dep) |
| fzf | ✓ | - | **Add to Air** |
| gawk | ✓ | - | Studio only |
| gdbm | ✓ | - | Studio only (dep) |
| git-delta | ✓ | - | **Add to Air** |
| heroku | ✓ | - | Studio only |
| htop | ✓ | ✓ | Common |
| hugo | ✓ | - | Studio only |
| ical-buddy | ✓ | - | Studio only |
| imagemagick | - | ✓ | Air only |
| jupyterlab | ✓ | ✓ | Common |
| libffi | ✓ | ✓ | Common |
| neovim | ✓ | ✓ | Common |
| node@18 | ✓ | - | Studio only |
| openssl@1.1 | ✓ | - | Studio only (legacy) |
| pixi | - | ✓ | **Self-install on both** |
| postgis | ✓ | - | Studio only |
| postgresql@14 | ✓ | - | Studio: @14 |
| postgresql@17 | - | ✓ | Air: @17 - **Pick one version** |
| postgresql@18 | - | ✓ | Air: @18 - Remove? |
| pv | ✓ | - | Studio only |
| python@3.11 | ✓ | - | Studio only |
| redis | ✓ | - | Studio only |
| ripgrep | ✓ | ✓ | Common |
| ruby-install | ✓ | ✓ | Common |
| rustup | ✓ | - | Studio only |
| starship | ✓ | ✓ | Common |
| stow | ✓ | ✓ | Common |
| tailwindcss | ✓ | - | Studio only |
| telnet | ✓ | ✓ | Common |
| terminal-notifier | ✓ | - | **Add to Air** |
| tmux | ✓ | ✓ | Common |
| tree | ✓ | - | **Add to Air** |
| uv | ✓ | ✓ | Common |
| w3m | ✓ | - | Studio only |
| wget | ✓ | ✓ | Common |
| yarn | ✓ | - | Studio only |

## Homebrew Casks

| Cask | Studio | Air | Recommendation |
|------|--------|-----|----------------|
| alt-tab | ✓ | ✓ | Common - Homebrew |
| arc | - | ✓ | **Add to Studio** - Homebrew |
| audio-hijack | - | ✓ | Air only |
| bartender | - | ✓ | Air only (or add to Studio?) |
| claude-code | ✓ | ✓ | Common - Homebrew |
| db-browser-for-sqlite | ✓ | - | Studio only |
| easy-move+resize | ✓ | - | Common - Homebrew |
| firefox@developer-edition | ✓ | ✓ | Common - Homebrew |
| ghostty | ✓ | - | **Add to Air** - Homebrew |
| kap | ✓ | ✓ | Common - Homebrew |
| keka | - | ✓ | Air only |
| keycastr | - | ✓ | Air only |
| mactex | - | ✓ | Air has cask, Studio has TeX dir |
| miniforge | ✓ | - | Studio only (use pixi instead?) |
| raycast | ✓ | ✓ | Common - Homebrew |
| rectangle | ✓ | - | Studio has free, Air has Pro |
| shottr | ✓ | ✓ | Common - Homebrew |
| sqlitestudio | ✓ | - | Studio only |
| stats | - | ✓ | **Add to Studio** - Homebrew |
| textmate | ✓ | ✓ | Common - Homebrew |

## Apps (DMG/App Store) - Not in Homebrew

| App | Studio | Air | Recommendation |
|-----|--------|-----|----------------|
| 1Password | ✓ | ✓ | DMG (subscription) |
| Amazon Kindle | ✓ | - | Studio only - App Store |
| Anki | ✓ | - | Studio only |
| Arc | ✓ (DMG) | ✓ (cask) | **Standardize: Homebrew cask** |
| BeardedSpice | ✓ | - | Studio only |
| Beekeeper Studio | ✓ | - | Studio only |
| ChatGPT | ✓ | ✓ | DMG (auto-updates) |
| Claude | ✓ | ✓ | DMG (auto-updates) |
| Codex | ✓ | ✓ | DMG |
| CrossOver | ✓ | - | Studio only |
| Cryptomator | ✓ | - | Studio only |
| Cursor | - | ✓ | Air only |
| dBpoweramp | ✓ | - | Studio only |
| DeepL | ✓ | - | Studio only |
| Discord | ✓ | - | Studio only - Homebrew cask? |
| Docker | ✓ | ✓ | DMG (complex installer) |
| Figma | ✓ | - | Studio only |
| GarageBand | - | ✓ | Air only - App Store |
| Google Chrome | ✓ | ✓ | DMG (auto-updates) |
| Horo | ✓ | - | Studio only |
| Microsoft apps | ✓ | - | Studio only |
| Obsidian | ✓ | ✓ | DMG (auto-updates) |
| pgAdmin 4 | ✓ | - | Studio only |
| Proton apps | ✓ | ✓ | DMG |
| Rectangle Pro | ✓ | ✓ | DMG (paid version) |
| Shapr3D | ✓ | - | Studio only |
| Signal | ✓ | ✓ | DMG |
| Slack | ✓ | ✓ | DMG or cask? |
| Steam | ✓ | - | Studio only |
| texstudio | ✓ | - | Studio only |
| Things3 | ✓ | ✓ | App Store |
| TurboTax | ✓ | - | Studio only |
| VS Code | ✓ | ✓ | DMG (auto-updates) |
| Windows App | - | ✓ | Air only |
| Xcode | ✓ | - | Studio only - App Store |
| YubiKey Manager | ✓ | - | Studio only |
| Zoom | ✓ | ✓ | DMG |
| Zotero | ✓ | ✓ | DMG |

## Action Items

### Add to Studio (from Air)
- [ ] `arc` cask (currently DMG)
- [ ] `stats` cask

### Add to Air (from Studio)
- [ ] `fzf` formula
- [ ] `git-delta` formula
- [ ] `tree` formula
- [ ] `terminal-notifier` formula
- [ ] `ghostty` cask

### Standardize Install Method
- [ ] Arc: Both use Homebrew cask
- [ ] Slack: Decide Homebrew vs DMG
- [ ] Discord: Decide Homebrew vs DMG

### Decisions Needed
- [ ] PostgreSQL version: @14 vs @17 - pick one for both?
- [ ] Rectangle vs Rectangle Pro - keep both approaches?
- [ ] miniforge (Studio) vs pixi-only - consolidate?

### Keep as DMG (auto-update apps)
- 1Password, ChatGPT, Claude, Chrome, Docker, Obsidian, Proton apps, Signal, VS Code, Zoom, Zotero

### Studio-only (don't sync)
- dBpoweramp, CrossOver, Shapr3D, Steam, Xcode, TurboTax, Microsoft apps

### Air-only (don't sync)
- ffmpeg + deps (video work), audio-hijack, Cursor
