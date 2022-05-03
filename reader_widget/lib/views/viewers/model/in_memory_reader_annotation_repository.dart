import 'package:dartx/dartx.dart';
import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class InMemoryReaderAnnotationRepository extends ReaderAnnotationRepository {
  int _currentId = 0;
  final List<ReaderAnnotation> annotations = [];

  @override
  Future<List<ReaderAnnotation>> allWhere(
          {Predicate<ReaderAnnotation> predicate =
              const AcceptAllPredicate()}) async =>
      annotations.where(predicate.test).toList();

  @override
  Future<ReaderAnnotation> createBookmark(PaginationInfo paginationInfo) async {
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
        "$_currentId", paginationInfo.locator.json, AnnotationType.bookmark);
    _currentId++;
    annotations.add(readerAnnotation);
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation> createHighlight(
      Locator locator, HighlightStyle style, int tint) async {
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
      "$_currentId",
      locator.json,
      AnnotationType.highlight,
      style: style,
      tint: tint,
    );
    _currentId++;
    annotations.add(readerAnnotation);
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation?> get(String id) async =>
      annotations.firstOrNullWhere((element) => element.id == id);

  @override
  void save(ReaderAnnotation readerAnnotation) {}

  @override
  Future<void> delete(List<String> deletedIds) async {
    annotations.removeWhere((element) => deletedIds.contains(element.id));
    super.delete(deletedIds);
  }
}
