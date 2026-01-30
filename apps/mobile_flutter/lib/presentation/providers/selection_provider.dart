import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selection_provider.g.dart';

@riverpod
class SelectionNotifier extends _$SelectionNotifier {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void verifySelection(List<String> visibleIds) {
      // Optional: remove hidden ids?
      // No, keep selection persistent
  }

  void selectAll(List<String> ids) {
      state = {...state, ...ids};
  }

  void clear() {
    state = {};
  }
  
  bool isSelected(String id) => state.contains(id);
  
  int get count => state.length;
}
