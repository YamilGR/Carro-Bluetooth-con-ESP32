extension Remap on num {
  double remap(num fromLow, num fromHigh, num toLow, num toHigh) {
    return (this - fromLow) * (toHigh - toLow) / (fromHigh - fromLow) + toLow;
  }
}

