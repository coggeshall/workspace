import os


HERE = os.path.dirname(os.path.abspath(__file__))

def setup_desktop():
    with open("/tmp/vncpw", "r") as f:
        password = f.readline().strip()
    return {
        'command': [os.path.join(HERE, 'bin/startup')],
        'port': 6901,
        'timeout': 30,
        'mappath': {
            '/': '/vnc_lite.html?path=desktop%2Fwebsockify&resize=remote&autoconnect=true#password=' + password,
        },
        'new_browser_window': True
    }
