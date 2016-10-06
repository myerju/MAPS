#Pre-CERT video split
  
##Load Packages
pkgs <- c("dplyr", "tidyr", "readr", "lubridate", "fuzzyjoin", "zoo") # list packages needed
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
suppressMessages(ipak(pkgs)) # take function, and give it that list

##Import Data
sync_type1 <- c("MAPS-001", "MAPS-002", "MAPS-003", "MAPS-004", "MAPS-005", "MAPS-006", "MAPS-007", "MAPS-008", "MAPS-009", "MAPS-010", "MAPS-011")

#import data
log <-  (read.csv(paste("", "Volumes", "MAPS1", "Participant Recordings", id, "synced", paste(id,"_log_webcam_sync.csv", sep = ""), sep = "/"))) 

#Before we can run CERT, we need to split our videos on which section we want to run. For now, we will be running the emotion reels. 
log$webcam_timestamp<- as.character(log$webcam_timestamp)

emotion_start <- log %>%
  filter(entry=="Emotion Reels/Surprise A.mov") %>%
  filter(event=="start") %>%
  select(webcam_timestamp)

duration_start <- hms(emotion_start)

if (id =="MAPS-011") {
  emotion_end <- log %>%
    filter(entry=="Emotion Reels/Happy A.mov") %>%
    filter(event=="end") %>%
    select(webcam_timestamp)
} else {
  emotion_end <- log %>%
    filter(entry=="Emotion Reels/Yawning A.mov") %>%
    filter(event=="end") %>%
    select(webcam_timestamp)
}

duration_end <- hms(emotion_end)

emotion_duration <- duration_end - duration_start

POSIXct_emotion_duration <- parse_date_time(emotion_duration,"ms")
emotion_duration <- format(POSIXct_emotion_duration, format="%H:%M:%OS")
#emotion_duration <- paste0("00:", emotion_duration)

#Export 
emotion_times <- cbind(emotion_start, emotion_end, emotion_duration)
colnames(emotion_times) <- c("start", "end", "duration")
write.csv(emotion_times, file = paste("", "Volumes", "MAPS1", "Participant Recordings", id, "CERT", paste(id,"_emotions_timepoints.csv", sep = ""), sep = "/"))