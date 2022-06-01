import 'package:dfunc/dfunc.dart' hide Predicate;
import 'package:iridium_app/database/locator_helper.dart';
import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';
import 'package:uuid/uuid.dart';

class LocatorReaderAnnotationRepository extends ReaderAnnotationRepository {
  final Uuid uuid = const Uuid();
  final LocatorDB locatorDB;
  final String bookId;

  LocatorReaderAnnotationRepository._(this.bookId, this.locatorDB);

  static Future<LocatorReaderAnnotationRepository>
      createLocatorReaderAnnotationRepository(String bookId) async =>
          LocatorReaderAnnotationRepository._(
              bookId, await LocatorDB.createLocatorDB());

  @override
  Future<List<ReaderAnnotation>> allWhere(
      {Predicate<ReaderAnnotation> predicate =
          const AcceptAllPredicate()}) async {
    List<Map<String, dynamic>> annotations = await locatorDB.getLocator(bookId);
    return annotations
        .map(ReaderAnnotation.fromJson)
        .where(predicate.test)
        .toList();
  }

  @override
  Future<ReaderAnnotation> savePosition(PaginationInfo paginationInfo) async {
    ReaderAnnotation? position = await getPosition();
    if (position != null) {
      await delete([position.id]);
    }
    String id = uuid.v1();
    position = ReaderAnnotation(
        id, bookId, paginationInfo.locator.json, AnnotationType.position);
    await locatorDB.add(position.toJson());
    return position;
  }

  @override
  Future<ReaderAnnotation?> getPosition() async {
    Map<String, dynamic>? annotation =
        await locatorDB.findByBookAndType(bookId, AnnotationType.position);
    return annotation
        ?.let((it) => (it.isNotEmpty) ? ReaderAnnotation.fromJson(it) : null);
  }

  @override
  Future<ReaderAnnotation> createBookmark(PaginationInfo paginationInfo) async {
    String id = uuid.v1();
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
        id, bookId, paginationInfo.locator.json, AnnotationType.bookmark);
    await locatorDB.add(readerAnnotation.toJson());
    notifyBookmark(readerAnnotation);
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation> createHighlight(
      PaginationInfo? paginationInfo,
      Locator locator,
      HighlightStyle style,
      int tint,
      String? annotation) async {
    String id = uuid.v1();
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
      id,
      bookId,
      locator.json,
      AnnotationType.highlight,
      style: style,
      tint: tint,
      annotation: annotation,
    );
    await locatorDB.add(readerAnnotation.toJson());
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation?> get(String id) async {
    Map<String, dynamic>? annotation = await locatorDB.findById(id);
    return annotation?.let((it) => ReaderAnnotation.fromJson(it));
  }

  @override
  void save(ReaderAnnotation readerAnnotation) =>
      locatorDB.update(readerAnnotation.toJson());

  @override
  Future<void> delete(Iterable<String> deletedIds) async {
    for (String id in deletedIds) {
      await locatorDB.remove({'id': id});
    }
    super.delete(deletedIds);
  }
}
