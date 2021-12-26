## About

Ass Secret Store is simple cli password manager based on [Age](https://github.com/FiloSottile/age). Usage:
```
Age Secret Store is simple password manager inspired by pass which use Age <https://github.com/FiloSottile/age> as encryption. Usage:
  ass init
      Create new storage with new age key pair.
  ass add <names>
      Add new entries.
  ass ls
      List entries.
  ass show <name>
      Decrypt entry and print to stdout.
  ass cp <name>
      Decrypt entry and copy to clipboard. Clipboard will be cleared in 15 seconds. You can define custom time in ASS_COPY_TIME. Currently work only with klipper and wl-clipboard.
  ass rm <names>
      Remove entries.
  ass destroy
      Remove password storage.
  ass help
      Show this help.
```

## Requirements
* age
* tree – for listing your passwords
* KDE and Wayland (wl-clipboard and klipper) – for copying. If you want use other tools just replace commands for copying and clearing clipboard, it's only two commands in copy function

## Todo
* bash/zsh completions
* YubiKey support – when [YubiKey plugin for Age](https://github.com/str4d/age-plugin-yubikey) will be ready (probably when age 1.1 will release) and when I get my own YubiKey (someone want buy me one :grin:)
