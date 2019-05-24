![GPLv3](https://img.shields.io/badge/license-GPLv3-brightgreen.svg)
[![MELPA](http://melpa.org/packages/ng2-mode-badge.svg)](http://melpa.org/#/ng2-mode)
# ng2-mode
The Angular 2+ support Emacs needs

![Screenshot](example.png)
## Features
- Syntax highlighting
- Syntactic indentation
- Out-of-the-box [lsp-mode](https://github.com/emacs-lsp/lsp-mode) support
- [typescript-mode](https://github.com/ananthakumaran/typescript.el) integration
- [tide](https://github.com/ananthakumaran/tide) integration

## Dependencies
- [typescript-mode](https://github.com/ananthakumaran/typescript.el) is required for typescript editing support

## Installation
Install this package with `M-x package-install RET ng2-mode`. It will automatically be activated on `*.{component|service|pipe|directive|guard|module}.ts` and `*.component.html` files, as well as whenever you type `M-x ng2-mode`.

If you want lsp-mode integration for your typescript files, add this to `~/.emacs.d/init.el`:
``` emacs-lisp
(with-eval-after-load 'typescript-mode (add-hook 'typescript-mode-hook #'lsp))
```

## Functions
- `ng2-mode` - Enable either `ng2-ts-mode` or `ng2-html-mode`, depending on the buffer's file extension
- `ng2-ts-mode` - Enable Angular 2 TypeScript mode
- `ng2-html-mode` - Enable Angular 2 Template mode

## Contributing
If you want to see a function in either mode, feel free to open an issue or a pull request.

## License
GPLv3+
