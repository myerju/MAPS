#Log/Webcamera Output Sync

##Load Packages
pkgs <- c("dplyr", "tidyr", "ggplot2", "psych", "fuzzyjoin", "zoo", "readr") # list packages needed
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
suppressMessages(ipak(pkgs)) # take function, and give it that list

id <- "MAPS-014"

##Method 1: Touchscreen and examiner voice
#The first 10 participants were recorded with touchscreen tap and the examiner saying the numbers "one" through "four". The timestamps for the spoken numbers were found manually by opening the webcam videos in audacity. 

sync_type1 <- c("MAPS-001", "MAPS-002", "MAPS-003", "MAPS-004", "MAPS-005", "MAPS-006", "MAPS-007", "MAPS-008", "MAPS-009", "MAPS-010", "MAPS-011")


#import data
log <-  read_tsv(paste("", "Volumes", "MAPS1", "Participant Recordings", id, "raw", paste(id,"_log.tsv", sep = ""), sep = "/"))
video_sync <- read.csv(paste("", "Users", username, "Box Sync", "MAPS", "Data", "Sync", "sync_timestamps.csv", sep = "/"), header = T) #csv of manually recorded timestamps


#create a column that gives the difference between the log timestamp and the webcam timestamp
if (id %in% sync_type1) {
  video_sync <- mutate(video_sync, vid_diff = one_time_sec - touch_time_sec)
} else {
  video_sync <- mutate(video_sync, vid_diff = webcam_beep_start_sec - maincomp_beep_start_sec)
}

#There are a few where the session started before the webcamera so if the difference is < 0, the difference will be subtracted from the timestamp and if the difference is > 0, the difference will be added to the timestamp.
#create an ID column in log
log <- log %>%
  mutate(ID = id)

#make ID a character type
video_sync$ID <- as.character(video_sync$ID)

#left join by ID number
log_sync <- left_join(log, video_sync, by = c("ID"))

#create new vectors of timestamp_sec for log_nodesc and eyetracker
log_timestamp_sec <- (as.numeric(as.POSIXct(strptime(log$timestamp, format = "%H:%M:%OS"))) -
                        as.numeric(as.POSIXct(strptime("0", format = "%S"))))

#Create a new column for join 
log_sync <- log_sync%>%
  mutate(timestamp_sec = log_timestamp_sec)

#find offset for session log (log does not start at zero)
log_offset <- log_sync[[1, 16]]

#mutate a new column based on if difference is positive or negative
log_sync <- mutate(log_sync, webcam_timestamp_sec = 
                     ifelse(vid_diff > 0, timestamp_sec + vid_diff - log_offset, 
                            timestamp_sec - abs(vid_diff) - log_offset))



#fix the format for a column in format HH:MM:SS.msec
webcam_timestamp <- format(.POSIXct(log_sync$webcam_timestamp_sec), "%M:%OS")
webcam_timestamp <- paste0("00:", webcam_timestamp)

log_sync <- log_sync %>%
  mutate(webcam_timestamp = webcam_timestamp)

#delete_extra_col
extra <- c("ID", "one_time", "one_time_sec", "touch_time", "touch_time_sec", "webcam_beep", "maincomp_beep", "notes")
log_sync <- log_sync[, !names(log_sync) %in% extra]


##Export Synced Log file
write.csv(log_sync, file =paste("", "Volumes", "MAPS1", "Participant Recordings", id, "synced", paste(id,"_log_webcam_sync.csv", sep = ""), sep = "/")) 