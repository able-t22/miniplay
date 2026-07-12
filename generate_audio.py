"""
Generates short, real, playable WAV files with distinct little melodies
so the app has actual audio to play. Pure stdlib (wave + math) - no
external downloads, no copyright concerns.
"""
import wave, math, struct, os

OUT_DIR = "static/audio"
os.makedirs(OUT_DIR, exist_ok=True)

SAMPLE_RATE = 44100

# note frequencies (Hz)
NOTES = {
    "C4": 261.63, "D4": 293.66, "E4": 329.63, "F4": 349.23,
    "G4": 392.00, "A4": 440.00, "B4": 493.88, "C5": 523.25,
    "D5": 587.33, "E5": 659.25, "F5": 698.46, "G5": 783.99,
}

def tone(freq, duration, volume=0.3):
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # simple envelope to avoid clicks (attack/release)
        env = min(1, i / (0.02 * SAMPLE_RATE), (n - i) / (0.02 * SAMPLE_RATE))
        val = volume * env * math.sin(2 * math.pi * freq * t)
        samples.append(val)
    return samples

def write_wav(filename, melody):
    """melody: list of (note_name, duration_sec)"""
    all_samples = []
    for note, dur in melody:
        all_samples.extend(tone(NOTES[note], dur))
    path = os.path.join(OUT_DIR, filename)
    with wave.open(path, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = b"".join(struct.pack("<h", int(s * 32767)) for s in all_samples)
        wf.writeframes(frames)
    print(f"wrote {path} ({len(all_samples)/SAMPLE_RATE:.1f}s)")

# a handful of distinct little melodies, looped to make ~10-15s clips
MELODIES = {
    "song1.wav":  [("C4",.4),("E4",.4),("G4",.4),("C5",.6)] * 4,   # song_id 1 Golden Hour
    "song2.wav":  [("D4",.3),("F4",.3),("A4",.3),("D5",.5)] * 4,   # song_id 2 Sunset Drive
    "song5.wav":  [("E4",.35),("G4",.35),("B4",.35),("E5",.55)]*4, # song_id 5 Neon Dreams
    "song8.wav":  [("A4",.3),("C5",.3),("E5",.3),("A4",.5)] * 4,   # song_id 8 Static Bloom
    "song11.wav": [("G4",.25),("A4",.25),("B4",.25),("D5",.4)]*4,  # song_id 11 Concrete Verses
    "song14.wav": [("F4",.4),("A4",.4),("C5",.4),("F4",.6)] * 4,   # song_id 14 Blue Room
    "song20.wav": [("C5",.2),("D5",.2),("E5",.2),("G5",.3)] * 5,   # song_id 20 Circuit Dreams
    "song24.wav": [("B4",.3),("D5",.3),("F5",.3),("B4",.5)] * 4,   # song_id 24 Midnight Hours
    "song27.wav": [("G4",.35),("B4",.35),("D5",.35),("G4",.5)]*4,  # song_id 27 Open Road
    "song39.wav": [("E4",.3),("A4",.3),("C5",.3),("E5",.5)] * 4,   # song_id 39 Firelight
}

for fname, melody in MELODIES.items():
    write_wav(fname, melody)

print("done -", len(MELODIES), "audio files generated")
