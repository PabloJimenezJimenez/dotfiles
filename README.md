# dotfiles

<p align="center">
  <a href="https://discord.gg/Wsy2NpnZDu"
    ><img
      alt="Discord"
      src="https://img.shields.io/discord/1439901831038763092?style=flat-square&label=discord"
  /></a>
</p>

Watch the walkthrough: https://youtu.be/5N-okeDdIuI

My personal setup, managed with nix-darwin and home-manager on Mac, and
home-manager standalone on Linux.
One repo, one command, and a fresh machine ends up configured the same way every time.

## Contributing / Using This Repo

These are my personal dotfiles, shared publicly so people can read them, learn from them, and fork them freely.
Feature requests and pull requests are not accepted here, and PRs are auto-closed.
If you find a bug, please open a GitHub Issue using the bug report template.

## What you get

Running the switch builds:

- System settings on Mac (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew apps on Mac (WezTerm and Claude Code casks)
- Nix user packages on every platform (ripgrep, fd, fzf, jq, lazygit, Neovim, Hack Nerd Font, Herdr)
- Extra Nix packages on Linux (WezTerm and Claude Code, since there are no casks)
- Shell (zsh, aliases, starship prompt)
- Editor (Neovim config with the rose-pine moon theme)
- Terminal (WezTerm config with the rose-pine moon theme and dimmed unfocused windows)
- Agent configs (Claude, Codex, opencode all share one AGENTS.md)
- Optional Pi theme and local extensions, generic UI settings and model overrides, plus two deliberately pinned third-party Pi packages

## Prerequisites

- **Mac (Apple Silicon)** - default. Works out of the box.
- **Mac (Intel)** - change one line. In `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";` (the comment right there tells you the same thing).
- **Linux (Ubuntu 24.04, including WSL2)** - default `homeConfigurations."linux"` output, `x86_64-linux`. On ARM set `linuxSystem = "aarch64-linux";` in `flake.nix`.
- Linux only: make zsh your login shell once, since home-manager installs and configures it but does not change it:

  ```sh
  chsh -s "$(command -v zsh)"
  ```

- WSL note: WezTerm installed here runs through WSLg. If you prefer the native Windows WezTerm, point it at `\\wsl$\...\<distro>\home\<user>\.config\wezterm` (that path is the symlink this repo creates) instead of using the Linux build.

## Fresh-machine setup

On a brand new Mac or Linux box, from a bare clone of this repo:

```sh
git clone https://github.com/kunchenguid/dotfiles.git
cd dotfiles
```

Before you run it: review "Make it yours" below.
Change the host label or CPU architecture if needed, and read the Homebrew cleanup warning.
`bootstrap.sh` applies the config to your machine, so do this first.

```sh
./bootstrap.sh
```

`bootstrap.sh` does five things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Enables the `nix-command` and `flakes` experimental features, if a bare Nix install left them off.
3. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
4. Checks the `user` configured in `flake.nix` against your actual username, and offers to fix it for you if they differ.
5. Runs the first switch: `darwin-rebuild switch` on Mac (fetched from the nix-darwin 26.05 release branch) or `home-manager switch` on Linux (fetched from the home-manager 26.05 release branch). Both apply this repo's locked flake config.

After that, `darwin-rebuild` exists and you're on the normal workflow below.

### Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system - handy when you have edited something:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

If you renamed the host label in "Make it yours", substitute your label for `mac` in these commands.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it.
No separate build-and-copy step.

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your username and offers to set it) OR change the single `user = "kunchen"` line in `flake.nix`.
  Everything else (`configuration.nix`, `home.nix`, home directory paths) is threaded from that one variable.
- **Host label** - `"mac"` on macOS, `"linux"` on Linux. The label appears in `flake.nix` (`darwinConfigurations."mac"` / `homeConfigurations."linux"`), `rebuild.sh`, and `bootstrap.sh`. All three have to match.
- **CPU architecture**:
  - Mac: `hostPlatform` in `configuration.nix` (see Prerequisites above).
  - Linux: `linuxSystem` in `flake.nix` (see Prerequisites above).

**Git identity:** this config deliberately does not set your git name or email.
Git will stop your first commit and tell you to set them (`git config --global user.name "Your Name"` and `git config --global user.email you@example.com`).
If you'd rather manage that declaratively, add this back to `home.nix` with your own identity:

```nix
programs.git = {
  enable = true;
  settings.user = {
    name = "Your Name";
    email = "you@example.com";
  };
};
```

**Homebrew cleanup warning:** `configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`.
That means every time you switch on Mac, Homebrew removes any package or cask on your machine that isn't listed in the `brews` and `casks` arrays in `configuration.nix` (Linux has no Homebrew in this config at all).
Today those arrays hold only the WezTerm and Claude Code casks; `herdr` moved to the flake.
If you already have Homebrew stuff installed that isn't in that list, the first switch will uninstall it.
Read through `brews` and `casks` before you run `bootstrap.sh` or `rebuild.sh` for the first time, and add anything you want to keep.

