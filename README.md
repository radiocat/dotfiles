# dotfiles
----

## 事前にインストールするもの

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



## その他 

* Windowsの場合はvimprocのmakeでエラーが出る。参照⇒https://github.com/Shougo/neobundle.vim#1-install-neobundle


## .gitconfigについて

`.gitconfig.local` を `include` するので初回は以下をホームディレクトリにコピーして作成する。


```
$ cp $HOME/dotfiles/.gitconfig.local ~/.gitconfig.local
```

