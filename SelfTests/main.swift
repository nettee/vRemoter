import Foundation

func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else {
        FileHandle.standardError.write(Data("FAIL: \(message)\n".utf8))
        exit(1)
    }
}

do {
    let protocolHandler = ATVVProtocol()
    try protocolHandler.acceptCapabilities(
        ATVVCapabilities(
            version: .v10,
            codecs: ATVVCodec.adpcm16k.rawValue,
            interactionModel: 0,
            frameSize: 120
        )
    )

    let packet = Data([0x12, 0x34, 0xAB, 0xCD, 0x56, 0x78])
    protocolHandler.beginAudioStream(codec: .adpcm16k)
    let first = protocolHandler.decodeAudio(packet)
    require(first != nil, "first stream did not decode")

    _ = protocolHandler.decodeAudio(Data(repeating: 0x77, count: 24))
    protocolHandler.endAudioStream()
    protocolHandler.beginAudioStream(codec: .adpcm16k)
    let second = protocolHandler.decodeAudio(packet)

    require(second != nil, "second stream did not decode")
    require(first?.samples == second?.samples, "ADPCM state was not reset")
    require(first?.sequence == 0, "first stream sequence did not start at zero")
    require(second?.sequence == 0, "second stream sequence did not restart")

    // AUDIO_SYNC is allowed on either side of AUDIO_START. Verify that START
    // no longer erases a sync received during MIC_OPEN.
    protocolHandler.prepareForAudioStream()
    protocolHandler.applyAudioSync(
        codec: .adpcm16k,
        sequence: 42,
        predictor: 1_234,
        stepIndex: 20
    )
    protocolHandler.beginAudioStream(codec: .adpcm16k)
    let synced = protocolHandler.decodeAudio(Data([0x12, 0x34]))
    require(synced?.sequence == 42, "AUDIO_START erased AUDIO_SYNC sequence")
    require(
        synced?.samples.first != first?.samples.first,
        "AUDIO_START erased AUDIO_SYNC decoder state"
    )

    // A sync applied during one active stream must not become the initializer
    // for the next stream.
    protocolHandler.applyAudioSync(
        codec: .adpcm16k,
        sequence: 70,
        predictor: -2_000,
        stepIndex: 30
    )
    _ = protocolHandler.decodeAudio(Data([0x77, 0x77]))
    protocolHandler.endAudioStream()
    protocolHandler.beginAudioStream(codec: .adpcm16k)
    let afterActiveSync = protocolHandler.decodeAudio(packet)
    require(
        afterActiveSync?.samples == first?.samples,
        "active-stream AUDIO_SYNC leaked into the next stream"
    )
    require(
        afterActiveSync?.sequence == 0,
        "new unsynchronized stream sequence did not reset"
    )

    print("PASS: repeated AUDIO_START resets unsynchronized streams")
    print("PASS: AUDIO_START preserves a fresh AUDIO_SYNC")
    print("PASS: active-stream AUDIO_SYNC does not leak into next stream")

    let realtimeOpen = try protocolHandler.micOpenCommand(realtime: true)
    let hostClose = try protocolHandler.micCloseCommand(streamID: 42, hostRequested: true)
    let hostExtend = try protocolHandler.keepAliveCommand(streamID: 42, hostRequested: true)
    let physicalClose = try protocolHandler.micCloseCommand(streamID: 42)
    require(realtimeOpen == Data([0x0C, 0x01]), "Chromecast realtime MIC_OPEN must use mode 1")
    require(hostClose == Data([0x0D, 0x00]), "host-requested MIC_CLOSE must address stream zero")
    require(hostExtend == Data([0x0E, 0x00]), "host-requested MIC_EXTEND must address stream zero")
    require(physicalClose == Data([0x0D, 42]), "physical stream close must retain its stream ID")
    print("PASS: realtime opening and host-session addressing")

    let legacy = ATVVProtocol()
    try legacy.acceptCapabilities(ATVVCapabilities(version: .v04, codecs: 1, interactionModel: 0, frameSize: 134))
    let legacyOpen = try legacy.micOpenCommand(realtime: true)
    let legacyClose = try legacy.micCloseCommand(streamID: 42, hostRequested: true)
    require(legacyOpen == Data([0x0C, 0x00, 0x01]), "v0.4 must keep codec-based MIC_OPEN")
    require(legacyClose == Data([0x0D]), "v0.4 must keep its one-byte MIC_CLOSE")
    print("PASS: legacy microphone commands remain compatible")
} catch {
    FileHandle.standardError.write(Data("FAIL: \(error)\n".utf8))
    exit(1)
}
