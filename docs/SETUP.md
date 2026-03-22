# New Machine Setup

Steps to configure a new machine from scratch.

---

## 1. Install 1Password

Download and install [1Password](https://1password.com/downloads) manually.

Sign in with your email and Secret Key (retrieve from another device or the Emergency Kit PDF in your existing vault).

### Install 1Password CLI

Enable the CLI via **1Password → Settings → Developer → Command-Line Interface (CLI)**.

Verify:

```zsh
op --version
```

Sign in:

```zsh
eval $(op signin)
```

---

## 2. Create SSH Key

```zsh
ssh-keygen -t ed25519 -C "your@email.com"
# Accept default path (~/.ssh/id_ed25519), set a passphrase
```

Copy the public key:

```zsh
pbcopy < ~/.ssh/id_ed25519.pub
```

---

## 3. Import GPG Key

Import the GPG private key stored in 1Password:

```zsh
op document get private.gpg --output /tmp/private.asc && gpg --allow-secret-key-import --import /tmp/private.asc && rm /tmp/private.asc
```

Verify the key was imported:

```zsh
gpg --list-secret-keys
```

---

## 4. Add SSH Key to GitHub

1. Go to [github.com/settings/keys](https://github.com/settings/keys)
2. **New SSH key** → paste the public key → save

### Test access

```zsh
ssh -T git@github.com
# Expected: Hi phamann! You've successfully authenticated...
```

---

## 5. Install Nix (Determinate Systems)

**macOS:** Use the GUI `.pkg` installer — download from:

```
https://install.determinate.systems/determinate-pkg/stable/Universal
```

Open the `.pkg` and follow the prompts. Or use the CLI instead:

```zsh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**Linux:** CLI only:

```zsh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart your shell or source the environment:

```zsh
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

---

## 6. Clone Dotfiles

```zsh
git clone git@github.com:phamann/dotfiles.nix.git $HOME/.config/nixpkgs
cd $HOME/.config/nixpkgs
```

---

## 7. Apply Configuration

Run the appropriate target for this machine:

| Host    | Type   | Command        |
|---------|--------|----------------|
| x-wing  | macOS  | `make x-wing`  |
| r2-d2   | macOS  | `make r2-d2`   |
| yoda    | Linux  | `make yoda`    |

```zsh
make <hostname>
```

This will take a while on first run.

---

## 8. Test Configuration

```zsh
# Verify nix-darwin (macOS)
darwin-rebuild --version

# Verify home-manager
home-manager --version

# Check a managed package
which nvim && nvim --version

# Verify shell is correct
echo $SHELL
```

Restart your terminal. If something looks off, check `make help` for available targets.
