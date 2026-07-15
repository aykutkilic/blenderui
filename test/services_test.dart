import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('state store updates, resets, and suppresses equal values', () {
    final store = BlenderStateStore<int>(1);
    addTearDown(store.dispose);
    var notifications = 0;
    store.addListener(() => notifications++);

    expect(store.replace(1), isFalse);
    expect(store.update((value) => value + 2), isTrue);
    expect(store.value, 3);
    expect(store.reset(), isTrue);
    expect(store.value, 1);
    expect(notifications, 2);
  });

  test('history store offers bounded undo and redo', () {
    final store = BlenderHistoryStore<int>(0, historyLimit: 2);
    addTearDown(store.dispose);

    store.replace(1);
    store.replace(2);
    store.replace(3);
    expect(store.undoHistory, <int>[1, 2]);

    expect(store.undo(), isTrue);
    expect(store.value, 2);
    expect(store.undo(), isTrue);
    expect(store.value, 1);
    expect(store.undo(), isFalse);
    expect(store.redo(), isTrue);
    expect(store.value, 2);

    store.replace(8);
    expect(store.canRedo, isFalse);
  });

  test('service containers support scopes, factories, and disposal', () {
    final root = BlenderServiceContainer();
    final disposable = _DisposableService();
    root.registerSingleton<_DisposableService>(disposable);
    root.registerLazySingleton<_LazyService>((services) => _LazyService());
    root.registerFactory<_FactoryService>(
      (services) => _FactoryService(services.get<_LazyService>()),
    );
    final child = root.createChild();

    expect(child.get<_DisposableService>(), same(disposable));
    expect(root.get<_LazyService>(), same(root.get<_LazyService>()));
    expect(
      root.get<_FactoryService>(),
      isNot(same(root.get<_FactoryService>())),
    );
    expect(root.maybeGet<String>(), isNull);

    child.dispose();
    expect(disposable.disposed, isFalse);
    root.dispose();
    expect(disposable.disposed, isTrue);
    expect(() => root.get<_LazyService>(), throwsStateError);
  });

  test('service container reports circular dependencies', () {
    final services = BlenderServiceContainer();
    addTearDown(services.dispose);
    services.registerLazySingleton<_CircularService>(
      (container) => _CircularService(container.get<_CircularService>()),
    );

    expect(() => services.get<_CircularService>(), throwsStateError);
  });

  test('command registry executes enabled commands', () async {
    final registry = BlenderCommandRegistry();
    addTearDown(registry.dispose);
    var enabled = false;
    var executions = 0;
    registry.register(
      BlenderCommand(
        id: 'save',
        label: 'Save',
        shortcut: 'Ctrl S',
        enabled: () => enabled,
        execute: () => executions++,
      ),
    );

    expect(await registry.execute('missing'), isFalse);
    expect(await registry.execute('save'), isFalse);
    enabled = true;
    registry.refresh();
    expect(await registry.execute('save'), isTrue);
    expect(executions, 1);
  });

  testWidgets('state and service scopes expose typed values', (tester) async {
    final state = BlenderStateStore<int>(4);
    final services = BlenderServiceContainer()
      ..registerSingleton<_LazyService>(_LazyService());
    addTearDown(state.dispose);
    addTearDown(services.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderServiceScope(
          services: services,
          child: BlenderStateScope<int>(
            store: state,
            child: Builder(
              builder: (context) => Text(
                '${BlenderStateScope.watch<int>(context).value} '
                '${BlenderServiceScope.read<_LazyService>(context).label}',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('4 lazy'), findsOneWidget);
    state.replace(9);
    await tester.pump();
    expect(find.text('9 lazy'), findsOneWidget);
  });
}

class _DisposableService implements BlenderServiceDisposable {
  bool disposed = false;

  @override
  void dispose() => disposed = true;
}

class _LazyService {
  String get label => 'lazy';
}

class _FactoryService {
  _FactoryService(this.dependency);

  final _LazyService dependency;
}

class _CircularService {
  _CircularService(this.self);

  final _CircularService self;
}
