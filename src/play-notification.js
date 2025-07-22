const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

class NotificationManager {
    constructor() {
        this.configPath = path.join(__dirname, '..', 'config.json');
        this.loadConfig();
    }

    loadConfig() {
        if (fs.existsSync(this.configPath)) {
            this.config = JSON.parse(fs.readFileSync(this.configPath, 'utf8'));
        } else {
            this.config = {
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
    }

    playNotification(type) {
        if (!this.config.enabled) return;

        const playerPath = path.join(__dirname, 'notification-player.js');
        const command = `node "${playerPath}" ${type}`;
        
        exec(command, (error) => {
            if (error) {
                console.error(`Notification error: ${error.message}`);
            }
        });
    }
}

const manager = new NotificationManager();
const eventType = process.argv[2] || 'notification';
manager.playNotification(eventType);