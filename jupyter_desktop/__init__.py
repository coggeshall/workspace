import os


HERE = os.path.dirname(os.path.abspath(__file__))

def setup_desktop():
    return {
        'command': [os.path.join(HERE, 'bin/startup')],
        'port': 6901,
        'timeout': 30,
        'new_browser_window': True
    }
