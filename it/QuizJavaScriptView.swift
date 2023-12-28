//
//  QuizHtmlCssView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/29.
//

import SwiftUI

struct QuizJavaScriptView: View {
        @Binding var isPresenting: Bool
    
    let QuizJavaScriptList: [QuizQuestion] = [
        QuizQuestion(
            question : "JavaScriptで、指定された要素の最初の子要素を返すプロパティは何か？",
            choices : [
                "firstChild",
                "firstElementChild",
                "lastChild",
                "childNodes"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'firstElementChild' プロパティは指定された要素の最初の子要素を返します。"
        ),

        QuizQuestion(
            question : "JavaScriptで、配列の最後に新しい要素を追加し、新しい長さを返すメソッドは何か？",
            choices : [
                "push",
                "pop",
                "shift",
                "unshift"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'push' メソッドは配列の最後に新しい要素を追加し、新しい長さを返します。"
        ),

        QuizQuestion(
            question : "JavaScriptで、特定の時間遅延後にコードを実行するために使用される関数は何か？",
            choices : [
                "setTimeout",
                "setInterval",
                "clearTimeout",
                "timeDelay"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'setTimeout' 関数は特定の時間遅延後にコードを一度だけ実行します。"
        ),

        QuizQuestion(
            question : "JavaScriptで、特定の文字列が含まれているかどうかをチェックするメソッドは何か？",
            choices : [
                "contains",
                "hasString",
                "includes",
                "findString"
            ],
            correctAnswerIndex : 2,
            explanation : "JavaScriptの 'includes' メソッドは、特定の文字列が含まれているかどうかをチェックします。"
        ),

        QuizQuestion(
            question : "JavaScriptで、イベントのデフォルトの動作を阻止するメソッドは何か？",
            choices : [
                "stopDefault",
                "preventDefault",
                "blockDefault",
                "haltDefault"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'preventDefault' メソッドは、イベントのデフォルトの動作を阻止します。"
        ),

        QuizQuestion(
            question : "JavaScriptで、'this' キーワードがグローバルコンテキストで参照するオブジェクトは何か？",
            choices : [
                "currentElement",
                "window",
                "document",
                "globalObject"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptでは、グローバルコンテキストで 'this' キーワードは 'window' オブジェクトを参照します。"
        ),

        QuizQuestion(
            question : "JavaScriptで、HTML要素のスタイルを動的に変更するために使用されるプロパティは何か？",
            choices : [
                "elementStyle",
                "style",
                "css",
                "htmlStyle"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'style' プロパティを使用して、HTML要素のスタイルを動的に変更できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、指定された要素から特定のクラスを削除するメソッドは何か？",
            choices : [
                "removeClass",
                "deleteClass",
                "remove",
                "classList.remove"
            ],
            correctAnswerIndex : 3,
            explanation : "JavaScriptの 'classList.remove' メソッドを使用して、指定された要素から特定のクラスを削除できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、JSON文字列をJavaScriptオブジェクトに変換するために使用されるメソッドは何か？",
            choices : [
                "JSON.parse",
                "JSON.stringify",
                "JSON.toObject",
                "JSON.toJS"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'JSON.parse' メソッドを使用して、JSON文字列をJavaScriptオブジェクトに変換できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、指定された配列内のすべての要素に対して関数を実行するメソッドは何か？",
            choices : [
                "forEach",
                "every",
                "loop",
                "each"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'forEach' メソッドを使用して、配列内のすべての要素に対して関数を一度ずつ実行できます。"
        ),
        QuizQuestion(
            question : "JavaScriptで、クリックイベントをHTML要素に追加するために使用されるメソッドは何か？",
            choices : [
                "addEventListener",
                "attachEvent",
                "onClick",
                "addClickEvent"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'addEventListener' メソッドを使用して、HTML要素にイベントリスナーを追加できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、配列の要素を一つずつ処理し、単一の出力値を生成するメソッドは何か？",
            choices : [
                "map",
                "filter",
                "reduce",
                "forEach"
            ],
            correctAnswerIndex : 2,
            explanation : "JavaScriptの 'reduce' メソッドを使用して、配列の各要素を処理し、単一の結果値を生成できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、非同期操作を扱うために用いられるオブジェクトは何か？",
            choices : [
                "AsyncFunction",
                "Promise",
                "AsyncAwait",
                "Callback"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'Promise' オブジェクトは、非同期操作の最終的な完了（または失敗）およびその結果の値を表します。"
        ),

        QuizQuestion(
            question : "JavaScriptで、文字列内の特定の文字列を別の文字列に置換するメソッドは何か？",
            choices : [
                "change",
                "replace",
                "swap",
                "alter"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'replace' メソッドを使用して、文字列内の指定された部分を新しい文字列に置換できます。"
        ),
        QuizQuestion(
            question : "JavaScriptで、ウェブページのURLを取得するために使用されるプロパティは何か？",
            choices : [
                "document.URL",
                "window.location",
                "browser.url",
                "location.href"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'window.location' プロパティを使用して、現在のウェブページのURLを取得できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、特定のタイミングでコードを一度だけ実行するために使用されるメソッドは何か？",
            choices : [
                "setInterval",
                "setTimeout",
                "timeFunction",
                "delay"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'setTimeout' メソッドを使用して、指定したミリ秒後にコードを一度だけ実行できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、HTML要素の内容を取得または設定するために使用されるプロパティは何か？",
            choices : [
                "innerText",
                "textContent",
                "htmlContent",
                "innerContent"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'innerText' プロパティを使用して、HTML要素の見えるテキスト内容を取得または設定できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、指定された要素の最初の子要素を取得するために使用されるプロパティは何か？",
            choices : [
                "firstChild",
                "firstElement",
                "firstElementChild",
                "firstNode"
            ],
            correctAnswerIndex : 2,
            explanation : "JavaScriptの 'firstElementChild' プロパティを使用して、指定された要素の最初の子要素を取得できます。"
        ),
        QuizQuestion(
            question : "JavaScriptで、指定した条件が真である間、コードブロックを繰り返し実行するループ構文は何か？",
            choices : [
                "forLoop",
                "while",
                "repeat",
                "doWhile"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'while' ループを使用して、条件が真の間、コードブロックを繰り返し実行できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、複数の値を一つの変数に格納するために使用されるデータ構造は何か？",
            choices : [
                "String",
                "Array",
                "Object",
                "Function"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'Array' を使用して、複数の値を一つの変数に順序付きで格納できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、HTMLドキュメント内の特定の要素をIDによって取得するために使用されるメソッドは何か？",
            choices : [
                "getElementById",
                "querySelector",
                "findElement",
                "getElement"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'getElementById' メソッドを使用して、IDによってHTMLドキュメント内の特定の要素を取得できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、文字列を特定の区切り文字で分割して配列に変換するメソッドは何か？",
            choices : [
                "split",
                "cut",
                "divide",
                "separate"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'split' メソッドを使用して、文字列を特定の区切り文字で分割し、配列に変換できます。"
        ),
        QuizQuestion(
            question : "JavaScriptで、指定した条件が真である間、コードブロックを繰り返し実行するループ構文は何か？",
            choices : [
                "forLoop",
                "while",
                "repeat",
                "doWhile"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'while' ループを使用して、条件が真の間、コードブロックを繰り返し実行できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、複数の値を一つの変数に格納するために使用されるデータ構造は何か？",
            choices : [
                "String",
                "Array",
                "Object",
                "Function"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'Array' を使用して、複数の値を一つの変数に順序付きで格納できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、HTMLドキュメント内の特定の要素をIDによって取得するために使用されるメソッドは何か？",
            choices : [
                "getElementById",
                "querySelector",
                "findElement",
                "getElement"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'getElementById' メソッドを使用して、IDによってHTMLドキュメント内の特定の要素を取得できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、文字列を特定の区切り文字で分割して配列に変換するメソッドは何か？",
            choices : [
                "split",
                "cut",
                "divide",
                "separate"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'split' メソッドを使用して、文字列を特定の区切り文字で分割し、配列に変換できます。"
        ),
        QuizQuestion(
            question : "JavaScriptで、ブラウザのコンソールにメッセージを出力するために使用されるメソッドは何か？",
            choices : [
                "print",
                "log",
                "write",
                "display"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'console.log' メソッドを使用して、開発者コンソールにメッセージを出力できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、指定された条件が偽である間、コードブロックを実行するループ構文は何か？",
            choices : [
                "while",
                "doWhile",
                "for",
                "repeatUntil"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'do...while' ループを使用して、条件が偽の間、コードブロックを実行できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、オブジェクトに新しいプロパティを追加するために使用されるキーワードは何か？",
            choices : [
                "new",
                "create",
                "add",
                "define"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'new' キーワードを使用して、新しいオブジェクトを作成し、プロパティを追加できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、指定された関数を配列の各要素に対して一度だけ実行するメソッドは何か？",
            choices : [
                "map",
                "forEach",
                "filter",
                "reduce"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'map' メソッドを使用して、配列内の各要素に対して指定された関数を一度ずつ実行し、新しい配列を作成できます。"
        ),QuizQuestion(
            question : "JavaScriptで、変数のデータ型を判定するために使用される演算子は何か？",
            choices : [
                "typeof",
                "instanceof",
                "getType",
                "dataType"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'typeof' 演算子を使用して、変数のデータ型を判定できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、指定した文字列が特定の文字列で終わるかどうかを判定するメソッドは何か？",
            choices : [
                "endsWith",
                "startsWith",
                "contains",
                "hasSuffix"
            ],
            correctAnswerIndex : 0,
            explanation : "JavaScriptの 'endsWith' メソッドを使用して、文字列が特定の文字列で終わるかどうかを判定できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、関数宣言の代わりに匿名関数を作成するために使用される関数は何か？",
            choices : [
                "lambda",
                "arrowFunction",
                "anonymous",
                "functionExpression"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptのアロー関数（arrow function）を使用して、名前のない関数式を作成できます。"
        ),

        QuizQuestion(
            question : "JavaScriptで、HTML要素のクラスリストに新しいクラスを追加するメソッドは何か？",
            choices : [
                "addClass",
                "classList.add",
                "insertClass",
                "appendClass"
            ],
            correctAnswerIndex : 1,
            explanation : "JavaScriptの 'classList.add' メソッドを使用して、HTML要素のクラスリストに新しいクラスを追加できます。"
        )



    ]
        
        
        @State private var shuffledQuizList: [QuizQuestion]
        private var authManager = AuthManager()
        private var audioManager = AudioManager.shared
        
        init(isPresenting: Binding<Bool>) {
            _isPresenting = isPresenting
            _shuffledQuizList = State(initialValue: QuizJavaScriptList.shuffled())
        }
    @StateObject var sharedInterstitial = Interstitial()
        var body: some View {
            QuizView(quizzes: shuffledQuizList, quizLevel: .advanced, authManager: authManager,audioManager: audioManager, isPresenting: $isPresenting, interstitial: sharedInterstitial)
        }
    }


#Preview {
    QuizJavaScriptView(isPresenting: .constant(false))
}
