## About

Ass Secret Store is simple cli password manager based on [Age](https://github.com/FiloSottile/age). Usage: run [ass](./ass) in terminal and do things :stuck_out_tongue:

## Requirements

* `age`
* [gum](https://github.com/charmbracelet/gum)
* `tree` – for listing your passwords
* `pwgen` – for generating passwords
* `wl-clipboard` for copying on Wayland, `xsel` and `xclip` for copying on X11

## Custom colors

You can create own color style and define custom width in `$HOME/.config/ass/colors`. You can use terminal colors (as below) or hex codes. Available variables and default values:
```bash
C_WARN="3"
C_ERR="1"
C_OK="2"
C_PASS="6"
C_ENAME="10"
C_TITLE="13"
C_BORDER="5"
C_BUTTON="2"
C_TREE="10"
C_CURSOR="15"
S_WIDTH="60"
```

## Old version

You can use old version without `gum` dependency, it's [ass-old](./ass-old) file. Usage:
```
Age Secret Store is simple password manager inspired by pass which use Age <https://github.com/FiloSottile/age> as encryption. Usage:
  ass init [--no-password -n] [--keyfile -k <keyfile>]
      Create new Age Secret Storage. If you not use password protected keys you should use -n flag. Keys are automatically generated if not exist. Define custom key location (existing or not) via -k.
  ass add [--generate-password -g] [--symbol-disable -s] [--length -l <number>] [--recipient -r <recipient>] <names>
      Add new entries. Optionally generate random passwords with given length or no special symbols. You can define additional recipients.
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
## Zsh completion (old version only)

To use zsh completion copy `ass.zsh-completion` to `<completion-dir>` as `_ass` and add to your `~/.zshrc` line:
```
fpath=(<completion-dir> $fpath)
```
