enum FamilyRole {
  dad,
  mom,
  son,
  daughter,
  grandparent,
  roommate,
  other;

  // Ideally, serialization would handle string conversion,
  // typically toUppercase or maintaining exact string matches if DB depends on it.
  // For now, simple name usage or custom mapping if needed.
}
