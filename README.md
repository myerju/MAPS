# MAPS Scripts

* Created as an extra copy of MAPS analyses for backup purposes

##List of files included:
* log_eyetracker_sync.Rmd - script for merging log file and eyetracker csv
* MAPS Analyses.Rmd - script for pre-markup analyses
* filenametocsv.py - Rosemary's script for creating a csv of filenames and duration times (in mm:ss.msec and ss.msec)
* sync.R - Kevin's orginal R script for syncronizing accelerometer output and video based on button beep
* final_sync.m - Archana's matlab script for syncronizing accelerometer and video based on beep (based on sync.R)
* CERT_raw_facet_plot.Rmd - R script for tidying CERT data and creating facet plot for basic analysis
* CERT_video_split.Rmd - R script to output start and end timepoints of emotion reels from log files
* emotions_split - Shell script to cut webcam videos based on emotion reel timepoints for CERT analysis


Order to run scripts in:
1) log_eyetracker_sync.rmd - merge log file and eyetracker csv
2) MAPS_sync.rmd - sync webcamera video and log file using touch screen
3) sync.R - sync webcamera and log file using audios
4) CERT_video_split.rmd - get timepoints for python clip script
5) export all to MAPS1/Participant Recordings
6) Enter in session data to REDCap
7) run MAPS Analyses.rmd for beginning analyses

