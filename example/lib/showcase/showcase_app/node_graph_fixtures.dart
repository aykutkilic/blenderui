part of '../showcase_app.dart';

List<BlenderGraphLink> _shaderNodeLinkFixture() => <BlenderGraphLink>[
  const BlenderGraphLink(
    from: 'texture',
    fromSocket: 'color',
    to: 'shader',
    toSocket: 'base-color',
  ),
  const BlenderGraphLink(
    from: 'shader',
    fromSocket: 'shader',
    to: 'output',
    toSocket: 'surface',
  ),
];

List<BlenderGraphLink> _geometryNodeLinkFixture() => <BlenderGraphLink>[
  const BlenderGraphLink(
    from: 'group-input',
    fromSocket: 'geometry',
    to: 'distribute',
    toSocket: 'mesh',
  ),
  const BlenderGraphLink(
    from: 'group-input',
    fromSocket: 'selection',
    to: 'distribute',
    toSocket: 'selection',
  ),
  const BlenderGraphLink(
    from: 'group-input',
    fromSocket: 'distance-min',
    to: 'distribute',
    toSocket: 'distance-min',
  ),
  const BlenderGraphLink(
    from: 'group-input',
    fromSocket: 'distance-max',
    to: 'distribute',
    toSocket: 'distance-max',
  ),
  const BlenderGraphLink(
    from: 'group-input',
    fromSocket: 'radius',
    to: 'icosphere',
    toSocket: 'radius',
  ),
  const BlenderGraphLink(
    from: 'distribute',
    fromSocket: 'points',
    to: 'instance',
    toSocket: 'points',
  ),
  const BlenderGraphLink(
    from: 'distribute',
    fromSocket: 'rotation',
    to: 'instance',
    toSocket: 'rotation',
  ),
  const BlenderGraphLink(
    from: 'icosphere',
    fromSocket: 'mesh',
    to: 'instance',
    toSocket: 'instance',
  ),
  const BlenderGraphLink(
    from: 'instance',
    fromSocket: 'instances',
    to: 'realize',
    toSocket: 'geometry',
  ),
  const BlenderGraphLink(
    from: 'realize',
    fromSocket: 'geometry',
    to: 'result-reroute',
    toSocket: 'input',
  ),
  const BlenderGraphLink(
    from: 'result-reroute',
    fromSocket: 'output',
    to: 'group-output',
    toSocket: 'geometry',
  ),
];
