import 'package:flutter/foundation.dart';
import 'package:rive/rive.dart';

class FlutterFlowRiveController extends SimpleAnimation {
  FlutterFlowRiveController(
    super.animationName, {
    super.mix,
    super.autoplay,
    this.shouldLoop = false,
  });

  bool shouldLoop;
  final _reactivate = ValueNotifier<bool>(false);
  ValueListenable<bool> get changeReactivate => _reactivate;

  bool get reactivate => _reactivate.value;
  set reactivate(bool value) {
    if (_reactivate.value != value) {
      _reactivate.value = value;
    }
  }

  bool endOfAnimation(LinearAnimationInstance? instance) {
    if (instance == null) {
      return false;
    }
    return instance.time == instance.animation.endTime;
  }

  @override
  bool init(RuntimeArtboard artboard) {
    reactivate = false;
    changeReactivate.addListener(() {
      if (reactivate) {
        isActive = true;
      }
    });
    return super.init(artboard);
  }

  @override
  void apply(RuntimeArtboard artboard, double elapsedSeconds) {
    if (instance == null) {
      return;
    }

    /// Reset on button press
    if (reactivate) {
      if (endOfAnimation(instance as LinearAnimationInstance?)) {
        instance?.time = 0;
      }
      reactivate = false;
    }

    if (instance == null || endOfAnimation(instance as LinearAnimationInstance?)) {
      isActive = false;
    }

    /// Stop after one loop if not a continuous animation
    if (!shouldLoop &&
        (instance?.animation.loop == Loop.loop ||
            instance?.animation.loop == Loop.pingPong) &&
        instance!.didLoop) {
      isActive = false;
    }

    instance!
      ..animation.apply(instance!.time, coreContext: artboard, mix: mix)
      ..advance(elapsedSeconds);
  }
}
