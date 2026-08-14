import 'dart:io';

typedef ContentMediaDownloadProgress =
    void Function(int bytesDownloaded, int? totalBytes);

Future<int?> downloadUrlToFile({
  required String url,
  required String localPath,
  ContentMediaDownloadProgress? onProgress,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) {
    throw StateError('La URL firmada de la descarga no es válida.');
  }

  final client = HttpClient();
  IOSink? sink;
  final partialFile = File('$localPath.part');
  var existingBytes = 0;

  try {
    if (await partialFile.exists()) {
      existingBytes = await partialFile.length();
    }

    final request = await client.getUrl(uri);
    if (existingBytes > 0) {
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=$existingBytes-');
    }

    final response = await request.close();
    final resumes = existingBytes > 0 && response.statusCode == 206;
    if (response.statusCode != HttpStatus.ok && !resumes) {
      throw HttpException(
        'La descarga respondió con ${response.statusCode}.',
        uri: uri,
      );
    }

    if (!resumes && existingBytes > 0) {
      existingBytes = 0;
    }

    await partialFile.parent.create(recursive: true);
    sink = partialFile.openWrite(
      mode: resumes ? FileMode.append : FileMode.write,
    );

    final responseLength = response.contentLength;
    final totalBytes = responseLength < 0
        ? null
        : existingBytes + responseLength;
    var downloadedBytes = existingBytes;
    onProgress?.call(downloadedBytes, totalBytes);

    await for (final chunk in response) {
      sink.add(chunk);
      downloadedBytes += chunk.length;
      onProgress?.call(downloadedBytes, totalBytes);
    }

    await sink.flush();
    await sink.close();
    sink = null;

    final targetFile = File(localPath);
    if (await targetFile.exists()) {
      await targetFile.delete();
    }
    await partialFile.rename(localPath);
    return downloadedBytes;
  } catch (_) {
    await sink?.close();
    rethrow;
  } finally {
    client.close(force: true);
  }
}

Future<void> deletePartialFile(String localPath) async {
  final partialFile = File('$localPath.part');
  if (await partialFile.exists()) {
    await partialFile.delete();
  }
}
