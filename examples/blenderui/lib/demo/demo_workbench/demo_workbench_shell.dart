part of '../demo_workbench.dart';

class DemoWorkbench extends StatefulWidget {
  const DemoWorkbench({super.key, this.onStatus});

  final ValueChanged<String>? onStatus;

  @override
  State<DemoWorkbench> createState() => _DemoWorkbenchState();
}
