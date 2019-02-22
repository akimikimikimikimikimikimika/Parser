## Parser

Parserは,ファイルをBase64にエンコードするためのツールです。同時に,ファイルの内容を圧縮することもできます。

### 基本
- ファイルを読み込み,それをBase64形式で変換し,dataスキームのURLを生成。
- 生成したdataスキームURLは,そのまま開くこともできる。
- Base64は,データサイズが元のファイルより133%に膨張するので,データ圧縮を実装している。データ圧縮では,使う上では不自由ない部分を削除する。一部のファイルにおいて有用。

### 使い方
Loadボタンを押してファイルを選択する(又は,直接ファイルをドロップする)と,ファイルが読み込まれる。  
Compressボタンを押すとデータ圧縮のオン/オフが切り替えられる。(オンの時は青色に点灯)  
Dataタブにファイルのソースが表示され,Base64タブにBase64形式のURLを表示する。  
Clearボタンで読み込んだデータを消去する。  
Copyボタンを押すと,直上に表示されたソース或いはBase64のURLをクリップボードにコピーする。  
Openボタンを押すと,URLを開く。  

### データ圧縮
対応言語: HTML, SVG, MathML, CSS, JavaScript, Perl  
JavaScript, Perlでも,文末を適切にセミコロン(;)で終止させていないファイルを圧縮すると,そのソースは実行不能になる。圧縮する前に,このことを確認しなければならない。  
画像や他言語のファイルなど,上に示していないファイルは,dataスキームのURLには変換できますが,圧縮してはならない。画像は開けなくなり,改行/インデントが言語として機能するMarkdownやPythonなどの言語では正常に機能しなくなる。  
コメントアウトは全て削除される。必要な場合は,別途挿入が必要。  

### 特記事項
- JavaScript, CSSを無効にすると利用できない。
- 同じURLでそのままデスクトップでも,モバイルでも利用できる。
- Internet Explorerでは利用できない。
- iOSデバイスでは,ホーム画面にアイコンを追加すると,スタンドアロンで開く。
- iPhone X 対応。
- iOSのChromeでは適切に表示されない。

### シェルコマンド
Parserをシェルコマンドから利用できるようなコードを書いた。以下の“ソースコード”のリンクを開いて表示されるリポジトリ内のCommandline/Parserに実行ファイルを配置した。Swiftで書いた為,おそらくmacOSでしか作動しないと思われる。
#### 使い方
```Shell
Parser [verb] [input] [output]
```
- `[verb]` : 実行アクション
	* x : 何も変換しない
	* b : base64形式のURLに変換する
	* c : 圧縮する
	* bc : 圧縮して,base64形式のURLに変換する
	* help : 使い方を説明する
- `[input]` : 変換するファイルのパス
- `[output]` : 変換した内容を保存するファイルのパス。指定しない場合は,標準出力する
#### 例
```Shell
Parser c Original.html Compressed.html
   # Original.htmlの内容を圧縮して,Compressed.htmlとして保存する
```
#### コンパイル
Swiftソースコードを添えているので,以下のコマンドで自分でもコンパイルできる。
```Shell
cd Commandline
swiftc -o Parser Parser.swift
```

### 更新情報
- Swiftで作成したシェルコマンドの追加
- (エラーを起こさないように)より的確に圧縮できるように改良

### 開く
- [オンライン版](https://akimikimikimikimikimikimika.github.io/Parser/Parser.html "Triangleオンライン版")
- [オフライン版](https://akimikimikimikimikimikimika.github.io/Parser/offline.html "Triangleオフライン版")
- [ソースコード (GitHub)](https://github.com/akimikimikimikimikimikimika/Parser/ "ソースコード")

オンライン版では,全てのコンテンツを組み込み,常に最新の状態で利用できます。  
オフライン版では,オンライン版と同じ体験をオフラインでもできるようにします。URLのdataスキームに全てのソースコードを埋め込んでいるので,一部コンテンツに制限があります。
