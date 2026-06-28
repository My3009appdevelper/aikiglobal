import 'package:supabase_flutter/supabase_flutter.dart';

String contentMediaUploadErrorMessage(Object error) {
  if (error is StorageException) {
    final status = error.statusCode?.trim();
    final message = error.message.toLowerCase();
    final storageError = error.error?.toLowerCase();
    if (status == '401' ||
        status == '403' ||
        message.contains('row-level security') ||
        message.contains('permission') ||
        storageError == 'unauthorized') {
      return 'No tienes permisos para subir archivos al Storage. Revisa las políticas del bucket content.';
    }

    if (status == '404') {
      return 'No se encontró el bucket content o la ruta del archivo en Storage.';
    }

    return 'No se pudo subir el archivo a Storage. Revisa el bucket content y la conexión.';
  }

  if (error is PostgrestException) {
    final code = error.code?.trim();
    final message = error.message.toLowerCase();
    if (code == '42501' ||
        message.contains('row-level security') ||
        message.contains('permission denied')) {
      return 'No tienes permisos para registrar el archivo en content_media. Revisa RLS y permisos de la tabla.';
    }

    if (code == 'PGRST205' || code == 'PGRST204') {
      return 'Supabase no encuentra content_media o alguna columna esperada. Revisa que la tabla esté expuesta en la API.';
    }

    return 'No se pudo registrar el archivo en content_media. Revisa la configuración de Supabase.';
  }

  return 'No se pudo subir el archivo. Revisa tus permisos o conexión.';
}

String supabaseErrorDebugLabel(Object error) {
  if (error is StorageException) {
    return 'StorageException status=${error.statusCode} error=${error.error} message=${error.message}';
  }

  if (error is PostgrestException) {
    return 'PostgrestException code=${error.code} message=${error.message} details=${error.details} hint=${error.hint}';
  }

  return error.toString();
}
