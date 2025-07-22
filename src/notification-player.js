const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

class NotificationPlayer {
    constructor() {
        this.soundsDir = path.join(__dirname, '..', 'sounds');
        this.config = this.loadConfig();
    }

    loadConfig() {
        const configPath = path.join(__dirname, '..', 'config.json');
        if (fs.existsSync(configPath)) {
            return JSON.parse(fs.readFileSync(configPath, 'utf8'));
        }
        return {
            enabled: true,
            volume: 0.5,
            sounds: {
                completion: 'completion.wav',
                notification: 'notification.wav',
                error: 'error.wav',
                toolComplete: 'tool-complete.wav'
            }
        };
    }

    async playSound(soundType) {
        if (!this.config.enabled) return;
        
        const soundFile = path.join(this.soundsDir, this.config.sounds[soundType]);
        if (!fs.existsSync(soundFile)) {
            console.warn(`Sound file not found: ${soundFile}`);
            return;
        }

        const command = this.getPlayCommand(soundFile);
        
        exec(command, (error) => {
            if (error) {
                console.error(`Audio playback error: ${error.message}`);
            }
        });
    }

    getPlayCommand(soundFile) {
        const platform = process.platform;
        const volume = this.config.volume;

        switch (platform) {
            case 'darwin': // macOS
                return `afplay "${soundFile}" -v ${volume}`;
            case 'linux':
                return `aplay "${soundFile}" -q`;
            case 'win32': // Windows
                return `powershell -c "(New-Object Media.SoundPlayer '${soundFile}').PlaySync()"`;
            default:
                return `echo -e "\a"`; // Fallback to system bell
        }
    }
}

// Main execution logic
const player = new NotificationPlayer();
const soundType = process.argv[2] || 'completion';
player.playSound(soundType);