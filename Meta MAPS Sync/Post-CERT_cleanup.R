##Cleaning up CERT output
#CERT analyzes videos frame by frame. The video is taken at 30 frames per second. This section is `emotion_duration_sec` long and has `emotion_duration_sec*30` frames in it.

#define pathways
cert_file <- paste("", "Volumes", "MAPS1", "Participant Recordings", id, "CERT", paste(id,"_emotions.txt", sep = ""), sep = "/")
cert <- read.table(cert_file, sep="\t", skip = 2, header = T, na.strings = "NaN")

#find timestamp differences
start_row <- as.numeric(which(log$webcam_timestamp == emotion_start[1,]))
end_row <- as.numeric(which(log$webcam_timestamp == emotion_end[1,]))
emotion_log <- log[start_row:end_row,]
emotion_log <- mutate(emotion_log, timestamp_diff_sec = (timestamp_sec - lag(timestamp_sec)))

if (id %in% sync_type1) {
  emotion_log[1,10] = 0
} else {
  emotion_log[1,14] = 0
}

#create cumulative timestamp based on timestamp differences in log
emotion_log <- mutate(emotion_log, cum_timestamp = cumsum(timestamp_diff_sec))

end <- nrow(cert) #How many frames do we have in this video?

#create frame and cumulative timestamp columns in CERT csv
cert<- cert %>%   
  mutate(frame= c(1:end))

cert <- cert %>%
  mutate(cum_timestamp = ((frame-1)*(1/30)))

# Join CERT and log files
#fuzzy join log and eyetracker within .06 of the timestamp_sec column
cert <- difference_left_join(cert, emotion_log, by = "cum_timestamp", max_dist =.06) 

#put in order, then find unique values and fill cells below until next unique value
cert <- cert %>%
  arrange(frame)
cert$entry <- na.locf(cert$entry,na.rm = FALSE) 

#Create emotion column
cert <- cert %>%
  separate(entry, c("filepath", "emotion"), "/") %>%
  separate(emotion, c("emotion", "end"), "A")

#Delete extra columns
extra <- c("File","X", "source", "timestamp", "vid_diff", "webcam_timestamp", "timestamp_diff_sec", "filepath", "end")
cert <- cert[, !names(cert) %in% extra]
cert <- cert[c("frame", "cum_timestamp.x", "cum_timestamp.y", "timestamp_sec", "webcam_timestamp_sec",  "event", "emotion", "Mouth.Imp.X", "Y", "Left.Eye.Imp.X", "Y.1", "Right.Eye.Imp.X", "Y.2", "Mouth.Left.Corner.Imp.X", "Y.3", "Right.Eye.Nasal.Imp.X", "Y.4", "Mouth.Right.Corner.Imp.X", "Y.5", "Right.Eye.Temporal.Imp.X", "Y.6", "Left.Eye.Temporal.Imp.X", "Y.7", "Left.Eye.Nasal.Imp.X", "Y.8", "Nose.Imp.X", "Y.9", "Mouth.Left.Corner.X", "Y.10", "Mouth.Right.Corner.X", "Y.11", "X.AU.1..Inner.Brow.Raise", "X.AU.2..Outer.Brow.Raise", "X.AU.4..Brow.Lower", "X.AU.5..Eye.Widen", "X.AU.9..Nose.Wrinkle", "X.AU.10..Lip.Raise", "X.AU.12..Lip.Corner.Pull", "X.AU.14..Dimpler", "X.AU.15..Lip.Corner.Depressor", "X.AU.17..Chin.Raise", "X.AU.20..Lip.stretch", "X.AU.6..Cheek.Raise", "X.AU.7..Lids.Tight", "X.AU.18..Lip.Pucker", "X.AU.23..Lip.Tightener", "X.AU.24..Lip.Presser", "X.AU.25..Lips.Part", "X.AU.26..Jaw.Drop", "X.AU.28..Lips.Suck", "X.AU.45..Blink.Eye.Closure", "Fear.Brow..1.2.4.", "Distress.Brow..1..1.4.", "AU.10.Left", "AU.12.Left", "AU.14.Left", "AU.10.Right", "AU.12.Right", "AU.14.Right", "Gender", "Glasses", "Yaw", "Pitch", "Roll", "Smile.Detector", "Anger..v3.",  "Contempt..v3.", "Disgust..v3.", "Fear..v3.", "Joy..v3.", "Sad..v3.", "Surprise..v3.", "Neutral..v3.")] 
names <- c("frame", "cert_timestamp", "emotion_timestamp", "log_timestamp_sec", "webcam_timestamp_sec", "event", "emotion", "Mouth.Imp.X", "Mouth.Imp.Y", "Left.Eye.Imp.X", "Left.Eye.Imp.Y", "Right.Eye.Imp.X", "Right.Eye.Imp.Y", "Mouth.Left.Corner.Imp.X", "Mouth.Left.Corner.Imp.Y", "Right.Eye.Nasal.Imp.X", "Right.Eye.Nasal.Imp.Y", "Mouth.Right.Corner.Imp.X", "Mouth.Right.Corner.Imp.Y", "Right.Eye.Temporal.Imp.X", "Right.Eye.Temporal.Imp.Y", "Left.Eye.Temporal.Imp.X", "Left.Eye.Temporal.Imp.Y", "Left.Eye.Nasal.Imp.X", "Left.Eye.Nasal.Imp.Y", "Nose.Imp.X", "Nose.Imp.Y", "Mouth.Left.Corner.X", "Mouth.Left.Corner.Y", "Mouth.Right.Corner.X", "Mouth.Right.Corner.Y", "AU.1.Inner.Brow.Raise", "AU.2.Outer.Brow.Raise", "AU.4.Brow.Lower", "AU.5.Eye.Widen", "AU.9.Nose.Wrinkle", "AU.10.Lip.Raise", "AU.12.Lip.Corner.Pull", "AU.14.Dimpler", "AU.15.Lip.Corner.Depressor", "AU.17.Chin.Raise", "AU.20.Lip.stretch", "AU.6.Cheek.Raise", "AU.7.Lids.Tight", "AU.18.Lip.Pucker", "AU.23.Lip.Tightener", "AU.24.Lip.Presser", "AU.25.Lips.Part", "AU.26.Jaw.Drop", "AU.28.Lips.Suck", "AU.45.Blink.Eye.Closure", "Fear.Brow.1.2.4.", "Distress.Brow.1.1.4.", "AU.10.Left", "AU.12.Left", "AU.14.Left", "AU.10.Right", "AU.12.Right", "AU.14.Right", "Gender", "Glasses", "Yaw", "Pitch", "Roll", "Smile.Detector", "Anger.v3",  "Contempt.v3", "Disgust.v3", "Fear.v3", "Joy.v3", "Sad.v.", "Surprise.v3", "Neutral.v3.")

#assign column names to new tidied dataframe
colnames(cert) <- names

#make all column names lowercase
names(cert) <- names(cert) %>%
  tolower() 

#Export csv file
write.csv(cert, file = paste("", "Volumes", "MAPS1", "Participant Recordings", id, "CERT", paste(id,"_emotion_cert.csv", sep = ""), sep = "/"))