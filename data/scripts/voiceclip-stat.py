import os
import wave
import contextlib
import csv

def get_wav_duration(file_path):
    """Return the duration of a WAV file in seconds."""
    with contextlib.closing(wave.open(file_path, 'r')) as wf:
        frames = wf.getnframes()
        rate = wf.getframerate()
        duration = frames / float(rate)
        return duration

def find_wav_files(base_folder):
    """Recursively find all WAV files in a folder."""
    wav_files = []
    for root, _, files in os.walk(base_folder):
        for file in files:
            if file.lower().endswith(".wav"):
                full_path = os.path.join(root, file)
                try:
                    duration = get_wav_duration(full_path)
                    wav_files.append((full_path, duration))
                except Exception as e:
                    print(f"Error reading {full_path}: {e}")
    return wav_files

def write_csv(data, output_csv):
    """Write the path and duration data to a CSV file."""
    with open(output_csv, mode='w', newline='', encoding='utf-8') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(['File Path', 'Duration (seconds)'])
        for row in data:
            writer.writerow(row)

def main():
    base_folder = './voice-clips'
    output_csv = "voice-clip-durations.csv"

    print("Scanning for WAV files...")
    wav_data = find_wav_files(base_folder)

    # Sort by duration descending
    wav_data.sort(key=lambda x: x[1], reverse=True)

    print(f"Writing results to {output_csv}...")
    write_csv(wav_data, output_csv)

    print(f"Done! {len(wav_data)} files processed.")

if __name__ == "__main__":
    main()