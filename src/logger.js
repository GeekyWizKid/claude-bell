const { createWriteStream } = require('fs');
const path = require('path');

class Logger {
    #logLevel = 'info';
    #logFile = null;
    #writeStream = null;

    static LEVELS = {
        ERROR: 0,
        WARN: 1,
        INFO: 2,
        DEBUG: 3
    };

    constructor(options = {}) {
        this.#logLevel = options.level || process.env.LOG_LEVEL || 'info';
        this.#logFile = options.file || null;
        
        if (this.#logFile) {
            this.#writeStream = createWriteStream(this.#logFile, { flags: 'a' });
        }
    }

    error(message, ...args) {
        this.#log('ERROR', message, args);
    }

    warn(message, ...args) {
        this.#log('WARN', message, args);
    }

    info(message, ...args) {
        this.#log('INFO', message, args);
    }

    debug(message, ...args) {
        this.#log('DEBUG', message, args);
    }

    #log(level, message, args = []) {
        if (this.#shouldLog(level)) {
            const timestamp = new Date().toISOString();
            const formattedMessage = `[${timestamp}] ${level}: ${message}`;
            const fullMessage = args.length > 0 ? `${formattedMessage} ${args.join(' ')}` : formattedMessage;

            console[level.toLowerCase()]?.(fullMessage) || console.log(fullMessage);
            
            if (this.#writeStream) {
                this.#writeStream.write(fullMessage + '\n');
            }
        }
    }

    #shouldLog(level) {
        const levelValue = Logger.LEVELS[level] ?? Logger.LEVELS.INFO;
        const currentLevel = Logger.LEVELS[this.#logLevel.toUpperCase()] ?? Logger.LEVELS.INFO;
        return levelValue <= currentLevel;
    }

    close() {
        if (this.#writeStream) {
            this.#writeStream.end();
        }
    }
}

class NotificationError extends Error {
    constructor(message, code = 'NOTIFICATION_ERROR') {
        super(message);
        this.name = 'NotificationError';
        this.code = code;
        Error.captureStackTrace(this, NotificationError);
    }
}

class ValidationError extends NotificationError {
    constructor(message) {
        super(message, 'VALIDATION_ERROR');
        this.name = 'ValidationError';
    }
}

class ConfigError extends NotificationError {
    constructor(message) {
        super(message, 'CONFIG_ERROR');
        this.name = 'ConfigError';
    }
}

class AudioError extends NotificationError {
    constructor(message) {
        super(message, 'AUDIO_ERROR');
        this.name = 'AudioError';
    }
}

module.exports = {
    Logger,
    NotificationError,
    ValidationError,
    ConfigError,
    AudioError
};