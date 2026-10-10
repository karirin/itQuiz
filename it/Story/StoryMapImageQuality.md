# 拡大時の背景画質

## 原因と修正

元の画像は1042×1509pxで、2280×3300のワールドを160%まで表示すると、3倍密度の画面では素材の1pxが約10.5pxに引き伸ばされます。現在の採用画像は、元画像の地形を動かさずに超解像した4168×6036pxです。

image_genで高精細な再描画も試しましたが、出力は1042×1509pxで、地形にも細かな差が出たため採用していません。採用画像は元画像にOpenCVのEDSR 4倍超解像を適用したものです。地形の位置と画像比率は維持されますが、超解像による細部は推定結果であり、無限に拡大できるわけではありません。

背景は大きなSwiftUI ViewをscaleEffectで拡大せず、Canvasから画面の描画領域へ直接描きます。補間はhighです。拡大上限はCGImageの実際のピクセル数、地図サイズ、端末のdisplayScaleから計算し、素材1pxあたり最大2画面pxを目安にします。

ドラッグ時の負荷を抑えるため、採用画像には色調整をあらかじめ反映し、広域表示では同じ地形から縮小した2084×3018px版を使います。拡大すると4168×6036px版に切り替わります。画像の読み込みと画面上下の延長用切り出しは各版について一度だけ行い、ドラッグ中には繰り返しません。これは同一画像の解像度違いであり、地図をタイル状に繋げる処理ではありません。

現画像の画質目安となる上限は3倍密度のiPhoneで約122%、2倍密度ではアプリ側の上限160%です。起動時は広域表示のままとし、ドラッグ、ピンチ、＋／−で必要なときだけ拡大できます。画像の比率と画面の比率が異なるため、縮小しても画像は画面を覆う倍率で止まります。

## 背景の差し替え

現在のアセットは `StoryForestWorldPreviewIllustration`。
ファイルは `Assets.xcassets/StoryForestWorldPreviewIllustration.imageset/background.png`（4168×6036px）と、広域表示用の `Assets.xcassets/StoryForestWorldPreviewIllustrationOverview.imageset/background.png`（2084×3018px）。元画像は `Story/SourceArt/StoryForestWorldPreviewIllustration-1042x1509.png` に保管しています。
以前の画像 `StoryForestWorldSharpBackground` と `StoryForestWorldBackground` も残しています。

同じ比率（横38：縦55）の、より大きい画像を差し替えて再ビルドすると、拡大上限が自動で広がります。差し替え時は広域表示用の縮小版も同じ地形から作り直してください。表示範囲や進行データは変わりません。実際のディテールをさらに増やすには、より高解像度の原画が必要です。

3倍密度の画面で160%まで許容するには、この上限計算では最低約5472×7920pxの素材が必要です。大きな画像の導入時にはメモリ使用量も確認してください。

## 比較用の再描画に使ったプロンプト

組み込みimage_genを使用。採用前の1042×1509px画像を編集対象として添付しました。以下の目標サイズはプロンプトに含めた希望値で、返却画像の実寸は1042×1509pxでした。現行アセットには使っていません。

```text
Edit the attached illustrated game world map as a high-resolution production replacement. Preserve the EXACT geography, framing, aspect ratio, coastlines, river course, waterfall, mountains, groves, clearings, colors, lighting and landmark coordinates. Do not shift or recompose any land feature: game markers are placed by existing normalized coordinates. Reconstruct crisp, fine hand-painted details in trees, cliffs, grass and water so the map remains clear when zoomed on a Retina iPhone. Output the largest genuinely detailed portrait image supported, ideally at least 2160 x 3120 pixels, around aspect ratio 1042:1509. Full bleed terrain only. No labels, roads, paths, dots, nodes, pins, characters, monsters, buildings, treasure, UI or border. Avoid blur, smudging, soft focus and oversized brush strokes.
```
