import os


HERE = os.path.dirname(os.path.abspath(__file__))

def setup_desktop():
    with open("/tmp/vncpw", "r") as f:
        pass = f.readline().strip()
    return {
        'command': [os.path.join(HERE, 'bin/startup')],
        'port': 6901,
        'timeout': 30,
        'mappath': {
            '/': '/vnc.html?path=desktop%2Fwebsockify&resize=remote&autoconnect=true&password=' + pass,
        },
        'new_browser_window': True
    }
