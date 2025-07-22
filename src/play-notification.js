#!/usr/bin/env node

const NotificationPlayer = require('./notification-player');

class NotificationService {
    #player = null;
    #validTypes = new Set(['completion', 'notification', 'error', 'toolComplete']);

    constructor() {
        this.#player = new NotificationPlayer();
    }

    async play(type = 'notification') {
        const normalizedType = this.#normalizeType(type);
        
        if (!this.#isValidType(normalizedType)) {
            return this.#handleError(`Invalid sound type: ${type}. Available: ${this.#getAvailableTypes().join(', ')}`);
        }

        try {
            const result = await this.#player.playSound(normalizedType);
            this.#logResult(result);
            return result;
        } catch (error) {
            return this.#handleError(error.message);
        }
    }

    #normalizeType(type) {
        return String(type).toLowerCase().trim();
    }

    #isValidType(type) {
        return this.#validTypes.has(type);
    }

    #getAvailableTypes() {
        return [...this.#validTypes];
    }

    #logResult(result) {
        if (result.success) {
            console.log(`🎵 ${result.message}`);
        } else {
            console.warn(`⚠️  ${result.message}`);
        }
    }

    #handleError(message) {
        console.error(`❌ Error: ${message}`);
        return { success: false, message };
    }

    getStatus() {
        return {
            enabled: this.#player.isEnabled(),
            volume: this.#player.getVolume(),
            availableTypes: this.#getAvailableTypes()
        };
    }
}

function main() {
    const args = process.argv.slice(2);
    const soundType = args[0] || 'notification';
    
    const service = new NotificationService();
    
    if (args.includes('--status') || args.includes('-s')) {
        const status = service.getStatus();
        console.log('🔔 Notification Service Status');
        console.log('============================');
        console.log(`Enabled: ${status.enabled ? '✅' : '❌'}`);
        console.log(`Volume: ${Math.round(status.volume * 100)}%`);
        console.log(`Available types: ${status.availableTypes.join(', ')}`);
        return;
    }

    if (args.includes('--help') || args.includes('-h')) {
        console.log('🔔 Claude Code Bell - Usage');
        console.log('===========================');
        console.log('Usage: node play-notification.js [type] [options]');
        console.log('');
        console.log('Types:');
        console.log('  completion   - Task completion sound');
        console.log('  notification - General notification');
        console.log('  error        - Error notification');
        console.log('  toolComplete - Tool execution complete');
        console.log('');
        console.log('Options:');
        console.log('  --status, -s  Show current status');
        console.log('  --help,  -h   Show this help');
        return;
    }

    service.play(soundType);
}

if (require.main === module) {
    main();
}

module.exports = { NotificationService };