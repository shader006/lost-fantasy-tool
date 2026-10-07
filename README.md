# Lost Fantasy Tool

## 📥 Download & install

➡️ **[Click here to download the full installer (LostFantasy-full.zip)](https://github.com/shader006/lost-fantasy-tool/releases/download/installer/LostFantasy-full.zip)**  (~460 MB)

1. Download the zip file above.
2. Right-click → **Extract All** → pick an install folder, e.g. `C:\LostFantasy`.
3. Open the extracted folder and run **`lost_fantasy_user.exe`**.
4. If Windows shows *"Windows protected your PC"*: click **More info → Run anyway** (first run only).

### Prefer a one-line install script instead?

**PowerShell:**
```powershell
irm https://raw.githubusercontent.com/shader006/lost-fantasy-tool/main/install.ps1 | iex
```
**Command Prompt (cmd.exe):**
```cmd
curl -L -o install.cmd https://raw.githubusercontent.com/shader006/lost-fantasy-tool/main/install.cmd && install.cmd
```
Both download every file, verify its SHA256, fetch the Chromium runtime, and ask before launching the app. Safe to re-run anytime to repair an install.

## 🔄 Updating

After installing, the app **checks for updates automatically**. When a yellow line appears at the bottom: press **U** to download, then **U** again to install. You never need to re-download the zip.

## ❓ Lots of confusing files under Releases?

You only need the **full installer** above. The `.exe`, `.dll`, `manifest.json`… files are internal pieces the self-updater uses — not meant to be downloaded by hand.
