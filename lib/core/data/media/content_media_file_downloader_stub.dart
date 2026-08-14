typedef ContentMediaDownloadProgress =
    void Function(int bytesDownloaded, int? totalBytes);

Future<int?> downloadUrlToFile({
  required String url,
  required String localPath,
  ContentMediaDownloadProgress? onProgress,
}) async {
  return null;
}

Future<void> deletePartialFile(String localPath) async {}
