part of '../non3d_editors.dart';

enum BlenderGraphInterpolation { constant, linear, bezier }

enum BlenderGraphHandleType { free, aligned, vector, automatic }

@immutable
class BlenderGraphKeyframe {
  const BlenderGraphKeyframe({
    required this.id,
    required this.frame,
    required this.value,
    this.leftHandle,
    this.rightHandle,
    this.interpolation = BlenderGraphInterpolation.bezier,
    this.leftHandleType = BlenderGraphHandleType.automatic,
    this.rightHandleType = BlenderGraphHandleType.automatic,
    this.selected = false,
    this.leftHandleSelected = false,
    this.rightHandleSelected = false,
  });

  final String id;
  final double frame;
  final double value;
  final Offset? leftHandle;
  final Offset? rightHandle;
  final BlenderGraphInterpolation interpolation;
  final BlenderGraphHandleType leftHandleType;
  final BlenderGraphHandleType rightHandleType;
  final bool selected;
  final bool leftHandleSelected;
  final bool rightHandleSelected;

  BlenderGraphKeyframe copyWith({
    double? frame,
    double? value,
    Offset? leftHandle,
    Offset? rightHandle,
    BlenderGraphInterpolation? interpolation,
    BlenderGraphHandleType? leftHandleType,
    BlenderGraphHandleType? rightHandleType,
    bool? selected,
    bool? leftHandleSelected,
    bool? rightHandleSelected,
  }) => BlenderGraphKeyframe(
    id: id,
    frame: frame ?? this.frame,
    value: value ?? this.value,
    leftHandle: leftHandle ?? this.leftHandle,
    rightHandle: rightHandle ?? this.rightHandle,
    interpolation: interpolation ?? this.interpolation,
    leftHandleType: leftHandleType ?? this.leftHandleType,
    rightHandleType: rightHandleType ?? this.rightHandleType,
    selected: selected ?? this.selected,
    leftHandleSelected: leftHandleSelected ?? this.leftHandleSelected,
    rightHandleSelected: rightHandleSelected ?? this.rightHandleSelected,
  );
}

@immutable
class BlenderCurveChannel {
  const BlenderCurveChannel({
    required this.id,
    required this.label,
    this.keyframes = const <BlenderGraphKeyframe>[],
    this.points = const <Offset>[],
    this.color,
    this.dataPath,
    this.arrayIndex,
    this.visible = true,
    this.selected = false,
    this.active = false,
    this.muted = false,
    this.locked = false,
    this.extrapolation = BlenderGraphExtrapolation.constant,
  });

  final String id;
  final String label;

  /// Frame/value keyframes used by the complete Graph Editor model.
  ///
  /// Keep this list in ascending frame order. The renderer relies on that
  /// invariant for logarithmic viewport culling instead of sorting every
  /// curve during pan and zoom repaints.
  final List<BlenderGraphKeyframe> keyframes;

  /// Legacy normalized points retained for source compatibility. New callers
  /// should provide [keyframes].
  final List<Offset> points;
  final Color? color;
  final String? dataPath;
  final int? arrayIndex;
  final bool visible;
  final bool selected;
  final bool active;
  final bool muted;
  final bool locked;
  final BlenderGraphExtrapolation extrapolation;

  List<BlenderGraphKeyframe> get resolvedKeyframes {
    if (keyframes.isNotEmpty) return keyframes;
    return <BlenderGraphKeyframe>[
      for (var index = 0; index < points.length; index++)
        BlenderGraphKeyframe(
          id: '$id-$index',
          frame: points[index].dx,
          value: points[index].dy,
          interpolation: BlenderGraphInterpolation.linear,
        ),
    ];
  }

  BlenderCurveChannel copyWith({
    List<BlenderGraphKeyframe>? keyframes,
    Color? color,
    bool? visible,
    bool? selected,
    bool? active,
    bool? muted,
    bool? locked,
    BlenderGraphExtrapolation? extrapolation,
  }) => BlenderCurveChannel(
    id: id,
    label: label,
    keyframes: keyframes ?? resolvedKeyframes,
    color: color ?? this.color,
    dataPath: dataPath,
    arrayIndex: arrayIndex,
    visible: visible ?? this.visible,
    selected: selected ?? this.selected,
    active: active ?? this.active,
    muted: muted ?? this.muted,
    locked: locked ?? this.locked,
    extrapolation: extrapolation ?? this.extrapolation,
  );
}

enum BlenderGraphExtrapolation { constant, linear }

enum BlenderGraphChannelKind { object, action, group, curve }

@immutable
class BlenderGraphChannelNode {
  const BlenderGraphChannelNode({
    required this.id,
    required this.label,
    this.kind = BlenderGraphChannelKind.group,
    this.curveId,
    this.children = const <BlenderGraphChannelNode>[],
    this.expanded = true,
    this.selected = false,
    this.visible = true,
    this.muted = false,
    this.locked = false,
    this.color,
  });

  final String id;
  final String label;
  final BlenderGraphChannelKind kind;
  final String? curveId;
  final List<BlenderGraphChannelNode> children;
  final bool expanded;
  final bool selected;
  final bool visible;
  final bool muted;
  final bool locked;
  final Color? color;
}

enum BlenderGraphChannelActionType {
  toggleExpanded,
  toggleVisible,
  toggleMuted,
  toggleLocked,
}

@immutable
class BlenderGraphChannelAction {
  const BlenderGraphChannelAction(this.nodeId, this.type);

  final String nodeId;
  final BlenderGraphChannelActionType type;
}

@immutable
class BlenderGraphKeyframeRef {
  const BlenderGraphKeyframeRef(this.channelId, this.keyframeId);

  final String channelId;
  final String keyframeId;

  @override
  bool operator ==(Object other) =>
      other is BlenderGraphKeyframeRef &&
      other.channelId == channelId &&
      other.keyframeId == keyframeId;

  @override
  int get hashCode => Object.hash(channelId, keyframeId);
}

@immutable
class BlenderGraphKeyframeMove {
  const BlenderGraphKeyframeMove({
    required this.keyframe,
    required this.frame,
    required this.value,
  });

  final BlenderGraphKeyframeRef keyframe;
  final double frame;
  final double value;
}

@immutable
class BlenderGraphMarker {
  const BlenderGraphMarker({required this.frame, required this.label});

  final double frame;
  final String label;
}
