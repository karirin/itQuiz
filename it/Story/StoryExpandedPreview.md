# 広域マップ試作

開発者ビルドの「絵本の森」画面でパレットから「試作 · 広域マップ」を選ぶと、縦横1.5倍の地図を確認できます。通常の採用背景はそのまま残しています。

Simulatorでは起動引数 `-StoryImageAdventurePreview -StoryExpandedAdventurePreview` を指定すると広域版を直接開けます。この起動方法は通常の確認用進行とは別の保存領域を使います。

試作画像は ChatGPT imagegen で生成した周辺地形の案です。生成時に元画像の中央固定を指示しましたが、川・滝・海岸の細部は再解釈されたため、元画像とピクセル単位では一致しません。既存の19スポットとルートは ID や進行状態を変えず、地図中央の同じ相対座標へ移しています。新しく広がった周囲には、まだ新しい探索スポットはありません。

描画時は縮小版・中解像度版・高解像度版を倍率で切り替えます。高解像度版は超解像による推定ディテールを含むため、元から存在しない細部まで保証するものではありません。広域表示の操作感と見た目を先に比較し、正式採用時には中央地形を正確に保つ専用の描き足し画像を用意するのが望ましいです。

画像編集のプロンプト:

```text
Use case: precise-object-edit. This is an image OUTPAINTING task. The attached portrait canvas has an existing illustrated fantasy game map occupying the central rectangle and transparent empty margins on all four sides. Fill ONLY the transparent margins to continue the map seamlessly. Treat every pixel of the existing central rectangle as locked: do not redraw, crop, scale, recolor, blur, shift, or reinterpret anything inside it. Preserve the current river, waterfall, mountains, coast, trees, and clearings exactly where they are. In the empty surrounding area extend the northwestern snowy mountains and waterfall watershed, western mixed woodland and grassy passages, eastern turquoise sea and rocky coast, southern river and forest, with varied open terrain suitable for future game spots. Match the exact isometric top-down storybook illustration style, daylight, color and level of detail of the center. Keep the original portrait aspect ratio and centered composition. Full-bleed coherent terrain to every outer edge. No repeated or mirrored patches. No characters, monsters, treasure, buildings, paths, dots, pins, labels, text, border, UI, or watermark.
```
