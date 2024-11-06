import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'ffi/fluidlite_bindings.dart';
import 'ffi/library.dart';

class FluidLiteSynth {
  late final Pointer<fluid_settings_t> _settings;
  late final Pointer<fluid_synth_t> _synth;

  FluidLiteSynth() {
    _settings = FluidLiteLibrary.bindings.new_fluid_settings();
    _synth = FluidLiteLibrary.bindings.new_fluid_synth(_settings);
  }

  void dispose() {
    FluidLiteLibrary.bindings.delete_fluid_synth(_synth);
    FluidLiteLibrary.bindings.delete_fluid_settings(_settings);
  }

  set gain(double value) {
    FluidLiteLibrary.bindings.fluid_synth_set_gain(_synth, value);
  }

  double get gain {
    return FluidLiteLibrary.bindings.fluid_synth_get_gain(_synth);
  }

  void reset() {
    FluidLiteLibrary.bindings.fluid_synth_program_reset(_synth);
  }

  void sendMidi({
    required int command,
    required int data1,
    required int data2,
  }) {
    final baseCommand = command & 0xF0;
    final channel = command & 0x0F;

    switch (baseCommand) {
      case 0x80: // Note Off
        noteOff(channel: channel, key: data1);
        break;
      case 0x90: // Note On
        noteOn(channel: channel, key: data1, velocity: data2);
        break;
      case 0xA0: // Polyphonic Key Pressure (Aftertouch)
        keyPressure(channel: channel, key: data1, value: data2);
        break;
      case 0xB0: // Control Change
        controlChange(channel: channel, control: data1, value: data2);
        break;
      case 0xC0: // Program Change
        programChange(channel: channel, program: data1);
        break;
      case 0xD0: // Channel Pressure (Aftertouch)
        channelPressure(channel: channel, value: data1);
        break;
      case 0xE0: // Pitch Bend Change. Range is 0 (-1 semitone) to 8192 (0 semitone) to 16383 (+1 semitone)
        pitchBend(channel: channel, value: (data2 << 7) | data1);
        break;
      default:
        print('Unsupported MIDI command: $command');
    }
  }

  double getVolume({required int channel}) {
    return getControlValue(channel: channel, control: 7) / 127;
  }

  void setVolume({required int channel, required double value}) {
    controlChange(channel: channel, control: 7, value: (value * 127).toInt());
  }

  bool noteOn({required int channel, required int key, required int velocity}) {
    final result = FluidLiteLibrary.bindings
        .fluid_synth_noteon(_synth, channel, key, velocity);
    return result == 0;
  }

  bool noteOff({required int channel, required int key}) {
    final result =
        FluidLiteLibrary.bindings.fluid_synth_noteoff(_synth, channel, key);
    return result == 0;
  }

  bool noteOffAll() {
    for (int channel = 0; channel < 16; channel++) {
      final result =
          FluidLiteLibrary.bindings.fluid_synth_all_notes_off(_synth, channel);
      if (result != 0) return false;
    }
    return true;
  }

  bool controlChange(
      {required int channel, required int control, required int value}) {
    final result = FluidLiteLibrary.bindings
        .fluid_synth_cc(_synth, channel, control, value);

    return result == 0;
  }

  int getControlValue({required int channel, required int control}) {
    final Pointer<Int> pval = calloc<Int>();

    try {
      final result = FluidLiteLibrary.bindings
          .fluid_synth_get_cc(_synth, channel, control, pval);
      if (result != 0) {
        return 0;
      }
      return pval.value;
    } finally {
      calloc.free(pval);
    }
  }

  bool pitchBend({required int channel, required int value}) {
    final result = FluidLiteLibrary.bindings
        .fluid_synth_pitch_bend(_synth, channel, value);

    return result == 0;
  }

