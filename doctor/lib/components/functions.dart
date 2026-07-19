import 'package:flutter/material.dart';

int getMinutesDiff(TimeOfDay tod1, TimeOfDay tod2) {
  int ans = (tod1.hour * 60 + tod1.minute) - (tod2.hour * 60 + tod2.minute);
  return ans < 0 ? 0 : ans;
}
