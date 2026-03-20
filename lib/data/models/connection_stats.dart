class ConnectionStats {
  final int downloadBytes;
  final int uploadBytes;
  final double downloadSpeedBps;
  final double uploadSpeedBps;
  final Duration connectionDuration;

  const ConnectionStats({
    this.downloadBytes = 0,
    this.uploadBytes = 0,
    this.downloadSpeedBps = 0,
    this.uploadSpeedBps = 0,
    this.connectionDuration = Duration.zero,
  });

  ConnectionStats copyWith({
    int? downloadBytes,
    int? uploadBytes,
    double? downloadSpeedBps,
    double? uploadSpeedBps,
    Duration? connectionDuration,
  }) {
    return ConnectionStats(
      downloadBytes: downloadBytes ?? this.downloadBytes,
      uploadBytes: uploadBytes ?? this.uploadBytes,
      downloadSpeedBps: downloadSpeedBps ?? this.downloadSpeedBps,
      uploadSpeedBps: uploadSpeedBps ?? this.uploadSpeedBps,
      connectionDuration: connectionDuration ?? this.connectionDuration,
    );
  }
}
