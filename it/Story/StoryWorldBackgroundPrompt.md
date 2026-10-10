# 広域マップの背景画像と操作

> 拡大時の画質対策を追加しました。現在の画像と倍率制限については [StoryMapImageQuality.md](StoryMapImageQuality.md) を参照してください。

「絵本の森」の背景を、山脈・湖・入り江・森林が広がる広域マップへ更新しました。以前の760×1100に対して、表示上の世界は2280×3300で、面積は9倍です。19地点の配置を同じ倍率で広げています。プレイ可能な章・地点数・進行・報酬は共通です。

## 操作

- 1本指のドラッグ：地図を上下左右に移動。
- 2本指のピンチ：拡大・縮小。
- ＋／−：段階的に拡大・縮小。
- 画面に広げる：背景を画面の高さまで広げる。左右にはみ出した部分はドラッグで見られます。
- 現在地：冒険者の位置へ戻り、操作しやすい倍率に戻す。
- 縮小は背景が画面全体を覆う倍率で止まります。画像の左右や上下に隠れた部分は、拡大してドラッグすると確認できます。
- 縮小時の目印をタップ：その地点を選んで拡大。

最大倍率は画像の実際のピクセル数と端末の画素密度から自動計算します（上限160%）。最小倍率はヘッダーとフッターの背後も画像で覆えるよう画面サイズから計算します。画面が非常に縦長で画像の画質上限と競合する場合は、余白を出さない表示を優先します。縮小時は地名と大きなイラストを小さな目印に切り替えます。画像、経路、目印、コマは同じ座標変換で描画します。

## 背景の差し替え

採用した背景画像は `StoryForestWorldPreviewIllustration`、ファイルは `Assets.xcassets/StoryForestWorldPreviewIllustration.imageset/background.png` です。以前の背景 `StoryForestWorldSharpBackground` も開発用の選択肢として残しています。

開発用の候補画像は `StoryForestWorldPreviewWatercolor`（A・水彩ポップ）、`StoryForestWorldPreviewVivid`（C・ビビッドポップ）、`StoryForestWorldPreviewDiorama`（D・ジオラマ風）として残しています。Debugビルドでは、ホームの「絵本の森を冒険する」から開いた画面の上部にパレットが表示され、採用したB・候補A/C/D・以前の背景を切り替えて比較できます。Debug起動引数 `-StoryImageAdventurePreview` で直接開くこともできます。Releaseビルドでは採用したBの背景が表示され、パレットは表示されません。

推奨比率は横38：縦55、目標サイズは2280×3300px以上です。採用した画像の実寸は4168×6036pxです。世界の表示サイズと画像のピクセル数は別で、最大拡大では画像の精細さに限界があります。より高解像度の同じ比率の原画を用意すれば、コードを変えずに差し替えられます。

## 今回の画像生成プロンプト

組み込みのimage_genを使い、旧版の森の画像を画風の参考として添付しました。ChatGPTで使う場合も、旧画像を添付して次のプロンプトを渡してください。

```text
Use case: illustration-story. Create a new expanded world-map background for a mobile adventure game, using the attached forest map only as a visual style and palette reference. This must show a much larger geographic area, about NINE TIMES the land area of the reference. Do not simply enlarge the same trees or upscale the original composition. Pull the map camera far back: hundreds of much smaller trees, many distinct valleys and forests, layered mountain ranges, lakes, river networks, meadows, distant coastlines, and a sense of an enormous explorable country.

Portrait aspect ratio 38:55, target resolution 2280x3300 pixels, as detailed and high-resolution as possible. Full-bleed flat top-down illustrated world map. Keep the elegant watercolor/gouache storybook rendering of the reference, mossy sage-green woods, soft golden grasslands, teal water, and subtle paper grain. This is the terrain-only production asset, NOT an app screenshot or UI concept. No horizon or sky.

Geographic composition: southern half is a sprawling patchwork of sunlit grasslands, groves and small lakes, central region has several green valleys separated by forest ridges, northwestern border has distant rocky mountains, upper region has a mysterious deep forest, northeastern corner has a winding coastline with sheltered bays. Tiny trees, cliffs and waterfalls communicate world scale. Let the central 60% remain mostly connected traversable light-green land. Dense beautiful detail is concentrated along the outer sides and between the large meadow regions. Do not make one enormous empty clearing; show many natural regions linked by grassy valleys.
Keep unobstructed LAND around these normalized gameplay landmarks (x%, y% from top left), each clearing around 5% wide:
(33,84),(39,75),(24,65),(55,63),(43,50),(21,40),(62,40),(69,30),(38,15),(60,5).
A narrow river should cross the point (45,29), which will receive an app-rendered bridge. That river curves from the upper-left through this crossing toward the upper-right coastline. The other listed landmarks must be on land. Avoid large water bodies across the middle of the map.

Exclude all text, labels, letters, numbers, logos, watermarks, roads, dotted paths, grids, tiles, node circles, map pins, characters, monsters, animals, buildings, towns, treasure chests, tents, shrines, bridges, ships, coins, buttons, menus and UI. The app draws all playable routes, landmarks and characters independently over this background. Scenery only.
```

## 検証

`sh Scripts/test-story-adventure.sh` で、既存のゲーム進行と地図の座標・画面比率・拡大率・ドラッグ範囲を検証します。Debug引数 `-StoryImageAdventurePreview` は共通コインへの書き込みを無効にした確認用画面です。
