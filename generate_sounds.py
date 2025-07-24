import numpy as np
import wave
import os

def generate_tone(filename, frequency, duration=0.5, volume=0.5):
    sample_rate = 44100
    t = np.linspace(0, duration, int(sample_rate * duration))
    
    # Generate tone with envelope
    envelope = np.exp(-3 * t)
    wave_data = (volume * 32767 * envelope * np.sin(2 * np.pi * frequency * t)).astype(np.int16)
    
    # Save as WAV
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(wave_data.tobytes())

def generate_chord(filename, frequencies, duration=0.8, volume=0.5):
    sample_rate = 44100
    t = np.linspace(0, duration, int(sample_rate * duration))
    
    # Generate chord
    wave_data = np.zeros_like(t)
    envelope = np.exp(-2 * t)
    
    for freq in frequencies:
        wave_data += envelope * np.sin(2 * np.pi * freq * t)
    
    wave_data = (volume * 32767 * wave_data / len(frequencies)).astype(np.int16)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(wave_data.tobytes())

def generate_error_sound(filename):
    sample_rate = 44100
    duration = 0.3
    t = np.linspace(0, duration, int(sample_rate * duration))
    
    # Descending tone for error
    freq_start, freq_end = 800, 200
    frequencies = freq_start + (freq_end - freq_start) * t / duration
    envelope = np.exp(-4 * t)
    
    wave_data = (0.4 * 32767 * envelope * np.sin(2 * np.pi * frequencies * t)).astype(np.int16)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(wave_data.tobytes())

# Create sounds directory
os.makedirs('src/sounds', exist_ok=True)

# Generate different sounds
generate_chord('src/sounds/completion.wav', [523.25, 659.25, 783.99], 0.8, 0.5)  # C-E-G chord
generate_tone('src/sounds/notification.wav', 800, 0.3, 0.4)  # Simple notification
generate_error_sound('src/sounds/error.wav')  # Error sound
generate_tone('src/sounds/tool-complete.wav', 600, 0.2, 0.3)  # Tool completion

print("Sound files generated successfully!")
