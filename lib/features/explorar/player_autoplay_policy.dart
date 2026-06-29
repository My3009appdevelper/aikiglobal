bool shouldRequestAutoplayOnMediaSync({required bool initialAutoplayConsumed}) {
  return !initialAutoplayConsumed;
}

bool shouldConsumeInitialAutoplay({
  required bool requestedAutoplay,
  required bool mediaPrepared,
}) {
  return requestedAutoplay && mediaPrepared;
}
