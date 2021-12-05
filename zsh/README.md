# zsh configuration

## plugins

I used to use zsh plugin managers such as zinit, zplug which are not well maintained recently (I appreciate them though).

Currently, I manually manage zsh plugins by using git submodules.

```shell
# adding submodules
git submodule add https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/dotfiles/zsh/plugins/

# update installed submodules
df-zsh-plugin-update
```

## profiling

```shell
echo "zmodload zsh/zprof && zprof" > ~/.zshenv
```

Create new zsh session.

Remove file after initialization

```shell
rm ~/.zshenv
```
