String userFriendlyErrorMessage(
  Object error, {
  String fallbackMessage =
      'Não foi possível concluir esta ação. Tente novamente.',
}) {
  final rawMessage = error.toString().replaceFirst('Exception: ', '').trim();
  final normalized = rawMessage.toLowerCase();

  if (normalized.contains('401') ||
      normalized.contains('token') ||
      normalized.contains('autent') ||
      normalized.contains('sessao') ||
      normalized.contains('sessão')) {
    return 'Sua sessão expirou. Entre novamente para continuar.';
  }

  if (normalized.contains('403')) {
    return 'Você não tem permissão para fazer isso.';
  }

  if (normalized.contains('404')) {
    return 'Não encontramos essas informações no momento.';
  }

  if (normalized.contains('timeout') ||
      normalized.contains('conex') ||
      normalized.contains('back-end indisponivel') ||
      normalized.contains('network') ||
      normalized.contains('socket') ||
      normalized.contains('dioexception')) {
    if (normalized.contains('back-end indisponivel')) {
      return rawMessage;
    }
    return fallbackMessage;
  }

  if (rawMessage.isEmpty) {
    return fallbackMessage;
  }

  return fallbackMessage;
}