  int getPitchBend({required int channel}) {
    final Pointer<Int> pval = calloc<Int>();

    try {
      final result = FluidLiteLibrary.bindings
          .fluid_synth_get_pitch_bend(_synth, channel, pval);
      if (result != 0) {
        return 0;
      }
      return pval.value;
    } finally {
      calloc.free(pval);
    }
  }

  bool setPitchWheelSensitivity({required int channel, required int value}) {
    final result = FluidLiteLibrary.bindings
        .fluid_synth_pitch_wheel_sens(_synth, channel, value);

    return result == 0;
  }

  int getPitchWheelSensitivity({required int channel}) {
    final Pointer<Int> pval = calloc<Int>();

    try {
      final result = FluidLiteLibrary.bindings
          .fluid_synth_get_pitch_wheel_sens(_synth, channel, pval);
      if (result != 0) {
        return 0;
      }
      return pval.value;
    } finally {
      calloc.free(pval);
    }
  }

  bool programChange({required int channel, required int program}) {
    final result = FluidLiteLibrary.bindings
        .fluid_synth_program_change(_synth, channel, program);

    return result == 0;
  }

  bool channelPressure({required int channel, required int value}) {
    final result = FluidLiteLibrary.bindings
        .fluid_synth_channel_pressure(_synth, channel, value);

    return result == 0;
  }

  bool keyPressure(
      {required int channel, required int key, required int value}) {
    final result = FluidLiteLibrary.bindings
        .fluid_synth_key_pressure(_synth, channel, key, value);

    return result == 0;
  }

  bool bankSelect({required int channel, required int bank}) {
    final result = FluidLiteLibrary.bindings
        .fluid_synth_bank_select(_synth, channel, bank);

    return result == 0;
  }

  bool selectSoundfont({required int channel, required int soundfontId}) {
    final result = FluidLiteLibrary.bindings
        .fluid_synth_sfont_select(_synth, channel, soundfontId);

    return result == 0;
  }

  // ...

  bool programSelect({
    required int channel,
    required int soundfontId,
    required int bankNumber,
    required int presetNumber,
  }) {
    final result = FluidLiteLibrary.bindings.fluid_synth_program_select(
      _synth,
      channel,
      soundfontId,
      bankNumber,
      presetNumber,
    );

    return result == 0;
  }

  // ...

  int loadSoundfont(String filename, {bool resetPresets = false}) {
    final Pointer<Utf8> filenamePointer = filename.toNativeUtf8();

    try {
      final result = FluidLiteLibrary.bindings.fluid_synth_sfload(
        _synth,
        filenamePointer.cast(),
        resetPresets ? 1 : 0,
      );
      if (result == -1) {
        print("FS error: " + getLastErrorMessage());
      }

      reset();
      return result;
    } finally {
      calloc.free(filenamePointer);
    }
  }

  // ....

  Int16List renderPCM16Bit({
    required int length,
  }) {
    const numChannels = 2;
    final buffer = calloc<Int16>(length * numChannels);

    final result = FluidLiteLibrary.bindings.fluid_synth_write_s16(
      _synth,
      length,
      buffer.cast(),
      0,
      numChannels,
      buffer.cast(),
      1,
      numChannels,
    );

    if (result != 0) {
      throw Exception('Failure rendering 16-bit PCM');
    }

    return buffer.asTypedList(length * numChannels);
  }

  List<double> renderDoubleList({
    required int length,
  }) {
    const numChannels = 2;
    final buffer = calloc<Double>(length * numChannels);

    final result = FluidLiteLibrary.bindings.fluid_synth_write_float(
      _synth,
      length,
      buffer.cast(),
      0,
      numChannels,
      buffer.cast(),
      1,
      numChannels,
    );

    if (result != 0) {
      throw Exception('Failure rendering double lists');
    }

    return buffer.asTypedList(length * numChannels);
  }

  // --------------------------------------------------------------------------
  String getLastErrorMessage() {
    final error = FluidLiteLibrary.bindings.fluid_synth_error(_synth);
    return error.cast<Utf8>().toDartString();
  }
}
