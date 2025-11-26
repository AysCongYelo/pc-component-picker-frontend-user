class BuildState {
  final Map<String, dynamic> build; // expanded components
  final Map<String, dynamic> summary; // power usage, total price
  final String? sourceBuildId; // editing mode
  final bool isLoading;
  final String? error;

  const BuildState({
    this.build = const {},
    this.summary = const {},
    this.sourceBuildId,
    this.isLoading = false,
    this.error,
  });

  BuildState copyWith({
    Map<String, dynamic>? build,
    Map<String, dynamic>? summary,
    String? sourceBuildId,
    bool? isLoading,
    String? error,
  }) {
    return BuildState(
      build: build ?? this.build,
      summary: summary ?? this.summary,
      sourceBuildId: sourceBuildId ?? this.sourceBuildId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
