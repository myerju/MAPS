import re, os, subprocess, csv

ids = ['002']
for id in ids:
    movpath = 'MAPS-' + id + '/raw/MAPS-' + id + '.mp4'
    csvpath = 'MAPS-' + id + '/CERT/MAPS-' + id + '_emotions_timepoints.csv'
    output = 'MAPS-' + id + '/CERT/MAPS-' + id + '_emotions.mp4'
    with open(csvpath, 'rt') as f:
        reader = csv.reader(f)
        for row in reader:
            start_time = row[1]
            duration = row[3]
subprocess.check_call(["ffmpeg", "-ss", start_time, "-t", duration, "-i", movpath, "-vcodec", "copy", "-acodec", "copy", output])
