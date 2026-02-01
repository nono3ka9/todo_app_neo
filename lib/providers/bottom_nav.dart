import 'package:flutter_riverpod/flutter_riverpod.dart';

// ボトムナビゲーションで、どちらのタブを選んでいるかを表す整数（0か1）を管理対象とするプロバイダ
final intPovider = NotifierProvider<_IntNotifier, int>(() => _IntNotifier());

class _IntNotifier extends Notifier<int> {
  // 管理対象は「state」という変数名でアクセスできる

  @override
  int build() {
    return 0; // state = 0（初期値は0）
  }

  void change(int index) {
    state = index;
  }
}
