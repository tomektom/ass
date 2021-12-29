## About

Ass Secret Store is simple cli password manager based on [Age](https://github.com/FiloSottile/age). Usage:
```
Age Secret Store is simple password manager inspired by pass which use Age <https://github.com/FiloSottile/age> as encryption. Usage:
  ass init [--no-password -n] [--keyfile -k <keyfile>]
      Create new Age Secret Storage. If you not use password protected keys you should use -n flag. Keys are automatically generated if not exist. Define custom key location (existing or not) via -k.
  ass add [--generate-password -g] [--symbol-disable -s] [--length -l <number>] <names>
      Add new entries. Optionally generate random passwords with given length or no special symbols.
  ass ls
      List entries.
  ass show [--keyfile -k <keyfile>] <name>
      Decrypt entry and print to stdout. Define key file if needed.
  ass cp [--keyfile -k <keyfile>] <name>
      Decrypt entry and copy to clipboard. Clipboard will be cleared in 15 seconds. You can define custom time in ASS_COPY_TIME. Currently work only with klipper and wl-clipboard.
  ass rm <names>
      Remove entries.
  ass passgen [--symbol-disable -s] [--length -l <number>] [--copy -c]
      Generate random password. Optionally define password length (default 20) or disable special symbols. Copy without printing to stdout.
  ass destroy
      Remove password storage.
  ass help
      Show this help.
Environment variables:
  ASS_DIRECTORY – location of Age Secret Storage, default: ~/.ass
  ASS_AGE_KEYFILE – secret age key, default: ASS_DIRECTORY/.key.age
  ASS_COPY_TIME – copy timeout, default: 15
```


## Requirements
* age
* tree – for listing your passwords
* pwgen – for generating passwords
* KDE and Wayland (wl-clipboard and klipper) – for copying. If you want use other tools just replace commands for copying and clearing clipboard, it's only two commands in copy function

## Completion

To use zsh completion copy `ass.zsh-completion` to `<completion-dir>` as `_ass` and add to your `~/.zshrc` line:
```
fpath=(<completion-dir> $fpath)
```

## Todo
* bash completions
* YubiKey support – when [YubiKey plugin for Age](https://github.com/str4d/age-plugin-yubikey) will be ready (probably when age 1.1 will release) and when I get my own YubiKey (someone want buy me one :grin:)
