import time
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from etl_processor import process_file, init_db

LANDING_ZONE = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'landing')

class ETLHandler(FileSystemEventHandler):
    def on_created(self, event):
        if not event.is_directory and event.src_path.endswith('.csv'):
            print(f"New file detected: {event.src_path}")
            # Small delay to ensure file write is complete
            time.sleep(1)
            process_file(event.src_path)

def start_watching():
    # Ensure DB is ready
    init_db()
    
    event_handler = ETLHandler()
    observer = Observer()
    observer.schedule(event_handler, path=LANDING_ZONE, recursive=False)
    observer.start()
    
    print(f"Started watching {LANDING_ZONE} for new files...")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

if __name__ == "__main__":
    start_watching()
