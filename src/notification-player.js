const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

class NotificationPlayer {
    #config = null;
    #soundsDir = null;

    constructor(configPath = null, soundsDir = null) {
        this.#soundsDir = soundsDir || path.join(__dirname, 'sounds');
        this.#config = this.#loadConfig(configPath);
    }

    #loadConfig(configPath = null) {
        const defaultConfig = {
            enabled: true,
            volume: 0.5,
            sounds: {
                completion: 'completion.wav',
                notification: 'notification.wav',
                error: 'error.wav',
                toolComplete: 'tool-complete.wav'
            }
        };

        try {
            const configFile = configPath || path.join(__dirname, '..', 'config.json');
            if (!fs.existsSync(configFile)) {
                return defaultConfig;
            }

            const configData = JSON.parse(fs.readFileSync(configFile, 'utf8'));
            return { ...defaultConfig, ...configData };
        } catch (error) {
            console.warn(`⚠️  Failed to load config: ${error.message}`);
            return defaultConfig;
        }
    }

    async playSound(soundType) {
        if (!this.isEnabled()) {
            return { success: false, message: 'Notifications disabled' };
        }

        const soundFile = this.#getSoundFile(soundType);
        if (!soundFile) {
            return { success: false, message: `Sound type '${soundType}' not found` };
        }

        if (!fs.existsSync(soundFile)) {
            return { success: false, message: `Sound file not found: ${path.basename(soundFile)}` };
        }

        try {
            await this.#executePlayCommand(soundFile);
            return { success: true, message: `Played: ${soundType}` };
        } catch (error) {
            return { success: false, message: `Playback failed: ${error.message}` };
        }
    }

    #getSoundFile(soundType) {
        const soundName = this.#config.sounds[soundType];
        return soundName ? path.join(this.#soundsDir, soundName) : null;
    }

    #getPlayCommand(soundFile) {
        const platform = process.platform;
        const volume = Math.max(0, Math.min(1, this.#config.volume));

        const commands = {
            darwin: `afplay "${soundFile}" -v ${volume}`,
            linux: `aplay "${soundFile}" -q`,
            win32: `powershell -c "(New-Object Media.SoundPlayer '${soundFile}').PlaySync()"`,
            default: `echo -e "\a"`
        };

        return commands[platform] || commands.default;
    }

    async #executePlayCommand(soundFile) {
        return new Promise((resolve, reject) => {
            const command = this.#getPlayCommand(soundFile);
            
            exec(command, (error, stdout, stderr) => {
                if (error) {
                    reject(new Error(`Audio playback failed: ${error.message}`));
                } else {
                    resolve({ stdout, stderr });
                }
            });
        });
    }

    isEnabled() {
        return this.#config.enabled === true;
    }

    setVolume(volume) {
        this.#config.volume = Math.max(0, Math.min(1, volume));
    }

    getVolume() {
        return this.#config.volume;
    }

    getAvailableSounds() {
        return Object.keys(this.#config.sounds);
    }

    getConfig() {
        return { ...this.#config };
    }
}

module.exports = NotificationPlayer;

if (require.main === module) {
    const player = new NotificationPlayer();
    const soundType = process.argv[2] || 'completion';
    
    player.playSound(soundType)
        .then(result => console.log(result.message))
        .catch(error => console.error(error.message));
}