# crystal_othello
CUIのオセロ
[Rubyで作成したもの](https://github.com/umaz/ruby_othello)のCrystal版
## crystalのコンパイル
`crystal build --release main.cr`

## モード
1. COMと対戦
2. 2人で対戦
3. COMの対戦を観戦

## COMのレベル
1. ランダム
2. スコアの高くなるマスに打つ
3. 返したスコアが高くなるマスに打つ
4. Lv3の評価方法で5手先まで読む
5. 基本はLv4で48手目以降は読み切る

## 詳細(Ruby版)
https://scrapbox.io/umaz/Rubyでオセロ~その1~
