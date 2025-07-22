const fs = require('fs');
const path = require('path');

class ConfigManager {
    #configPath = null;
    #defaultConfig = null;

    constructor(configPath = null) {
        this.#configPath = configPath || path.join(__dirname, '..', 'config.json');
        this.#defaultConfig = {
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
        try {
            if (!fs.existsSync(this.#configPath)) {
                this.saveConfig(this.#defaultConfig);
                return this.#defaultConfig;
            }

            const fileContent = fs.readFileSync(this.#configPath, 'utf8');
            const userConfig = JSON.parse(fileContent);
            const validatedConfig = this.#validateAndMerge(userConfig);
            
            return validatedConfig;
        } catch (error) {
            console.warn(`⚠️  Config error: ${error.message}. Using defaults.`);
            return this.#defaultConfig;
        }
    }

    saveConfig(config) {
        try {
            const validatedConfig = this.#validateAndMerge(config);
            const configDir = path.dirname(this.#configPath);
            
            if (!fs.existsSync(configDir)) {
                fs.mkdirSync(configDir, { recursive: true });
            }

            fs.writeFileSync(this.#configPath, JSON.stringify(validatedConfig, null, 2));
            return validatedConfig;
        } catch (error) {
            throw new Error(`Failed to save config: ${error.message}`);
        }
    }

    updateConfig(updates) {
        const currentConfig = this.getConfig();
        const newConfig = { ...currentConfig, ...updates };
        return this.saveConfig(newConfig);
    }

    resetConfig() {
        return this.saveConfig(this.#defaultConfig);
    }

    getDefaultConfig() {
        return { ...this.#defaultConfig };
    }

    getConfigPath() {
        return this.#configPath;
    }

    #validateAndMerge(userConfig) {
        const merged = { ...this.#defaultConfig, ...userConfig };
        
        merged.enabled = this.#validateBoolean(merged.enabled, 'enabled', this.#defaultConfig.enabled);
        merged.volume = this.#validateNumber(merged.volume, 'volume', this.#defaultConfig.volume, 0, 1);
        merged.sounds = this.#validateObject(merged.sounds, 'sounds', this.#defaultConfig.sounds);
        merged.events = this.#validateObject(merged.events, 'events', this.#defaultConfig.events);

        merged.sounds = this.#validateSounds(merged.sounds);
        merged.events = this.#validateEvents(merged.events);

        return merged;
    }

    #validateBoolean(value, name, defaultValue) {
        return typeof value === 'boolean' ? value : defaultValue;
    }

    #validateNumber(value, name, defaultValue, min, max) {
        const num = Number(value);
        return !isNaN(num) && num >= min && num <= max ? num : defaultValue;
    }

    #validateObject(value, name, defaultValue) {
        return value && typeof value === 'object' && !Array.isArray(value) 
            ? value 
            : defaultValue;
    }

    #validateSounds(sounds) {
        const validated = {};
        for (const [key, value] of Object.entries(this.#defaultConfig.sounds)) {
            validated[key] = typeof sounds[key] === 'string' ? sounds[key] : value;
        }
        return validated;
    }

    #validateEvents(events) {
        const validated = {};
        for (const [key, value] of Object.entries(this.#defaultConfig.events)) {
            validated[key] = typeof events[key] === 'boolean' ? events[key] : value;
        }
        return validated;
    }

    validateConfig(config) {
        const errors = [];

        if (typeof config.enabled !== 'boolean') {
            errors.push('enabled must be a boolean');
        }

        if (typeof config.volume !== 'number' || config.volume < 0 || config.volume > 1) {
            errors.push('volume must be a number between 0 and 1');
        }

        if (!config.sounds || typeof config.sounds !== 'object') {
            errors.push('sounds must be an object');
        } else {
            for (const [key, value] of Object.entries(config.sounds)) {
                if (typeof value !== 'string') {
                    errors.push(`sound.${key} must be a string`);
                }
            }
        }

        if (!config.events || typeof config.events !== 'object') {
            errors.push('events must be an object');
        } else {
            for (const [key, value] of Object.entries(config.events)) {
                if (typeof value !== 'boolean') {
                    errors.push(`event.${key} must be a boolean`);
                }
            }
        }

        return errors;
    }
}

module.exports = ConfigManager;