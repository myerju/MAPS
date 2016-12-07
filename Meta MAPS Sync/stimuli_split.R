#Stimuli video split

##Load Packages
pkgs <- c("dplyr", "tidyr", "readr", "lubridate", "fuzzyjoin", "zoo") # list packages needed
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
suppressMessages(ipak(pkgs)) # take function, and give it that list

id <- "MAPS-014"

##Import Data
sync_type1 <- c("MAPS-001", "MAPS-002", "MAPS-003", "MAPS-004", "MAPS-005", "MAPS-006", "MAPS-007", "MAPS-008", "MAPS-009", "MAPS-010", "MAPS-011")

#import data
log <-  (read.csv(paste("", "Volumes", "MAPS1", "Participant Recordings", id, "synced", paste(id,"_log_webcam_sync.csv", sep = ""), sep = "/"))) 

#Before we can run CERT, we need to split our videos on which section we want to run. For now, we will be running the emotion reels. 
log$webcam_timestamp<- as.character(log$webcam_timestamp)

stimuli_total <- c("Block 1/Sylvie_short.mov", "Block 1/Laugh Lessons-edit.mov", "Block 1/Twins Wall Tour-edit.mov", "Block 1/El Tiro Hand Tutting-Edit.mov", 
                   "Block 1/Heads Up-edit.mov", "Block 2/Arthur_short.mov", "Block 2/GMM_moviequiz_short.mov", "Block 2/Ukrainedude_roomtour_short.mov", 
                   "Block 2/Beanboozled_short.mov", "Block 3/Hannah_edit.mov", "Block 3/Boom Boom Balloon_short.mov", "Block 3/Charli's Crafty Kitchen_short.mov", 
                   "Block 3/Finish My Sentence_edit.mov", "Block 3/Lemonade_edit.mov", "Emotion Reels/Emotions Intro.mov", "Emotion Reels/Surprise A.mov", 
                   "Emotion Reels/Sad A.mov", "Emotion Reels/Fear A.mov", "Emotion Reels/Happy A.mov", "Emotion Reels/Yawning A.mov", 
                   "Story Retelling/Intro_stories.mov", "Story Retelling/Warm-ups.mov", "Story Retelling/Camping.mov", "Story Retelling/Fair.mov", 
                   "Story Retelling/Hiking.mov")

for(i in 1:25) {
  order <- i
  stimuli <- stimuli_total[order]
  stimuli_name <- substr(basename(stimuli), 1, nchar(basename(stimuli))-4)
  
  stimuli_start <- log %>%
    filter(entry==stimuli) %>%
    filter(event=="start") %>%
    select(webcam_timestamp)
  
  duration_start <- hms(stimuli_start)
  
  stimuli_end <- log %>%
    filter(entry==stimuli) %>%
    filter(event=="end") %>%
    select(webcam_timestamp)
  
  duration_end <- hms(stimuli_end)
  
  stimuli_duration <- duration_end - duration_start
  
  POSIXct_stimuli_duration <- parse_date_time(stimuli_duration,"ms") # doesn't work for videos under a minute
  stimuli_duration <- format(POSIXct_stimuli_duration, format="%H:%M:%OS")
  #emotion_duration <- paste0("00:", emotion_duration)
  
  #Export 
  stimuli_times <- cbind(stimuli_start, stimuli_end, stimuli_duration)
  colnames(stimuli_times) <- c("start", "end", "duration")
  write.csv(stimuli_times, file = paste("", "Volumes", "MAPS1", "Participant Recordings", id, "stimuli_split", "timepoints", paste(id,"_", stimuli_name, "_timepoints.csv", sep = ""), sep = "/"))
}

###TO DO: How to add in conditional statements if there is a break