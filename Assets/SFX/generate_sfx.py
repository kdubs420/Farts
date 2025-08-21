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

def whisper_loop():
    dur = 2.0
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / n
        env = 0.2 + 0.8 * t  # grow over time
        noise = random.uniform(-1, 1)
        samples.append(noise * env * 0.2)
    return samples

def phase_dash_echo():
    dur = 0.5
    n = int(SAMPLE_RATE * dur)
    base = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-6 * t)
        base.append(math.sin(2 * math.pi * 200 * t) * env * 0.6)
    echo_gap = int(SAMPLE_RATE * 0.1)
    echo = [s * 0.5 for s in base]
    return base + [0.0] * echo_gap + echo

def dark_surge_blackout():
    dur = 0.8
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-3 * t)
        base = math.sin(2 * math.pi * 40 * t) + 0.5 * math.sin(2 * math.pi * 80 * t)
        samples.append(base * env * 0.7)
    return samples

def tag_impact():
    return single_step(0.15)

def infection_transform():
    dur = 1.0
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 60 + 240 * (t / dur)
        env = math.exp(-3 * t)
        samples.append(math.sin(2 * math.pi * freq * t) * env * 0.6)
    return samples

def ui_click():
    n = int(SAMPLE_RATE * 0.1)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-40 * t)
        samples.append(math.sin(2 * math.pi * 800 * t) * env * 0.4)
    return samples

def ui_hover():
    n = int(SAMPLE_RATE * 0.15)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-25 * t)
        samples.append(math.sin(2 * math.pi * 600 * t) * env * 0.3)
    return samples

def countdown_beep():
    n = int(SAMPLE_RATE * 0.25)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-12 * t)
        samples.append(math.sin(2 * math.pi * 1000 * t) * env * 0.5)
    return samples

def stinger(base):
    dur = 0.6
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-4 * t)
        samples.append((math.sin(2 * math.pi * base * t) + 0.5 * math.sin(2 * math.pi * 2 * base * t)) * env * 0.6)
    return samples

def stinger_lobby():
    return stinger(220)

def stinger_prep():
    return stinger(260)

def stinger_hunt():
    return stinger(300)

def stinger_endgame():
    return stinger(340)

def stinger_results():
    return stinger(180)

def portal_spawn_fanfare():
    dur = 1.0
    tones = [440, 660, 880]
    seg = int(SAMPLE_RATE * (dur / len(tones)))
    samples = []
    for f in tones:
        for i in range(seg):
            t = i / SAMPLE_RATE
            env = math.exp(-3 * t)
            samples.append(math.sin(2 * math.pi * f * t) * env * 0.5)
    return samples

def match_end_fanfare():
    dur = 1.2
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-2 * t)
        chord = (math.sin(2 * math.pi * 330 * t) + math.sin(2 * math.pi * 440 * t) + math.sin(2 * math.pi * 550 * t)) / 3
        samples.append(chord * env * 0.6)
    return samples

os.makedirs('Assets/SFX', exist_ok=True)

def ambient_hum():
    dur = 2.0
    n = int(SAMPLE_RATE * dur)
    return [math.sin(2 * math.pi * 50 * (i / SAMPLE_RATE)) * 0.1 for i in range(n)]

def metal_creak():
    dur = 2.0
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        noise = random.uniform(-0.5, 0.5)
        env = math.exp(-3 * t)
        samples.append((math.sin(2 * math.pi * 30 * t) + noise) * env * 0.4)
    return samples

def machinery_loop():
    dur = 3.0
    n = int(SAMPLE_RATE * dur)
    samples = []
    clank_interval = int(SAMPLE_RATE * 0.75)
    for i in range(n):
        t = i / SAMPLE_RATE
        hum = math.sin(2 * math.pi * 40 * t) * 0.1 + math.sin(2 * math.pi * 80 * t) * 0.05
        clank = 0.0
        pos = i % clank_interval
        if pos < int(SAMPLE_RATE * 0.05):
            env = math.exp(-40 * pos / SAMPLE_RATE)
            clank = math.sin(2 * math.pi * 200 * pos / SAMPLE_RATE) * env * 0.3
        samples.append(hum + clank)
    return samples

