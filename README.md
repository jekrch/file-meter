# File Meter :open_file_folder:

A Docker-based tool to analyze file sizes in a specified directory, with options to find the largest individual files or aggregate by file types.

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/jekrch/file-meter.git
   ```
2. Navigate to the cloned directory:
   ```
   cd file-meter
   ```
3. Ensure Docker is running

## Usage

### Windows

Run `file_meter.bat`:
```
file_meter.bat C:\path\to\directory 10
```
Or double-click to run interactively.

### Linux

Make the script executable:
```
chmod +x file_meter.sh
```

Run the script:
```
./file_meter.sh /path/to/directory 10
```
Or run without arguments for interactive mode.

### Analyzing by File Types

To aggregate results by file type, add the `-t` flag:
```
file_meter.bat C:\path\to\directory 10 -t
```
or
```
./file_meter.sh /path/to/directory 10 -t
```

When run interactively, the script will prompt you to choose between analyzing individual files or file types.

## Sample Output

### Analyzing Individual Files

```
PS C:\projects\file-meter> .\file_meter.ps1 C:\Users\username\Documents 10
Starting file analysis...
Executing: docker run -it -v "C:\Users\username\Documents:/data" file-size-analyzer /data 10
Analyzing files...
Press Ctrl+C to stop the scan and see current results.
Counting files...
Total files to process: 1257
Scanning files...
Progress: [##################################################.] 100%
Processing...
Analysis complete. Largest 10 files:
Size            | File
----------------+--------------------------------------------------
105.6 MB        | Projects/Video/final_cut.mp4
87.3 MB         | Music/album_recording.wav
45.2 MB         | Images/vacation_photos.zip
22.8 MB         | Documents/annual_report.pdf
18.5 MB         | Software/installer.exe
15.3 MB         | Backups/documents_backup.zip
12.9 MB         | Projects/3D/model_render.blend
10.7 MB         | Music/concert_live.mp3
9.8 MB          | Documents/presentation.pptx
8.6 MB          | Images/family_portrait.psd
```

### Analyzing by File Types

```
PS C:\projects\file-meter> .\file_meter.ps1 C:\Users\username\Documents 10 -t
Starting file analysis...
Executing: docker run -it -v "C:\Users\username\Documents:/data" file-size-analyzer /data 10 -t
Analyzing files...
Press Ctrl+C to stop the scan and see current results.
Counting files...
Total files to process: 1257
Scanning files...
Progress: [##################################################.] 100%
Processing...
Analysis complete. Top 10 file types by total size:
Total Size           | Count      | Avg Size        | File Type
--------------------+------------+-----------------+------------------
256.8 MB             | 15         | 17.1 MB         | mp4
187.5 MB             | 32         | 5.9 MB          | wav
142.7 MB             | 1205       | 121.3 KB        | jpg
98.6 MB              | 8          | 12.3 MB         | zip
45.3 MB              | 67         | 692.3 KB        | pdf
38.9 MB              | 12         | 3.2 MB          | exe
35.6 MB              | 28         | 1.3 MB          | psd
22.4 MB              | 5          | 4.5 MB          | blend
18.7 MB              | 42         | 456.1 KB        | mp3
15.2 MB              | 23         | 676.9 KB        | pptx
```
