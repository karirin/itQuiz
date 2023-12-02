//
//  QuizHtmlCssView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/29.
//

import SwiftUI

struct QuizHtmlCssView: View {
        @Binding var isPresenting: Bool
    
    let QuizHtmlCssList: [QuizQuestion] = [
        QuizQuestion(
            question : "HTML文書で、画像を挿入するために使用されるタグは何か？",
            choices : [
                "<img>",
                "<picture>",
                "<image>",
                "<graphics>"
            ],
            correctAnswerIndex : 0,
            explanation : "<img> タグは、HTML文書に画像を挿入するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、文字の色を指定するプロパティは何か？",
            choices : [
                "font-color",
                "text-color",
                "color",
                "font-style"
            ],
            correctAnswerIndex : 2,
            explanation : "CSSの 'color' プロパティは文字の色を指定するために使用されます。"
        ),

        QuizQuestion(
            question : "HTMLで、リストアイテムを非順序付けリストとしてマークするために使用されるタグは何か？",
            choices : [
                "<ul>",
                "<ol>",
                "<li>",
                "<dl>"
            ],
            correctAnswerIndex : 0,
            explanation : "<ul> タグは非順序付けリスト（Unordered List）のアイテムをマークするために使用されます。"
        ),

        QuizQuestion(
            question : "CSSにおいて、要素の外側の余白を設定するプロパティは何か？",
            choices : [
                "margin",
                "padding",
                "border",
                "width"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'margin' プロパティは要素の外側の余白を設定します。"
        ),
        QuizQuestion(
            question : "HTMLで、文書のセクションを定義するタグは何か？",
            choices : [
                "<div>",
                "<span>",
                "<section>",
                "<article>"
            ],
            correctAnswerIndex : 2,
            explanation : "<section> タグは、文書のセクションを定義するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の幅を設定するプロパティは何か？",
            choices : [
                "margin",
                "padding",
                "width",
                "border"
            ],
            correctAnswerIndex : 2,
            explanation : "CSSの 'width' プロパティは要素の幅を設定します。"
        ),

        QuizQuestion(
            question : "HTMLで、順序付けリストを作成するために使用されるタグは何か？",
            choices : [
                "<ul>",
                "<ol>",
                "<li>",
                "<dl>"
            ],
            correctAnswerIndex : 1,
            explanation : "<ol> タグは順序付けリスト（Ordered List）を作成するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の背景色を設定するプロパティは何か？",
            choices : [
                "color",
                "background-color",
                "border-color",
                "text-color"
            ],
            correctAnswerIndex : 1,
            explanation : "CSSの 'background-color' プロパティは要素の背景色を設定します。"
        ),

        QuizQuestion(
            question : "HTMLで、独立したコンテンツを定義するタグは何か？",
            choices : [
                "<article>",
                "<section>",
                "<div>",
                "<header>"
            ],
            correctAnswerIndex : 0,
            explanation : "<article> タグは独立したコンテンツを定義するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、フォントの大きさを設定するプロパティは何か？",
            choices : [
                "font-size",
                "text-size",
                "font-weight",
                "text-style"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'font-size' プロパティはフォントの大きさを設定します。"
        ),

        QuizQuestion(
            question : "HTMLで、表を作成するためのタグは何か？",
            choices : [
                "<table>",
                "<tr>",
                "<td>",
                "<th>"
            ],
            correctAnswerIndex : 0,
            explanation : "<table> タグは表を作成するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の境界線を設定するプロパティは何か？",
            choices : [
                "border",
                "margin",
                "padding",
                "outline"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'border' プロパティは要素の境界線を設定します。"
        ),
        QuizQuestion(
            question : "HTMLで、ウェブページの見出しを表すタグは何か？",
            choices : [
                "<header>",
                "<h1>",
                "<title>",
                "<head>"
            ],
            correctAnswerIndex : 1,
            explanation : "<h1> から <h6> までのタグは、ウェブページの見出しを表します。"
        ),

        QuizQuestion(
            question : "CSSで、要素に影を追加するために使用されるプロパティは何か？",
            choices : [
                "shadow",
                "box-shadow",
                "text-shadow",
                "border-shadow"
            ],
            correctAnswerIndex : 1,
            explanation : "CSSの 'box-shadow' プロパティは要素に影を追加するために使用されます。"
        ),

        QuizQuestion(
            question : "HTMLで、フォームのテキスト入力欄を作成するためのタグは何か？",
            choices : [
                "<input type='text'>",
                "<textfield>",
                "<textbox>",
                "<input type='textbox'>"
            ],
            correctAnswerIndex : 0,
            explanation : "<input type='text'> タグは、フォームのテキスト入力欄を作成するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の最大幅を設定するプロパティは何か？",
            choices : [
                "max-width",
                "min-width",
                "width",
                "fixed-width"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'max-width' プロパティは要素の最大幅を設定します。"
        ),

        QuizQuestion(
            question : "HTMLで、強調されたテキストを表すタグは何か？",
            choices : [
                "<em>",
                "<strong>",
                "<b>",
                "<i>"
            ],
            correctAnswerIndex : 0,
            explanation : "<em> タグはテキストの強調（イタリック体）を表します。"
        ),

        QuizQuestion(
            question : "CSSで、要素をフレックスボックスとして配置するために使用されるプロパティは何か？",
            choices : [
                "display: flex",
                "flexbox",
                "flex-display",
                "box-flex"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'display: flex' プロパティは要素をフレックスボックスとして配置します。"
        ),

        QuizQuestion(
            question : "HTMLで、別のウェブページへのリンクを作成するためのタグは何か？",
            choices : [
                "<a href='url'>",
                "<link>",
                "<href>",
                "<navigate>"
            ],
            correctAnswerIndex : 0,
            explanation : "<a href='url'> タグは、別のウェブページへのリンクを作成するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の不透明度を設定するプロパティは何か？",
            choices : [
                "opacity",
                "transparent",
                "visibility",
                "alpha"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'opacity' プロパティは要素の不透明度を設定します。"
        ),
        QuizQuestion(
            question : "HTMLで、ウェブページに音声やビデオを埋め込むために使用されるタグは何か？",
            choices : [
                "<media>",
                "<audio>",
                "<video>",
                "<sound>"
            ],
            correctAnswerIndex : 2,
            explanation : "<video> タグは、ウェブページにビデオを埋め込むために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素をグリッドレイアウトとして配置するために使用されるプロパティは何か？",
            choices : [
                "display: grid",
                "grid-layout",
                "display: flex-grid",
                "grid-display"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'display: grid' プロパティは要素をグリッドレイアウトとして配置します。"
        ),

        QuizQuestion(
            question : "HTMLで、ドキュメントのメタデータを指定するために使用されるタグは何か？",
            choices : [
                "<meta>",
                "<data>",
                "<info>",
                "<metadata>"
            ],
            correctAnswerIndex : 0,
            explanation : "<meta> タグはドキュメントのメタデータ（例えば文字セット、ビューポートの設定、説明文など）を指定するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、複数の列でのテキストのレイアウトを指定するために使用されるプロパティは何か？",
            choices : [
                "columns",
                "multi-column",
                "text-columns",
                "column-layout"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'columns' プロパティは複数の列でのテキストのレイアウトを指定します。"
        ),

        QuizQuestion(
            question : "HTMLで、ウェブページの一部分に独立したコンテンツを埋め込むために使用されるタグは何か？",
            choices : [
                "<embed>",
                "<iframe>",
                "<frame>",
                "<insert>"
            ],
            correctAnswerIndex : 1,
            explanation : "<iframe> タグは、ウェブページの一部分に別のHTMLページを埋め込むために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の位置を固定するために使用されるプロパティは何か？",
            choices : [
                "position: fixed",
                "fixed-position",
                "position: static",
                "position: absolute"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'position: fixed' プロパティは要素の位置をビューポートに対して固定します。"
        ),

        QuizQuestion(
            question : "HTMLで、異なるドキュメントセクションを識別するために使用されるタグは何か？",
            choices : [
                "<section>",
                "<div>",
                "<header>",
                "<main>"
            ],
            correctAnswerIndex : 1,
            explanation : "<div> タグは、異なるドキュメントセクションを識別するための汎用コンテナです。"
        ),

        QuizQuestion(
            question : "CSSで、リストアイテムのマーカースタイルを設定するために使用されるプロパティは何か？",
            choices : [
                "list-style",
                "list-marker",
                "list-type",
                "list-style-type"
            ],
            correctAnswerIndex : 3,
            explanation : "CSSの 'list-style-type' プロパティはリストアイテムのマーカースタイル（例えばディスク、サークル、スクエアなど）を設定します。"
        ),

        QuizQuestion(
            question : "HTMLで、同一ページ内でのリンクを作成するために使用される属性は何か？",
            choices : [
                "href",
                "src",
                "link",
                "anchor"
            ],
            correctAnswerIndex : 0,
            explanation : "'href' 属性は、同一ページ内の特定のセクションへのリンクを作成するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、テキストの配置を指定するプロパティは何か？",
            choices : [
                "text-align",
                "align-text",
                "text-alignement",
                "text-position"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'text-align' プロパティはテキストの水平方向の配置（例：left、right、center）を指定します。"
        ),

        QuizQuestion(
            question : "HTMLで、ページのフッターを定義するタグは何か？",
            choices : [
                "<footer>",
                "<bottom>",
                "<end>",
                "<foot>"
            ],
            correctAnswerIndex : 0,
            explanation : "<footer> タグはページのフッター部分を定義します。"
        ),

        QuizQuestion(
            question : "CSSで、リストアイテムのマーカーを非表示にするために使用されるプロパティは何か？",
            choices : [
                "list-style-type: none",
                "list-marker: none",
                "list-style: none",
                "list-display: none"
            ],
            correctAnswerIndex : 2,
            explanation : "CSSの 'list-style: none' プロパティはリストアイテムのマーカーを非表示にします。"
        ),

        QuizQuestion(
            question : "HTMLで、ページ内のナビゲーションリンクをグループ化するために使用されるタグは何か？",
            choices : [
                "<nav>",
                "<navigation>",
                "<links>",
                "<navigate>"
            ],
            correctAnswerIndex : 0,
            explanation : "<nav> タグはページ内のナビゲーションリンクをグループ化するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の高さを設定するプロパティは何か？",
            choices : [
                "height",
                "size",
                "length",
                "height-size"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'height' プロパティは要素の高さを設定します。"
        ),

        QuizQuestion(
            question : "HTMLで、ブラウザにページのタイトルを表示するタグは何か？",
            choices : [
                "<title>",
                "<head>",
                "<header>",
                "<top>"
            ],
            correctAnswerIndex : 0,
            explanation : "<title> タグはブラウザのタブやウィンドウのタイトルバーにページのタイトルを表示します。"
        ),

        QuizQuestion(
            question : "CSSで、フォントスタイルをイタリックに設定するプロパティは何か？",
            choices : [
                "font-style: italic",
                "font-type: italic",
                "text-style: italic",
                "font-italic: true"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'font-style: italic' プロパティはフォントスタイルをイタリックに設定します。"
        ),
        QuizQuestion(
            question : "HTMLで、ページの著者や説明などの情報を含むセクションを表すタグは何か？",
            choices : [
                "<meta>",
                "<head>",
                "<header>",
                "<information>"
            ],
            correctAnswerIndex : 1,
            explanation : "<head> タグはページのメタデータ（著者、説明、タイトルなど）を含むセクションを表します。"
        ),

        QuizQuestion(
            question : "CSSで、リンクの様々な状態（通常、ホバー、アクティブ）にスタイルを適用するために使用される擬似クラスは何か？",
            choices : [
                ":link, :hover, :active",
                ":normal, :mouseover, :click",
                ":standard, :onmouse, :pressed",
                ":default, :over, :activated"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの ':link', ':hover', ':active' 擬似クラスはリンクの様々な状態にスタイルを適用します。"
        ),

        QuizQuestion(
            question : "HTMLで、入力フォームの一部としてチェックボックスを作成するために使用されるタグは何か？",
            choices : [
                "<input type='checkbox'>",
                "<checkbox>",
                "<check>",
                "<box>"
            ],
            correctAnswerIndex : 0,
            explanation : "<input type='checkbox'> タグはフォーム内でチェックボックスを作成するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の縁取り（アウトライン）を指定するために使用されるプロパティは何か？",
            choices : [
                "outline",
                "border",
                "edge",
                "frame"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'outline' プロパティは要素の縁取りを指定します。"
        ),

        QuizQuestion(
            question : "HTMLで、文章の段落を定義するために使用されるタグは何か？",
            choices : [
                "<paragraph>",
                "<text>",
                "<p>",
                "<para>"
            ],
            correctAnswerIndex : 2,
            explanation : "<p> タグは文章の段落を定義するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の水平方向の中央揃えを行う一般的な方法は何か？",
            choices : [
                "text-align: center",
                "align: horizontal",
                "margin: 0 auto",
                "center: horizontal"
            ],
            correctAnswerIndex : 2,
            explanation : "CSSで 'margin: 0 auto' を使用すると、要素は水平方向に中央揃えされます。"
        ),

        QuizQuestion(
            question : "HTMLで、別のウェブページへのリンクを新しいブラウザタブで開くようにするために使用される属性は何か？",
            choices : [
                "target='_blank'",
                "new='tab'",
                "open='new'",
                "href='new'"
            ],
            correctAnswerIndex : 0,
            explanation : "'target='_blank'' 属性は、リンクを新しいブラウザタブで開くために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の表示を非表示にするために使用されるプロパティは何か？",
            choices : [
                "visibility: hidden",
                "display: none",
                "hidden",
                "invisible"
            ],
            correctAnswerIndex : 1,
            explanation : "CSSの 'display: none' プロパティは要素の表示を非表示にします。"
        ),
        QuizQuestion(
            question : "HTMLで、ウェブページ内で動画や音楽などのメディアコンテンツを埋め込むために使用されるタグは何か？",
            choices : [
                "<media>",
                "<audio>",
                "<embed>",
                "<multimedia>"
            ],
            correctAnswerIndex : 2,
            explanation : "<embed> タグはウェブページ内で動画や音楽などのメディアコンテンツを埋め込むために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の背景画像を設定するために使用されるプロパティは何か？",
            choices : [
                "background-image",
                "background",
                "image",
                "background-src"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'background-image' プロパティは要素の背景画像を設定します。"
        ),

        QuizQuestion(
            question : "HTMLで、ウェブページのタイトルバーに表示されるアイコンを指定するために使用されるタグは何か？",
            choices : [
                "<icon>",
                "<favicon>",
                "<link rel='icon'>",
                "<img rel='icon'>"
            ],
            correctAnswerIndex : 2,
            explanation : "<link rel='icon'> タグはウェブページのタイトルバーに表示されるアイコン（ファビコン）を指定するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の背景画像が繰り返されないように設定するために使用されるプロパティは何か？",
            choices : [
                "background-repeat: no-repeat",
                "background-no-repeat",
                "no-repeat",
                "repeat-none"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'background-repeat: no-repeat' プロパティは背景画像が繰り返されないように設定します。"
        ),

        QuizQuestion(
            question : "HTMLで、長い文章やコンテンツの一部分を隠し、必要に応じて表示するために使用されるタグは何か？",
            choices : [
                "<details>",
                "<summary>",
                "<hidden>",
                "<collapse>"
            ],
            correctAnswerIndex : 0,
            explanation : "<details> タグは長い文章やコンテンツの一部分を隠し、必要に応じて表示するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、テキストの太字表示を指定するために使用されるプロパティは何か？",
            choices : [
                "font-weight: bold",
                "text-bold",
                "bold",
                "font-bold"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'font-weight: bold' プロパティはテキストの太字表示を指定します。"
        ),

        QuizQuestion(
            question : "HTMLで、ページ内の異なるセクションに簡単にナビゲートするために使用される要素は何か？",
            choices : [
                "<navigate>",
                "<anchor>",
                "<a href='#section'>",
                "<link>"
            ],
            correctAnswerIndex : 2,
            explanation : "<a href='#section'> 要素はページ内の異なるセクションに簡単にナビゲートするために使用されます。"
        ),
        QuizQuestion(
            question : "HTMLで、入力されたデータをサーバーに送信するフォームを作成するために使用されるタグは何か？",
            choices : [
                "<form>",
                "<input>",
                "<submit>",
                "<send>"
            ],
            correctAnswerIndex : 0,
            explanation : "<form> タグは入力されたデータをサーバーに送信するフォームを作成するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の相対的な位置を指定するために使用されるプロパティは何か？",
            choices : [
                "position: relative",
                "position: absolute",
                "position: fixed",
                "position: static"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'position: relative' プロパティは要素の相対的な位置を指定します。"
        ),

        QuizQuestion(
            question : "HTMLで、ドキュメントのメインコンテンツを囲むために使用されるセマンティックタグは何か？",
            choices : [
                "<main>",
                "<body>",
                "<content>",
                "<section>"
            ],
            correctAnswerIndex : 0,
            explanation : "<main> タグはドキュメントのメインコンテンツを囲むために使用されるセマンティックタグです。"
        ),

        QuizQuestion(
            question : "CSSで、マウスオーバー時にリンクの色を変更するために使用される擬似クラスは何か？",
            choices : [
                ":hover",
                ":active",
                ":focus",
                ":visited"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの ':hover' 擬似クラスはマウスオーバー時にリンクの色を変更するために使用されます。"
        ),

        QuizQuestion(
            question : "HTMLで、別のHTMLドキュメントを現在のドキュメントに埋め込むために使用されるタグは何か？",
            choices : [
                "<iframe>",
                "<frame>",
                "<embed>",
                "<insert>"
            ],
            correctAnswerIndex : 0,
            explanation : "<iframe> タグは別のHTMLドキュメントを現在のドキュメントに埋め込むために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の左右の余白を自動的に調整して中央揃えを行う方法は何か？",
            choices : [
                "margin: auto",
                "align: center",
                "justify-content: center",
                "text-align: center"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSで 'margin: auto' を使用すると、要素の左右の余白が自動的に調整され、中央揃えが行われます。"
        ),

        QuizQuestion(
            question : "HTMLで、メールアドレス入力フィールドを作成するために使用されるタグは何か？",
            choices : [
                "<input type='email'>",
                "<email>",
                "<mail>",
                "<input type='mail'>"
            ],
            correctAnswerIndex : 0,
            explanation : "<input type='email'> タグはメールアドレス入力フィールドを作成するために使用されます。"
        ),

        QuizQuestion(
            question : "CSSで、要素の上部に外側の余白を追加するために使用されるプロパティは何か？",
            choices : [
                "margin-top",
                "padding-top",
                "top",
                "border-top"
            ],
            correctAnswerIndex : 0,
            explanation : "CSSの 'margin-top' プロパティは要素の上部に外側の余白を追加します。"
        )

        ]
        
        
        @State private var shuffledQuizList: [QuizQuestion]
        private var authManager = AuthManager()
        private var audioManager = AudioManager.shared
        
        init(isPresenting: Binding<Bool>) {
            _isPresenting = isPresenting
            _shuffledQuizList = State(initialValue: QuizHtmlCssList.shuffled())
        }
    @StateObject var sharedInterstitial = Interstitial()
        var body: some View {
            QuizView(quizzes: shuffledQuizList, quizLevel: .advanced, authManager: authManager,audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
        }
    }


#Preview {
    QuizHtmlCssView(isPresenting: .constant(false))
}
