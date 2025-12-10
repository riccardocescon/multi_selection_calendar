enum ConflictMode {
  /// Allow two or more selections to overlap
  overlap,

  /// The old selection will be removed when a new selection overlaps it
  override,

  /// The result will be the merging of all overlapping selections
  merge,
}

enum SelectionConflictMode {
  /// Prevent new selections to be added
  block,

  /// Will cause the first selection added to be removed to make space for the new one
  fifo,
}
