import 'dart:math' as math;

extension MathHelpers on num {
  double degreeToRadian() {
    return this * math.pi / 180;
  }

  double radianToDegree() {
    return this * 180 / math.pi;
  }
}
