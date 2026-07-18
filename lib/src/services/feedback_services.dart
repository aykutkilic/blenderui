part of '../services.dart';

/// The severity associated with the current application status message.
enum BlenderStatusLevel { info, success, warning, error }

/// Immutable status-bar message managed by [BlenderStatusService].
class BlenderStatusMessage {
  const BlenderStatusMessage({
    required this.text,
    this.level = BlenderStatusLevel.info,
  });

  final String text;
  final BlenderStatusLevel level;
}

/// Application-wide status reporting service.
///
/// Commands and editor views can report progress or failures without knowing
/// which status-bar widget a host application has chosen to render.
class BlenderStatusService extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderStatusMessage? _message;

  BlenderStatusMessage? get message => _message;

  void report(
    String text, {
    BlenderStatusLevel level = BlenderStatusLevel.info,
  }) {
    final next = text.isEmpty
        ? null
        : BlenderStatusMessage(text: text, level: level);
    if (_message?.text == next?.text && _message?.level == next?.level) return;
    _message = next;
    notifyListeners();
  }

  void clear() {
    if (_message == null) return;
    _message = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _message = null;
    super.dispose();
  }
}

enum BlenderJobState { running, cancelRequested, completed, failed }

/// Immutable state for one application background job.
class BlenderJob {
  const BlenderJob({
    required this.id,
    required this.name,
    this.progress = 0,
    this.state = BlenderJobState.running,
    this.remainingTime,
    this.elapsedTime,
    this.onCancel,
    this.error,
  });

  final String id;
  final String name;
  final double progress;
  final BlenderJobState state;
  final String? remainingTime;
  final String? elapsedTime;
  final FutureOr<void> Function()? onCancel;
  final Object? error;

  bool get canCancel => state == BlenderJobState.running && onCancel != null;

  BlenderJob copyWith({
    String? name,
    double? progress,
    BlenderJobState? state,
    String? remainingTime,
    String? elapsedTime,
    FutureOr<void> Function()? onCancel,
    Object? error,
    bool clearError = false,
  }) => BlenderJob(
    id: id,
    name: name ?? this.name,
    progress: (progress ?? this.progress).clamp(0, 1).toDouble(),
    state: state ?? this.state,
    remainingTime: remainingTime ?? this.remainingTime,
    elapsedTime: elapsedTime ?? this.elapsedTime,
    onCancel: onCancel ?? this.onCancel,
    error: clearError ? null : error ?? this.error,
  );
}

/// Observable, insertion-ordered catalog of application background jobs.
class BlenderJobService extends ChangeNotifier
    implements BlenderServiceDisposable {
  final LinkedHashMap<String, BlenderJob> _jobs =
      LinkedHashMap<String, BlenderJob>();

  List<BlenderJob> get jobs => List<BlenderJob>.unmodifiable(_jobs.values);

  BlenderJob? operator [](String id) => _jobs[id];

  void register(BlenderJob job) {
    if (_jobs.containsKey(job.id)) {
      throw StateError('A job with id "${job.id}" already exists.');
    }
    _jobs[job.id] = job;
    notifyListeners();
  }

  bool update(String id, BlenderJob Function(BlenderJob current) update) {
    final current = _jobs[id];
    if (current == null) return false;
    final next = update(current);
    if (next.id != id) {
      throw ArgumentError.value(next.id, 'id', 'A job ID cannot change.');
    }
    if (identical(next, current)) return false;
    _jobs[id] = next;
    notifyListeners();
    return true;
  }

  bool reportProgress(
    String id,
    double progress, {
    String? remainingTime,
    String? elapsedTime,
  }) => update(
    id,
    (job) => job.copyWith(
      progress: progress,
      remainingTime: remainingTime,
      elapsedTime: elapsedTime,
    ),
  );

  Future<bool> cancel(String id) async {
    final job = _jobs[id];
    if (job == null || !job.canCancel) return false;
    _jobs[id] = job.copyWith(state: BlenderJobState.cancelRequested);
    notifyListeners();
    try {
      await job.onCancel!();
      return true;
    } catch (error) {
      _jobs[id] = job.copyWith(state: BlenderJobState.failed, error: error);
      notifyListeners();
      return false;
    }
  }

  bool complete(String id) => update(
    id,
    (job) => job.copyWith(
      progress: 1,
      state: BlenderJobState.completed,
      clearError: true,
    ),
  );

  bool fail(String id, Object error) => update(
    id,
    (job) => job.copyWith(state: BlenderJobState.failed, error: error),
  );

  bool remove(String id) {
    final removed = _jobs.remove(id) != null;
    if (removed) notifyListeners();
    return removed;
  }

  void clear() {
    if (_jobs.isEmpty) return;
    _jobs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _jobs.clear();
    super.dispose();
  }
}

/// One immutable report retained by [BlenderReportService].
class BlenderReport {
  const BlenderReport({
    required this.id,
    required this.message,
    this.level = BlenderStatusLevel.info,
    required this.timestamp,
  });

  final String id;
  final String message;
  final BlenderStatusLevel level;
  final DateTime timestamp;
}

/// Bounded, observable application report history.
class BlenderReportService extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderReportService({this.historyLimit = 100}) : assert(historyLimit > 0);

  final int historyLimit;
  final List<BlenderReport> _reports = <BlenderReport>[];
  int _nextId = 1;

  List<BlenderReport> get reports => List<BlenderReport>.unmodifiable(_reports);
  BlenderReport? get latest => _reports.isEmpty ? null : _reports.last;

  BlenderReport report(
    String message, {
    BlenderStatusLevel level = BlenderStatusLevel.info,
    String? id,
    DateTime? timestamp,
  }) {
    final next = BlenderReport(
      id: id ?? 'report-${_nextId++}',
      message: message,
      level: level,
      timestamp: timestamp ?? DateTime.now(),
    );
    _reports.add(next);
    if (_reports.length > historyLimit) {
      _reports.removeRange(0, _reports.length - historyLimit);
    }
    notifyListeners();
    return next;
  }

  bool remove(String id) {
    final before = _reports.length;
    _reports.removeWhere((report) => report.id == id);
    if (_reports.length == before) return false;
    notifyListeners();
    return true;
  }

  void clear() {
    if (_reports.isEmpty) return;
    _reports.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _reports.clear();
    super.dispose();
  }
}
