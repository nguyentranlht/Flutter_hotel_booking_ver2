import 'package:flutter_riverpod/flutter_riverpod.dart';

// final searchCriteriaProvider =
//     StateNotifierProvider<SearchCriteriaNotifier, SearchCriteria>(
//   (ref) => SearchCriteriaNotifier(),
// );

class SearchCriteria {
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfGuests;

  SearchCriteria({
    required this.startDate,
    required this.endDate,
    required this.numberOfGuests,
  });

  SearchCriteria copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfGuests,
  }) {
    return SearchCriteria(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
    );
  }
}

class SearchCriteriaNotifier extends StateNotifier<SearchCriteria> {
  SearchCriteriaNotifier()
      : super(SearchCriteria(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          numberOfGuests: 1,
        ));

  void update({
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfGuests,
  }) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      numberOfGuests: numberOfGuests,
    );
  }
}

final searchCriteriaProvider = StateProvider<SearchCriteria>((ref) {
  return SearchCriteria(
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 1)),
    numberOfGuests: 1,
  );
});
