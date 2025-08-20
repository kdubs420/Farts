import wave, struct, math, random, os

SAMPLE_RATE = 44100

def write_wave(path, samples):
    with wave.open(path, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 16-bit
        wf.setframerate(SAMPLE_RATE)
        data = b''.join(struct.pack('<h', int(max(-1.0, min(1.0, s)) * 32767)) for s in samples)
        wf.writeframes(data)

def envelope(length, decay=5):
    return [math.exp(-decay * t / length) for t in range(length)]

def single_step(duration=0.2):
    n = int(SAMPLE_RATE * duration)
    env = [math.exp(-8 * i / n) for i in range(n)]
    return [ (math.sin(2*math.pi*60*i/SAMPLE_RATE) + 0.5*math.sin(2*math.pi*120*i/SAMPLE_RATE)) * env[i] * 0.8 for i in range(n) ]

def footstep_loop():
    step = single_step()
    pause = [0.0] * int(SAMPLE_RATE * 0.25)
    return step + pause + step + pause

def breathing_loop():
    total = SAMPLE_RATE
    samples = []
    for i in range(total):
        t = i / SAMPLE_RATE
        phase = t % 1.0
        if phase < 0.4:
            env = phase / 0.4
        else:
            env = max(0.0, 1 - (phase - 0.4)/0.6)
        noise = random.uniform(-1, 1)
        samples.append(noise * env * 0.3)
    return samples

def flashlight_flicker():
    n = int(SAMPLE_RATE * 0.1)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-40 * t)
        samples.append(math.sin(2*math.pi*3000*t) * env * 0.5)
    return samples

def heartbeat_loop(bpm=60):
    beat_interval = 60 / bpm
    total = int(SAMPLE_RATE * beat_interval)
    samples = [0.0] * total
    beat = single_step(0.1)
    for offset in (0, int(0.5 * total)):
        for i, s in enumerate(beat):
            idx = i + offset
            if idx < total:
                samples[idx] += s
    return samples

def push_grunt():
    dur = 0.25
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * t / dur)
        noise = random.uniform(-1, 1)
        samples.append(noise * env * 0.4)
    return samples

def push_impact():
    return single_step(0.3)

os.makedirs('Assets/SFX', exist_ok=True)
write_wave('Assets/SFX/footstep.wav', footstep_loop())
write_wave('Assets/SFX/sprint_breathing.wav', breathing_loop())
write_wave('Assets/SFX/flashlight_flicker.wav', flashlight_flicker())
write_wave('Assets/SFX/heartbeat_slow.wav', heartbeat_loop(60))
write_wave('Assets/SFX/heartbeat_fast.wav', heartbeat_loop(120))
write_wave('Assets/SFX/push_grunt.wav', push_grunt())
write_wave('Assets/SFX/push_impact.wav', push_impact())
