import 'dart:convert';
import 'dart:io';

import 'package:aikiglobal/core/data/media/content_media_file_downloader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reanuda el archivo parcial y lo publica al terminar', () async {
    final body = utf8.encode('contenido multimedia de prueba');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      final range = request.headers.value(HttpHeaders.rangeHeader);
      final rangeMatch = range == null
          ? null
          : RegExp(r'bytes=(\d+)-').firstMatch(range);
      final start = rangeMatch == null ? 0 : int.parse(rangeMatch.group(1)!);

      if (start > 0) {
        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-${body.length - 1}/${body.length}',
        );
      }
      request.response.add(body.sublist(start));
      await request.response.close();
    });

    final directory = await Directory.systemTemp.createTemp('aiki-download');
    addTearDown(() => directory.delete(recursive: true));
    final localPath = '${directory.path}${Platform.pathSeparator}media.bin';
    final partialFile = File('$localPath.part');
    await partialFile.writeAsBytes(body.sublist(0, 8));

    final downloaded = await downloadUrlToFile(
      url: 'http://${server.address.host}:${server.port}/media',
      localPath: localPath,
    );

    expect(downloaded, body.length);
    expect(await File(localPath).readAsBytes(), body);
    expect(await partialFile.exists(), isFalse);
  });
}
