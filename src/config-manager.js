const fs = require('fs');
const path = require('path');

class ConfigManager {
    constructor() {
        this.configPath = path.join(__dirname, '..', 'config.json');
        this.defaultConfig = {
            enabled: true,
            volume: 0.5,
            sounds: {
                completion: 'completion.wav',
                notification: 'notification.wav',
                error: 'error.wav',
                toolComplete: 'tool-complete.wav'
            },
            events: {
                Stop: true,
                Notification: true,
                PostToolUse: false,
                PreToolUse: false
            }
        };
    }

    getConfig() {
        if (fs.existsSync(this.configPath)) {
            return { ...this.defaultConfig, ...JSON.parse(fs.readFileSync(this.configPath, 'utf8')) };
        }
        return this.defaultConfig;
    }

    updateConfig(newConfig) {
        const currentConfig = this.getConfig();
        const mergedConfig = { ...currentConfig, ...newConfig };
        fs.writeFileSync(this.configPath, JSON.stringify(mergedConfig, null, 2));
        return mergedConfig;
    }

    resetConfig() {
        fs.writeFileSync(this.configPath, JSON.stringify(this.defaultConfig, null, 2));
        return this.defaultConfig;
    }

    validateConfig(config) {
        const errors = [];
        
        if (typeof config.enabled !== 'boolean') {
            errors.push('enabled must be a boolean');
        }
        
        if (typeof config.volume !== 'number' || config.volume < 0 || config.volume > 1) {
            errors.push('volume must be a number between 0 and 1');
        }
        
        if (typeof config.sounds !== 'object') {
            errors.push('sounds must be an object');
        }
        
        return errors;
    }
}

module.exports = ConfigManager;