def forest_wind_loop():
    dur = 4.0
    n = int(SAMPLE_RATE * dur)
    samples = []
    prev = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        noise = random.uniform(-1, 1)
        prev = 0.98 * prev + 0.02 * noise
        gust = 0.5 + 0.5 * math.sin(2 * math.pi * 0.25 * t)
        howl = math.sin(2 * math.pi * 200 * t) * max(0.0, math.sin(2 * math.pi * 0.25 * t))**2
        samples.append(prev * gust * 0.3 + howl * 0.1)
    return samples

def asylum_hum_loop():
    dur = 3.0
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        base = math.sin(2 * math.pi * 55 * t) + 0.5 * math.sin(2 * math.pi * 110 * t)
        mod = math.sin(2 * math.pi * 2 * t) * 0.02
        samples.append((base * 0.08) + mod)
    return samples

def door_creak():
    dur = 1.0
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 80 + 120 * t
        env = math.sin(math.pi * t / dur)
        noise = random.uniform(-0.3, 0.3)
        samples.append((math.sin(2 * math.pi * freq * t) + noise) * env * 0.5)
    return samples

def switch_click():
    n = int(SAMPLE_RATE * 0.1)
    return [math.sin(2 * math.pi * 2000 * (i / SAMPLE_RATE)) * math.exp(-60 * i / SAMPLE_RATE) * 0.5 for i in range(n)]

def campfire_crackle_loop():
    dur = 3.0
    n = int(SAMPLE_RATE * dur)
    samples = [random.uniform(-0.02, 0.02) for _ in range(n)]
    step = int(SAMPLE_RATE * 0.1)
    burst = int(SAMPLE_RATE * 0.02)
    for start in range(0, n, step):
        for j in range(burst):
            idx = start + j
            if idx < n:
                env = math.exp(-50 * j / SAMPLE_RATE)
                samples[idx] += random.uniform(-1, 1) * env * 0.3
    return samples

def ensure_wave(path, gen):
    if not os.path.exists(path):
        write_wave(path, gen())

ensure_wave('Assets/SFX/footstep.wav', footstep_loop)
ensure_wave('Assets/SFX/sprint_breathing.wav', breathing_loop)
ensure_wave('Assets/SFX/flashlight_flicker.wav', flashlight_flicker)
ensure_wave('Assets/SFX/heartbeat_slow.wav', lambda: heartbeat_loop(60))
ensure_wave('Assets/SFX/heartbeat_fast.wav', lambda: heartbeat_loop(120))
ensure_wave('Assets/SFX/push_grunt.wav', push_grunt)
ensure_wave('Assets/SFX/push_impact.wav', push_impact)
ensure_wave('Assets/SFX/whisper_loop.wav', whisper_loop)
ensure_wave('Assets/SFX/phase_dash.wav', phase_dash_echo)
ensure_wave('Assets/SFX/dark_surge.wav', dark_surge_blackout)
ensure_wave('Assets/SFX/tag_impact.wav', tag_impact)
ensure_wave('Assets/SFX/infection_transform.wav', infection_transform)
ensure_wave('Assets/SFX/ui_click.wav', ui_click)
ensure_wave('Assets/SFX/ui_hover.wav', ui_hover)
ensure_wave('Assets/SFX/countdown_beep.wav', countdown_beep)
ensure_wave('Assets/SFX/stinger_lobby.wav', stinger_lobby)
ensure_wave('Assets/SFX/stinger_prep.wav', stinger_prep)
ensure_wave('Assets/SFX/stinger_hunt.wav', stinger_hunt)
ensure_wave('Assets/SFX/stinger_endgame.wav', stinger_endgame)
ensure_wave('Assets/SFX/stinger_results.wav', stinger_results)
ensure_wave('Assets/SFX/portal_spawn.wav', portal_spawn_fanfare)
ensure_wave('Assets/SFX/match_end_fanfare.wav', match_end_fanfare)
ensure_wave('Assets/SFX/ambient_hum.wav', ambient_hum)
ensure_wave('Assets/SFX/creaking_metal.wav', metal_creak)
ensure_wave('Assets/SFX/warehouse_machinery_loop.wav', machinery_loop)
ensure_wave('Assets/SFX/forest_wind_loop.wav', forest_wind_loop)
ensure_wave('Assets/SFX/asylum_hum_loop.wav', asylum_hum_loop)
ensure_wave('Assets/SFX/door_creak.wav', door_creak)
ensure_wave('Assets/SFX/switch_click.wav', switch_click)
ensure_wave('Assets/SFX/campfire_crackle_loop.wav', campfire_crackle_loop)
