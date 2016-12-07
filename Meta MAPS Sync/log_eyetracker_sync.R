#Log/Eyetracker Output Sync

##Load Packages
pkgs <- c("dplyr", "tidyr", "ggplot2", "psych", "fuzzyjoin", "zoo", "readr") # list packages needed
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
suppressMessages(ipak(pkgs)) # take function, and give it that list

##Import Data
eyetracker <- (read.csv(paste("", "Volumes", "MAPS1", "Participant Recordings", id, "raw", paste(id,"_eyetracker.csv", sep = ""), sep = "/"))) 
log <-  (read_tsv(paste("", "Volumes", "MAPS1", "Participant Recordings", id, "raw", paste(id,"_log.tsv", sep = ""), sep = "/"))) 


##Tidy Data
#We can't use the difference join with two factors because it cannot subtract one from the other. They must be numeric. The current structure of the Timestamp column is MM:SS.MS. We can use "period to seconds" in lubridate to create a new joining column we will call timestamp_ sec. 

#create new vectors of timestamp_sec for log_nodesc and eyetracker
log_timestamp_sec <- (as.numeric(as.POSIXct(strptime(log$timestamp, format = "%H:%M:%OS"))) -
as.numeric(as.POSIXct(strptime("0", format = "%S"))))

eyetracker_timestamp_sec <- (as.numeric(as.POSIXct(strptime(eyetracker$timestamp, format = "%H:%M:%OS"))) - 
as.numeric(as.POSIXct(strptime("0", format = "%S"))))

#Create a new column for join in log_nodesc and eyetracker
log <- log%>%
mutate(timestamp_sec = log_timestamp_sec)

eyetracker <- eyetracker%>%
mutate(timestamp_sec = eyetracker_timestamp_sec)


#Tidy our log data for Joining later

#get rid of extra 10.4 timestamp entries at beginning - no descriptions at top
log_nodesc <- log[-(1:3), ] 

#mutate a new column for touch quadrant
log_nodesc <- log_nodesc %>%
mutate(touchquadrant = (ifelse (log_nodesc$event=="touch", lead(entry), NA)))

#get rid of multiple touchscreen rows
log_nodesc <- filter(log_nodesc, !grepl('touchquadrant', event)) 


##Join Log and Eyetracker Data
#fuzzy join log and eyetracker within .06 of the timestamp_sec column
sync_data <- difference_left_join(eyetracker, log_nodesc, by = "timestamp_sec", max_dist =.06) 


#This gives us an approximate start and end time for all the stimuli/touch responses. I need to figure out the correct distance that I should use for this fuzzy-join. .06 was used because the beginning of the session in the log is 10.4 and is 10.459 in the eyetracker data. This causes a few repeats later down the list (a start time in the log corresponds with more than one row of eyetracker rows). I will look into filling in the rows inbetween start and end points. For filled in rows source will be "calculated", event will be "play", and entry will equal the video. 

###Tidy Post-Join Data
#find unique values and fill cells below until next unique value
sync_data$entry <- na.locf(sync_data$entry,na.rm = FALSE) 


#This worked really well for filling the entry column. It is pretty messy at the beginning because of the touch screen test but that is ok because we do not really need to analyze that part. Now to replace the NA values in the source and event columns. We will have to change the data type of those columns because replace_na does not work with factor variables unless you are replace the NAs with a predetermined factor of that column. 


#change columns from factor to character
sync_data$source <- as.character(sync_data$source) 
sync_data$event <- as.character(sync_data$event)

#replace NA values in source and event columns with new values
sync_data <- sync_data %>%
replace_na(list(source = "calculated", event = "play")) 


#Ok. Everything looks good! Let's section off everything after the eyetracker calibration.

##Create Post-Calibration Data
#find the timestamp when the first filler starts
start <- sync_data %>% 
  filter(entry == "Session Map Fillers/filler1+map.mov") %>%
  filter(event == "start") %>%
  select(timestamp_sec.x)

#pull that timestamp from the dataframe (looking for better ways to do this)
start_val <- start[1,1] 

#create dataframe of everything after calibration and intro
sync_data_postcalib <- filter(sync_data, sync_data$timestamp_sec.x > start_val) 


##Export Cleaned Data
#Now let's export our two new dataframes.

#full synced dataset 
write.csv(sync_data, file = paste("", "Volumes", "MAPS1", "Participant Recordings", id, "synced", paste(id, "_full_data_sync.csv", sep=""), sep="/"))

#post-calibration synced dataset 
write.csv(sync_data_postcalib, paste("", "Volumes", "MAPS1", "Participant Recordings", id, "synced", paste(id, "_postcalib_data_sync.csv", sep=""), sep="/"))