**About `herdr`:** it is installed from its official flake, `github:herdrdev/herdr/v0.9.1`, on both Mac and Linux (see `flake.nix` and `home.nix`).
It used to be a Homebrew formula; the first switch after that change lets `homebrew.onActivation.cleanup = "zap"` remove the brew copy while Nix takes over, same version, and `~/.config/herdr` is unaffected.
Update it with `nix flake update herdr`. If you don't use it, remove `herdrPkgs.${pkgs.stdenv.hostPlatform.system}.default` from `home.packages` in `home.nix` and drop the `herdr` input from `flake.nix`.

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, and `home.nix` installs it for Claude, Codex, and opencode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- The `cc` and `co` shell aliases in `home.nix` are high-agency shortcuts: `claude --dangerously-skip-permissions` and `codex --full-auto`.
  They're convenient for me, but know what they do before you use them.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs, nix-darwin, home-manager, nix-homebrew, and the Herdr flake, and declares the `mac` machine (nix-darwin) and the `linux` machine (home-manager standalone).
- `configuration.nix` - Mac-only system config: macOS defaults, Homebrew. Not used on Linux.
- `home.nix` - user-level config, shared by both platforms: shell, packages, prompt, and the symlinks described below. Platform differences (home directory, WezTerm/Claude Code source) live in `isLinux` conditionals.
- `rebuild.sh` - re-applies the config after the first switch. Detects the OS and runs `darwin-rebuild` (Mac) or `home-manager` (Linux).
- `home/` - the actual config files that get symlinked into place; the sections below explain the shared symlink model and Pi's narrower selective setup.

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list or a system default.

## Optional Pi configuration

Pi is an opt-in CLI, not a dependency this repository vendors. Install it from its owner with the [official Pi instructions](https://pi.dev), for example:

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

[Pi Launcher](https://github.com/kunchenguid/homebrew-tap) is also optional and installed from its owner, not declared by this config:

```sh
brew install --cask kunchenguid/tap/pi-launcher
```

Home Manager owns exactly two repository-authored Pi directories: `~/.pi/agent/themes` and `~/.pi/agent/extensions`. It also links `models.json` and `settings.json` as individual files. The local extension directory is for public, repository-authored extensions only - third-party package code never belongs there. Run `/reload` after editing a local extension or other Pi resources. The terminal-title extension shows a spinner while Pi is working, then a completion mark with the session name or current directory. The `rose-pine-moon` theme was authored clean-room from the public [Rosé Pine Moon palette](https://rosepinetheme.com/palette) and Pi's [public theme schema](https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json), not from a private or live theme file.

### Pi Calm

`home/.pi/agent/extensions/calm` is a standalone local Pi extension. Home Manager's existing global extensions-directory link makes Pi auto-load it without another declaration. `/calm` toggles a conversation-only presentation mode and is off by default. Its choice is stored locally in `~/.pi/agent/calm` (or the directory selected by `PI_CODING_AGENT_DIR`), not in this repository or Home Manager. Adapted from Firstmate under the bundled MIT license, Calm imports no Firstmate modules and has no Firstmate runtime dependency.

When enabled, Calm hides collapsed thinking and the call/result shells for Pi's seven built-in tools (`read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`) without leaving blank transcript rows. During an active run it replaces Pi's working row with a two-line animated blue-water, yellow-boat widget. `/calm` restores Pi's stock rendering and preserves the existing Ctrl+O tool-expansion choice.

Calm never changes prompts, tool execution, model context, session data, or ordering. `/share` and `/export` use the complete stock transcript. Generic custom tools, images, and unsupported Pi transcript classes deliberately remain visible because Pi has no safe general-purpose transcript filter. If a future Pi release no longer exports the exact collapsed-thinking rendering seam, Calm logs one diagnostic and leaves only that adapter disabled; all other behavior remains available.

Pi's package system declares two third-party sources in the linked global `settings.json`:

- `npm:pi-web-access@0.14.0` - the exact public npm release for web access.
- `npm:@ryan_nookpi/pi-extension-codex-fast-mode@0.2.6` - the exact public npm release from `ryan_nookpi`.

The versions are immutable pins, so Pi does not move them during package updates. Deliberate updates require a new source and security audit, followed by an explicit pin change in `home/.pi/agent/settings.json`. On Pi 0.82.0, global settings declarations install missing pinned packages automatically at startup. No one-time install command is required. Pi keeps the downloaded npm package trees in its own unmanaged `~/.pi/agent/npm` runtime directory, outside Home Manager and Git tracking.

Both packages execute with your full user permissions and must be trusted like any other executable code.

Home Manager deliberately does not manage `~/.pi/agent` itself, or Pi authentication, sessions, trust decisions, caches, npm/git package trees, or any other runtime state. The model overrides contain no credentials or endpoint settings, do not choose a default model, and only take effect after you authenticate Pi yourself. This remains an additive post-video layer: it does not install Pi, a launcher, or package source code into this repository.

## Notes

The first time you launch `nvim`, it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) by cloning plugins from GitHub.
That needs network access once; after that it's offline.
Neovim and WezTerm both use the rose-pine moon theme.
Neovim keeps italics off and uses a transparent background on macOS, Windows, and WSL so it matches the terminal setup.

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.
