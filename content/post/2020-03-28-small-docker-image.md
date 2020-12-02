---
title: Dockerイメージ縮小オタク
canonical: https://coordination.hatenablog.com/entry/2020/03/28/234717
---

おはようございます！！！[coord_e](https://twitter.com/coord_e)です、よろしくどうぞ。

## 動機

Docker イメージが小さくなると → 嬉しい！^[よかったですね]

## 一般的なテク

### multi-stage build

[embed](https://docs.docker.com/develop/develop-images/multistage-build/ "Use multi-stage builds"){ description="Keeping your images small with multi-stage images" }

ビルド環境とか最終的なイメージには必要ないんで…ビルドした後、必要なものだけ最終的なイメージに引っ張ってきます。

### upx

[embed](https://upx.github.io/ "UPX: the Ultimate Packer for eXecutables"){ description="UPX homepage: the Ultimate Packer for eXecutables " }

バイナリ詰めるマン。なんでかバイナリサイズが 1/10 とかになる^[やりすぎると常に 255 を返すハリボテになったり並列実行したときに限り低確率で異常終了する不思議な物体になったりすることがあるので、オプションは-9 ぐらいで止めておくといい]。普通に怖い

## スムーズに本題に入るためにまずシングルバイナリを否定します。シングルバイナリを否定してもいいですか？シングルバイナリがかわいそうですが…

シングルバイナリ作るのしんどくないですか？しんどいですね。みんながみんな Go を書いているわけではないので…あとソースコードが手元にない場合とかはもうどうしようもないですね。

実は、シングルバイナリを作らず極小 Docker イメージを作る方法があるんです！^[いかがでしたか？]

### 実行に必要なものをリストアップしよう

シェル芸をな^[`Dockerfile` はシェル芸が正当化できるので好きです]

大体の場合、実行に必要なものは実行ファイルそれ自体と動的リンクされたライブラリ、そして動的リンカ（プログラムインタプリタ）です^[他に必要なものがあったらこのリストに追加していけばいいです]。前者は ldd(1)で、後者は readelf(1)でそれぞれ取得します。

```bash
{ \
      echo "/path/to/your/executable"; \
      readelf -l "/path/to/your/executable" \
        | grep "program interpreter" \
        | sed -e 's/^.*: \(.*\)\]$/\1/'; \
      ldd "/path/to/your/executable" \
        | awk -F'=>' '{print $2}' \
        | sed -e 's/(.*)//' -e '/^\s*$/d' \
        | awk '{$1=$1};1'; \
}
```

おそらくリンクが混ざっているので、次のコマンドにパイプして^[`xargs` → `bash -c` コンボ嫌いなんですけどもっといい方法知りませんか？]リンク元とリンク先を両方ともリストに加えてやります。

```bash
xargs -I{} bash -c "echo {}; readlink -f {};"
```

これで実行に必要なファイルのリストができました！あとはこれを次のコマンドにパイプして、全ての必要なファイルを一つのディレクトリに詰めます。

```bash
xargs -I{} cp -r --parents {} /bundle
```

いいですね。では†次のステージ†へ…

```dockerfile
FROM scratch
COPY --from=0 /bundle/ /.
```

必要なものは全部 `/bundle/` に入ってるので、ベースイメージは`scratch`です^[`/bundle/`に突っ込んだファイルを必ず使いに行くようにしているわけではないので、`alpine`とかにするとうまく動かないことが多い]。 `COPY` でさっき`/bundle`にコピーしたファイル達を `/` に展開して…終了！

## 実例

[HLint](https://github.com/ndmitchell/hlint)という Haskell の Lint ツールのイッミジを作ってみます。Haskell 製のツールで、シングルバイナリを作るのがちょっとめんどくさい^[HLint のリリース、普通に動的リンクされたバイナリで配布されててそういうのもあるんだってなった]、なので今回の食材にぴったり。…では、出来上がった Dockerfile がこちらです！

```dockerfile
FROM haskell:8

RUN cabal new-update

# install
ARG INSTALL_DIR=/usr/bin
RUN cabal new-install hlint-2.2.11 --installdir "${INSTALL_DIR}" --install-method copy

# prepare for compression
WORKDIR /tmp
ADD https://github.com/upx/upx/releases/download/v3.95/upx-3.95-amd64_linux.tar.xz upx.tar.xz
RUN tar --strip-components=1 -xf upx.tar.xz && mv upx /usr/bin/

# compress executable
RUN cp "${INSTALL_DIR}/hlint" /tmp/hlint_copy
RUN upx -q -9 --brute "${INSTALL_DIR}/hlint"

# collect runtime dependencies
RUN { \
      echo "${INSTALL_DIR}/hlint"; \
      echo "$(which git)"; \
      readelf -l /tmp/hlint_copy \
        | grep "program interpreter" \
        | sed -e 's/^.*: \(.*\)\]$/\1/'; \
      { ldd /tmp/hlint_copy; ldd $(which git); } \
        | awk -F'=>' '{print $2}' \
        | sed -e 's/(.*)//' -e '/^\s*$/d' \
        | awk '{$1=$1};1'; \
    } | xargs -I{} bash -c "echo {}; readlink -f {};" \
      | xargs -I{} cp -r --parents {} /bundle

# copy
FROM scratch
COPY --from=0 /bundle/ /.

WORKDIR /work
CMD ["${INSTALL_DIR}/hlint"]
```

`hlint`には`--git`オプションがあって、`git`管理対象のファイルのみに lint を行うといったことができます。そこそこ便利なので、`--git`オプションが使えるように上の Dockerfile では`git`を同梱しています。このように必要なものをザクザク足していくことも、できるんですね（小並感）。でも、イメージサイズは？はい、こちらになります！

```
$ docker image ls
…
coorde/hlint    2.2.11   662fad71d2d6    4 weeks ago    13.6MB
…
```

小さめで嬉しいですね。今回作った[coorde/hlint](https://hub.docker.com/r/coorde/hlint)はボクがバイト先で作っているソフトウェアの CI 上でブンブン働いています。

## まとめ

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">Dockerで…どっかーんwwwwwwwwwwww</p>&mdash; coord_e (@coord_e) <a href="https://twitter.com/coord_e/status/1241690386071863298?ref_src=twsrc%5Etfw">March 22, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 参考文献

- [larsks/dockerize: A tool for creating minimal docker images from dynamic ELF binaries.](https://github.com/larsks/dockerize)
- [List binary dependencies to build a minimal docker image from scratch · GitHub](https://gist.github.com/bcardiff/85ae47e66ff0df35a78697508fcb49af)
- [How to create the smallest possible docker container of any image — Xebia Blog](https://xebia.com/blog/how-to-create-the-smallest-possible-docker-container-of-any-image/)
- [Creating minimal Docker images from dynamically linked ELF binaries · The Odd Bit](https://blog.oddbit.com/post/2015-02-05-creating-minimal-docker-images/)
