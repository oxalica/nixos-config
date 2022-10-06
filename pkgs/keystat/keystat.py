from pathlib import Path
import datetime
import json
import os
import subprocess
import sys

PERIOD = 256
LOG_FILE = Path(os.environ['STATE_DIRECTORY']) / str(datetime.datetime.now())
KEYLOGGER_PATH = sys.argv[1]

keyMap = { 'TOTAL': 0 }

with subprocess.Popen(KEYLOGGER_PATH, text=True, stdout=subprocess.PIPE) as pipe:
    for line in pipe.stdout:
        record = json.loads(line)
        if record['state_name'] != 'PRESSED':
            continue
        key = f"{record['event_name']}-{record['key_name']}"
        keyMap[key] = keyMap.get(key, 0) + 1
        keyMap['TOTAL'] += 1

        if keyMap['TOTAL'] % PERIOD == 1:
            tmpFile = LOG_FILE.with_suffix('.tmp');
            tmpFile.write_text(''.join(f'{k} {n}\n' for k, n in keyMap.items()))
            tmpFile.rename(LOG_FILE)

print('Broken pipe', file=sys.stderr)
exit(1)
