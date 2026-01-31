# dotfiles
----

## 事前にインストールするもの

* Git

Windows環境

```
winget install --id Git.Git -e --source winget
```



* Vim本体
* NeoBundle https://github.com/Shougo/neobundle.vim#1-install-neobundle

### Vimのcolorスキームを取得する

```
$ cd ~/.vim
$ mkdir tmp
$ mkdir colors
$ cd colors
$ curl -fsSLO https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim
$ curl -fsSLO https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim
```


### その他 

* Windowsの場合はvimprocのmakeでエラーが出る。参照⇒https://github.com/Shougo/neobundle.vim#1-install-neobundle

## bashの設定

```bash
$ echo "test -r ~/.bashrc && . ~/.bashrc" >> ~/.bash_profile
```

## zshの設定

* zsh `brew install zsh`
* oh-my-zsh https://github.com/robbyrussell/oh-my-zsh
* oh-my-zsh が作成した `.zshrc` に追加

```bash
$ cat zsh/zshrc.additional >> ~/.zshrc
```

↓を参考にテーマの書き換え
https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

```
 ZSH_THEME="gnzh"
```

## .gitconfigについて

`.gitconfig.local` を `include` するので初回は以下をホームディレクトリにコピーして作成する。


```
$ cp $HOME/dotfiles/.gitconfig.local ~/.gitconfig.local
```

