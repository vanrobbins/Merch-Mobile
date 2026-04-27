/// Counts slots in a planogram's stored JSON without parsing it.
///
/// The slotsJson format is a JSON array; each element opens with `[` for the
/// array itself plus one `[` per slot, so the slot count equals the number of
/// `[` occurrences minus 1. Returns 0 for null or empty (`[]`) input.
int countPlanogramSlots(String? slotsJson) {
  if (slotsJson == null || slotsJson == '[]') return 0;
  return '['.allMatches(slotsJson).length - 1;
}
