#!/usr/bin/env python
#filenametocsv.py: read out directory info to csv
#Rosemary Ingham

from csv import DictWriter
from os import listdir, chdir, getcwd
from sys import argv
from subprocess import check_output

if __name__ == '__main__':
    #read in list of files
    if len(argv) < 2:
        exit('Must supply input directory!')
    for path in argv[1:]:
        file_list = listdir(path)
        original_directory = getcwd()
        #go into directory to analyze files
        chdir(path)
    file_dict = {}
    #get length
    for file in file_list:
        #audio files
        if not file.startswith("._"):
            if file[-3:] in ("wav" "mp3"):
                raw_output = check_output(["soxi", "-d", file])
                file_length = raw_output.decode("utf-8").strip()
                file_dict[file] = file_length
            #video giles
            elif file[-3:] in ("mp4", "mov"):
                #apparently all these are necessary
                raw_output = check_output(["ffprobe", "-v", "error",
                            "-show_entries", "format=duration", "-of",
                            "default=noprint_wrappers=1:nokey=1",
                            "-sexagesimal", file])
                file_length = raw_output.decode("utf-8").strip()
                file_dict[file] = file_length
            else:
                file_dict[file] = "N/A"
    #put the file where we started out
    chdir(original_directory)
    #write out to csv
    with open("files.csv", "w") as sink:
        sink_csv = DictWriter(sink, fieldnames = ["Filename", "Duration"])
        sink_csv.writeheader()
        for file_name, file_length in file_dict.items():
            new_row = {}
            new_row["Filename"] = file_name
            new_row["Duration"] = file_length
            sink_csv.writerow(new_row)