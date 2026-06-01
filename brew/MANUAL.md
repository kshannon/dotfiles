# Manually Installed Applications

Apps installed via DMG/direct download (not Homebrew).
Track these here so they're not forgotten during machine setup.

## Format

| App | Source | Why not Homebrew? | Update Method |
|-----|--------|-------------------|---------------|
| Example App | https://example.com | No cask available | In-app updater |

## Current Manual Apps

### Self-Updating Apps (DMG preferred)

| App | Source | Why DMG? | Update Method |
|-----|--------|----------|---------------|
| Arc | https://arc.net | Self-updates aggressively | In-app |
| Firefox Dev Edition | https://www.mozilla.org/firefox/developer/ | Self-updates | In-app |
| Chrome | https://www.google.com/chrome/ | Self-updates | In-app |
| VS Code | https://code.visualstudio.com | Self-updates | In-app |
| Obsidian | https://obsidian.md | Self-updates | In-app |
| Zoom | https://zoom.us | Self-updates | In-app |
| ChatGPT | https://openai.com/chatgpt/mac | Self-updates | In-app |
| Claude | https://claude.ai/download | Self-updates | In-app |

### Paid/Licensed Apps (DMG required)

| App | Source | Why DMG? | Update Method |
|-----|--------|----------|---------------|
| Rectangle Pro | https://rectangleapp.com/pro | Paid license | In-app, iCloud sync |
| 1Password | https://1password.com | Subscription | In-app |
| audio-hijack | https://rogueamoeba.com/audiohijack/ | Paid license | In-app |

### Other DMG Apps

| App | Source | Why DMG? | Update Method |
|-----|--------|----------|---------------|
| Docker | https://www.docker.com/products/docker-desktop/ | Complex installer | In-app |
| Signal | https://signal.org | Security preference | In-app |
| Zotero | https://www.zotero.org | Plugin ecosystem | In-app |
| Proton Mail/VPN | https://proton.me | Security preference | In-app |

### Self-Installed CLI Tools

| Tool | Install Method | Why? |
|------|----------------|------|
| pixi | `curl -fsSL https://pixi.sh/install.sh \| bash` | Official installer |
| nvm | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh \| bash` | Shell integration |

<!--
To find DMG-installed apps, check:
- /Applications for apps not in `brew list --cask`
- Apps that prompt for updates but you installed via Homebrew (version mismatch)
-->
