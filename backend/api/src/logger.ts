type Level = 'debug' | 'info' | 'warn' | 'error';

interface LogMeta {
  [key: string]: unknown;
}

function emit(level: Level, msg: string, meta?: LogMeta): void {
  const line = JSON.stringify({
    level,
    time: new Date().toISOString(),
    msg,
    ...meta,
  });
  // CloudWatch indexes JSON automatically; stdout/stderr split is enough.
  if (level === 'error') {
    console.error(line);
  } else {
    console.log(line);
  }
}

export const logger = {
  debug: (msg: string, meta?: LogMeta) => emit('debug', msg, meta),
  info: (msg: string, meta?: LogMeta) => emit('info', msg, meta),
  warn: (msg: string, meta?: LogMeta) => emit('warn', msg, meta),
  error: (msg: string, meta?: LogMeta) => emit('error', msg, meta),
};
