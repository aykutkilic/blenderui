import AVFoundation
import AudioToolbox
import CoreAudio
import CoreMIDI
import FlutterMacOS

/// Native discovery and hosting boundary for the DAW example.
///
/// Audio Units are instantiated through AVAudioUnit. VST3 bundles are
/// discovered from their module metadata, but loading them requires a dedicated
/// VST3 SDK host process and is deliberately rejected instead of being faked.
final class NativeDawBridge {
  private let pluginChannel: FlutterMethodChannel
  private let audioChannel: FlutterMethodChannel
  private let midiChannel: FlutterMethodChannel
  private let audioEngine = AVAudioEngine()
  private var audioUnitDescriptions: [String: AudioComponentDescription] = [:]
  private var pluginDescriptors: [String: [String: Any]] = [:]
  private var audioUnits: [String: AVAudioUnit] = [:]

  init(messenger: FlutterBinaryMessenger) {
    pluginChannel = FlutterMethodChannel(
      name: "blender_ui_daw/native_plugin_host", binaryMessenger: messenger)
    audioChannel = FlutterMethodChannel(
      name: "blender_ui_daw/native_audio_engine", binaryMessenger: messenger)
    midiChannel = FlutterMethodChannel(
      name: "blender_ui_daw/native_midi_devices", binaryMessenger: messenger)

    pluginChannel.setMethodCallHandler { [weak self] call, result in
      self?.handlePlugin(call, result: result)
    }
    audioChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleAudio(call, result: result)
    }
    midiChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleMidi(call, result: result)
    }
  }

  private func handlePlugin(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "scan":
      let arguments = call.arguments as? [String: Any]
      let paths = arguments?["searchPaths"] as? [String] ?? []
      DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        let catalog = self?.scanPlugins(searchPaths: paths) ?? []
        DispatchQueue.main.async { result(catalog) }
      }
    case "instantiate":
      guard let id = argument(call, "pluginId") as? String else {
        result(FlutterError(code: "bad_arguments", message: "pluginId is required", details: nil))
        return
      }
      instantiate(id: id, result: result)
    case "remove":
      if let id = argument(call, "instanceId") as? String { audioUnits.removeValue(forKey: id) }
      result(nil)
    case "setEnabled":
      guard let id = argument(call, "instanceId") as? String,
            let enabled = argument(call, "enabled") as? Bool,
            let unit = audioUnits[id]
      else {
        result(FlutterError(code: "plugin_not_found", message: "Plug-in instance was not found", details: nil))
        return
      }
      unit.auAudioUnit.shouldBypassEffect = !enabled
      result(nil)
    case "setParameter":
      setParameter(call, result: result)
    case "saveState":
      saveState(call, result: result)
    case "restoreState":
      restoreState(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func scanPlugins(searchPaths: [String]) -> [[String: Any]] {
    audioUnitDescriptions.removeAll()
    pluginDescriptors.removeAll()
    var catalog = builtinPluginDescriptors()
    catalog.append(contentsOf: scanAudioUnits())
    catalog.append(contentsOf: scanVST3(searchPaths: searchPaths))
    catalog.sort {
      (($0["name"] as? String) ?? "").localizedCaseInsensitiveCompare(
        ($1["name"] as? String) ?? "") == .orderedAscending
    }
    for descriptor in catalog {
      if let id = descriptor["id"] as? String { pluginDescriptors[id] = descriptor }
    }
    return catalog
  }

  private func scanAudioUnits() -> [[String: Any]] {
    var result: [[String: Any]] = []
    var component: AudioComponent?
    var wildcard = AudioComponentDescription(
      componentType: 0,
      componentSubType: 0,
      componentManufacturer: 0,
      componentFlags: 0,
      componentFlagsMask: 0)
    repeat {
      component = AudioComponentFindNext(component, &wildcard)
      guard let component else { break }
      var description = AudioComponentDescription()
      guard AudioComponentGetDescription(component, &description) == noErr else { continue }
      let supportedTypes: Set<OSType> = [
        kAudioUnitType_MusicDevice, kAudioUnitType_MusicEffect,
        kAudioUnitType_Effect, kAudioUnitType_Generator,
        kAudioUnitType_MIDIProcessor,
      ]
      guard supportedTypes.contains(description.componentType) else { continue }
      var unmanagedName: Unmanaged<CFString>?
      AudioComponentCopyName(component, &unmanagedName)
      let fullName = unmanagedName?.takeRetainedValue() as String? ?? "Audio Unit"
      let pieces = fullName.split(separator: ":", maxSplits: 1).map(String.init)
      let vendor = pieces.count > 1 ? pieces[0].trimmingCharacters(in: .whitespaces) : "Audio Unit"
      let name = pieces.last?.trimmingCharacters(in: .whitespaces) ?? fullName
      let id = "au:\(description.componentType):\(description.componentSubType):\(description.componentManufacturer)"
      let instrument = description.componentType == kAudioUnitType_MusicDevice ||
        description.componentType == kAudioUnitType_Generator
      let descriptor: [String: Any] = [
        "id": id, "name": name, "vendor": vendor, "format": "audioUnit",
        "category": instrument ? "instrument" : "effect", "path": "au://\(id)",
        "audioInputs": instrument ? 0 : 2, "audioOutputs": 2,
        "midiInput": instrument || description.componentType == kAudioUnitType_MusicEffect,
        "midiOutput": description.componentType == kAudioUnitType_MIDIProcessor,
        "loadable": true,
      ]
      audioUnitDescriptions[id] = description
      result.append(descriptor)
    } while component != nil
    return result
  }

  private func builtinPluginDescriptors() -> [[String: Any]] {
    let devices: [(String, String)] = [
      ("internal:auto-filter", "Auto Filter"),
      ("internal:eq-eight", "EQ Eight"),
      ("internal:compressor", "Compressor"),
      ("internal:dynamics-compressor", "Dynamics Compressor"),
      ("internal:delay", "Delay"),
      ("internal:reverb", "Reverb"),
    ]
    return devices.map { id, name in
      [
        "id": id, "name": name, "vendor": "BlenderUI Audio", "format": "internal",
        "category": "effect", "path": "internal://\(id.dropFirst("internal:".count))",
        "audioInputs": 2, "audioOutputs": 2, "midiInput": false,
        "midiOutput": false, "loadable": true,
      ]
    }
  }

  private func scanVST3(searchPaths: [String]) -> [[String: Any]] {
    var result: [[String: Any]] = []
    var seen: Set<String> = []
    for rawPath in searchPaths {
      let path = NSString(string: rawPath).expandingTildeInPath
      guard let enumerator = FileManager.default.enumerator(
        at: URL(fileURLWithPath: path),
        includingPropertiesForKeys: [.isDirectoryKey],
        options: [.skipsHiddenFiles, .skipsPackageDescendants]
      ) else { continue }
      for case let bundleURL as URL in enumerator where bundleURL.pathExtension.lowercased() == "vst3" {
        enumerator.skipDescendants()
        let canonicalPath = bundleURL.resolvingSymlinksInPath().path
        guard seen.insert(canonicalPath).inserted else { continue }
        let bundle = Bundle(url: bundleURL)
        let module = vst3ModuleInfo(bundleURL)
        let classes = module?["Classes"] as? [[String: Any]]
        let categoryText = classes?.compactMap { $0["Category"] as? String }.joined(separator: " ") ?? ""
        let instrument = categoryText.localizedCaseInsensitiveContains("Instrument")
        let name = (module?["Name"] as? String) ??
          (bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ??
          (bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String) ??
          bundleURL.deletingPathExtension().lastPathComponent
        let vendor = (module?["Factory Info"] as? [String: Any])?["Vendor"] as? String ??
          (bundle?.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String) ?? "VST3"
        let id = "vst3:\(canonicalPath)"
        result.append([
          "id": id, "name": name, "vendor": vendor, "format": "vst3",
          "category": instrument ? "instrument" : "effect", "path": canonicalPath,
          "audioInputs": instrument ? 0 : 2, "audioOutputs": 2,
          "midiInput": instrument, "midiOutput": false,
          "loadable": false,
          "unavailableReason": "Discovered locally; loading requires the isolated VST3 SDK host bridge",
        ])
      }
    }
    return result
  }

  private func vst3ModuleInfo(_ bundleURL: URL) -> [String: Any]? {
    let candidates = [
      bundleURL.appendingPathComponent("Contents/Resources/moduleinfo.json"),
      bundleURL.appendingPathComponent("Contents/Resources/\(bundleURL.deletingPathExtension().lastPathComponent).vst3/moduleinfo.json"),
    ]
    for url in candidates {
      if let data = try? Data(contentsOf: url),
         let value = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        return value
      }
    }
    return nil
  }

  private func instantiate(id: String, result: @escaping FlutterResult) {
    guard let descriptor = pluginDescriptors[id] else {
      result(FlutterError(code: "plugin_not_found", message: "Plug-in is not in the current scan", details: id))
      return
    }
    if let unit = makeBuiltinAudioUnit(id: id) {
      let instanceId = "\(id)#\(UUID().uuidString)"
      audioUnits[instanceId] = unit
      result(instanceMap(id: instanceId, descriptor: descriptor, unit: unit))
      return
    }
    guard let description = audioUnitDescriptions[id] else {
      result(FlutterError(
        code: "vst3_host_unavailable",
        message: "VST3 was discovered, but loading requires the isolated VST3 SDK host bridge",
        details: descriptor["path"]))
      return
    }
    AVAudioUnit.instantiate(with: description, options: []) { [weak self] unit, error in
      DispatchQueue.main.async {
        guard let self, let unit else {
          result(FlutterError(code: "au_load_failed", message: error?.localizedDescription, details: id))
          return
        }
        let instanceId = "\(id)#\(UUID().uuidString)"
        self.audioUnits[instanceId] = unit
        result(self.instanceMap(id: instanceId, descriptor: descriptor, unit: unit))
      }
    }
  }

  private func makeBuiltinAudioUnit(id: String) -> AVAudioUnit? {
    switch id {
    case "internal:auto-filter":
      let unit = AVAudioUnitEQ(numberOfBands: 1)
      let band = unit.bands[0]
      band.filterType = .lowPass
      band.frequency = 1_000
      band.bandwidth = 1
      band.bypass = false
      return unit
    case "internal:eq-eight":
      let unit = AVAudioUnitEQ(numberOfBands: 8)
      let frequencies: [Float] = [60, 120, 250, 500, 1_000, 2_000, 6_000, 12_000]
      for (index, band) in unit.bands.enumerated() {
        band.filterType = index == 0 ? .lowShelf : (index == 7 ? .highShelf : .parametric)
        band.frequency = frequencies[index]
        band.bandwidth = 1
        band.gain = 0
        band.bypass = false
      }
      return unit
    case "internal:compressor":
      return makeAppleEffect(subType: kAudioUnitSubType_DynamicsProcessor)
    case "internal:dynamics-compressor":
      return makeAppleEffect(subType: kAudioUnitSubType_MultiBandCompressor)
    case "internal:delay":
      let unit = AVAudioUnitDelay()
      unit.delayTime = 0.25
      unit.feedback = 28
      unit.wetDryMix = 35
      return unit
    case "internal:reverb":
      let unit = AVAudioUnitReverb()
      unit.loadFactoryPreset(.mediumHall)
      unit.wetDryMix = 30
      return unit
    default:
      return nil
    }
  }

  private func makeAppleEffect(subType: OSType) -> AVAudioUnitEffect {
    AVAudioUnitEffect(audioComponentDescription: AudioComponentDescription(
      componentType: kAudioUnitType_Effect,
      componentSubType: subType,
      componentManufacturer: kAudioUnitManufacturer_Apple,
      componentFlags: 0,
      componentFlagsMask: 0))
  }

  private func instanceMap(id: String, descriptor: [String: Any], unit: AVAudioUnit) -> [String: Any] {
    let parameters = unit.auAudioUnit.parameterTree?.allParameters.map { parameter -> [String: Any] in
      let range = max(parameter.maxValue - parameter.minValue, 0.000001)
      return [
        "id": String(parameter.address), "name": parameter.displayName,
        "value": Double((parameter.value - parameter.minValue) / range),
        "unit": parameter.unitName ?? "", "automatable": true,
      ]
    } ?? []
    return [
      "instanceId": id, "descriptor": descriptor, "enabled": true,
      "parameters": parameters,
    ]
  }

  private func setParameter(_ call: FlutterMethodCall, result: FlutterResult) {
    guard let instanceId = argument(call, "instanceId") as? String,
          let parameterId = argument(call, "parameterId") as? String,
          let address = AUParameterAddress(parameterId),
          let value = argument(call, "value") as? Double,
          let parameter = audioUnits[instanceId]?.auAudioUnit.parameterTree?.parameter(withAddress: address)
    else {
      result(FlutterError(code: "parameter_not_found", message: "Audio Unit parameter was not found", details: nil))
      return
    }
    parameter.value = parameter.minValue + AUValue(value) * (parameter.maxValue - parameter.minValue)
    result(nil)
  }

  private func saveState(_ call: FlutterMethodCall, result: FlutterResult) {
    guard let instanceId = argument(call, "instanceId") as? String,
          let state = audioUnits[instanceId]?.auAudioUnit.fullState,
          let data = try? PropertyListSerialization.data(fromPropertyList: state, format: .binary, options: 0)
    else {
      result(FlutterStandardTypedData(bytes: Data()))
      return
    }
    result(FlutterStandardTypedData(bytes: data))
  }

  private func restoreState(_ call: FlutterMethodCall, result: FlutterResult) {
    guard let instanceId = argument(call, "instanceId") as? String,
          let typed = argument(call, "state") as? FlutterStandardTypedData,
          let state = try? PropertyListSerialization.propertyList(from: typed.data, options: [], format: nil) as? [String: Any]
    else {
      result(FlutterError(code: "invalid_state", message: "Audio Unit state is invalid", details: nil))
      return
    }
    audioUnits[instanceId]?.auAudioUnit.fullState = state
    result(nil)
  }

  private func handleAudio(_ call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "listDevices": result(listAudioDevices())
    case "start": startAudio(call, result: result)
    case "stop": audioEngine.stop(); result(nil)
    case "synchronizeProject", "seek", "setPlaying": result(nil)
    case "render": result(FlutterError(code: "render_unavailable", message: "Native offline rendering is not implemented", details: nil))
    case "cancelRender": result(nil)
    default: result(FlutterMethodNotImplemented)
    }
  }

  private func listAudioDevices() -> [[String: Any]] {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDevices,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain)
    var size: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size) == noErr else { return [] }
    let count = Int(size) / MemoryLayout<AudioDeviceID>.size
    var devices = [AudioDeviceID](repeating: 0, count: count)
    guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &devices) == noErr else { return [] }
    return devices.compactMap { device in
      guard let uid = audioString(device, selector: kAudioDevicePropertyDeviceUID),
            let name = audioString(device, selector: kAudioObjectPropertyName) else { return nil }
      return [
        "id": uid, "name": name,
        "inputChannels": channelCount(device, scope: kAudioObjectPropertyScopeInput),
        "outputChannels": channelCount(device, scope: kAudioObjectPropertyScopeOutput),
        "defaultSampleRate": Int(nominalSampleRate(device)),
      ]
    }
  }

  private func startAudio(_ call: FlutterMethodCall, result: FlutterResult) {
    guard let uid = argument(call, "deviceId") as? String,
          let device = deviceID(forUID: uid) else {
      result(FlutterError(code: "audio_device_not_found", message: "Selected CoreAudio device was not found", details: nil))
      return
    }
    audioEngine.stop()
    if let outputUnit = audioEngine.outputNode.audioUnit {
      var selected = device
      let status = AudioUnitSetProperty(
        outputUnit, kAudioOutputUnitProperty_CurrentDevice,
        kAudioUnitScope_Global, 0, &selected, UInt32(MemoryLayout<AudioDeviceID>.size))
      if status != noErr {
        result(FlutterError(code: "audio_device_select_failed", message: "CoreAudio rejected the selected output device", details: status))
        return
      }
    }
    if let inputUID = argument(call, "inputDeviceId") as? String,
       let inputDevice = deviceID(forUID: inputUID),
       let inputUnit = audioEngine.inputNode.audioUnit {
      var selectedInput = inputDevice
      let status = AudioUnitSetProperty(
        inputUnit, kAudioOutputUnitProperty_CurrentDevice,
        kAudioUnitScope_Global, 0, &selectedInput, UInt32(MemoryLayout<AudioDeviceID>.size))
      if status != noErr {
        result(FlutterError(code: "audio_input_select_failed", message: "CoreAudio rejected the selected input device", details: status))
        return
      }
    }
    if var frames = (argument(call, "bufferFrames") as? NSNumber)?.uint32Value {
      var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyBufferFrameSize,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain)
      let size = UInt32(MemoryLayout<UInt32>.size)
      AudioObjectSetPropertyData(device, &address, 0, nil, size, &frames)
    }
    do {
      audioEngine.prepare()
      try audioEngine.start()
      result(nil)
    } catch {
      result(FlutterError(code: "audio_engine_start_failed", message: error.localizedDescription, details: nil))
    }
  }

  private func deviceID(forUID uid: String) -> AudioDeviceID? {
    for device in listAudioDeviceIDs() {
      if audioString(device, selector: kAudioDevicePropertyDeviceUID) == uid { return device }
    }
    return nil
  }

  private func listAudioDeviceIDs() -> [AudioDeviceID] {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDevices,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain)
    var size: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size) == noErr else { return [] }
    var values = [AudioDeviceID](repeating: 0, count: Int(size) / MemoryLayout<AudioDeviceID>.size)
    guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &values) == noErr else { return [] }
    return values
  }

  private func audioString(_ object: AudioObjectID, selector: AudioObjectPropertySelector) -> String? {
    var address = AudioObjectPropertyAddress(
      mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain)
    var value: Unmanaged<CFString>?
    var size = UInt32(MemoryLayout<CFString?>.size)
    let status = withUnsafeMutablePointer(to: &value) { pointer in
      AudioObjectGetPropertyData(object, &address, 0, nil, &size, pointer)
    }
    guard status == noErr else { return nil }
    return value?.takeUnretainedValue() as String?
  }

  private func nominalSampleRate(_ device: AudioDeviceID) -> Double {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyNominalSampleRate,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain)
    var value: Float64 = 48000
    var size = UInt32(MemoryLayout<Float64>.size)
    AudioObjectGetPropertyData(device, &address, 0, nil, &size, &value)
    return value
  }

  private func channelCount(_ device: AudioDeviceID, scope: AudioObjectPropertyScope) -> Int {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyStreamConfiguration,
      mScope: scope, mElement: kAudioObjectPropertyElementMain)
    var size: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(device, &address, 0, nil, &size) == noErr else { return 0 }
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: MemoryLayout<AudioBufferList>.alignment)
    defer { pointer.deallocate() }
    guard AudioObjectGetPropertyData(device, &address, 0, nil, &size, pointer) == noErr else { return 0 }
    let buffers = UnsafeMutableAudioBufferListPointer(pointer.assumingMemoryBound(to: AudioBufferList.self))
    return buffers.reduce(0) { $0 + Int($1.mNumberChannels) }
  }

  private func handleMidi(_ call: FlutterMethodCall, result: FlutterResult) {
    guard call.method == "listEndpoints" else { result(FlutterMethodNotImplemented); return }
    var endpoints: [[String: Any]] = []
    for index in 0..<MIDIGetNumberOfSources() {
      endpoints.append(midiEndpoint(MIDIGetSource(index), direction: "input"))
    }
    for index in 0..<MIDIGetNumberOfDestinations() {
      endpoints.append(midiEndpoint(MIDIGetDestination(index), direction: "output"))
    }
    result(endpoints)
  }

  private func midiEndpoint(_ endpoint: MIDIEndpointRef, direction: String) -> [String: Any] {
    [
      "id": String(endpoint),
      "name": midiString(endpoint, property: kMIDIPropertyDisplayName) ?? "MIDI Endpoint",
      "manufacturer": midiString(endpoint, property: kMIDIPropertyManufacturer) ?? "",
      "model": midiString(endpoint, property: kMIDIPropertyModel) ?? "",
      "direction": direction,
      "online": midiInteger(endpoint, property: kMIDIPropertyOffline) == 0,
    ]
  }

  private func midiString(_ object: MIDIObjectRef, property: CFString) -> String? {
    var value: Unmanaged<CFString>?
    guard MIDIObjectGetStringProperty(object, property, &value) == noErr else { return nil }
    return value?.takeRetainedValue() as String?
  }

  private func midiInteger(_ object: MIDIObjectRef, property: CFString) -> Int32 {
    var value: Int32 = 0
    MIDIObjectGetIntegerProperty(object, property, &value)
    return value
  }

  private func argument(_ call: FlutterMethodCall, _ key: String) -> Any? {
    (call.arguments as? [String: Any])?[key]
  }
}
