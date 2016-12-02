#Standardizing CERT output for graph with multiple observations of differing lengths

#load packages
library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)

#setwd and define filename
setwd("/Users/Marissa Renda/Documents/Senior Fall 2016/PSY499 - Senior Thesis/CERT/")
filename <- "au_6_cheek_raise" #only change this and you'll be fine for the whole script

#import data
cert_standardize <- read_excel(paste(filename, ".xlsx", sep=""), col_names = TRUE)

#delete extra row
cert_standardize <- cert_standardize[-1,]

#transpose data
cert_standardize <- as.data.frame(t(cert_standardize))

#not needed but keep if you want to play with it later
#last_frame_val <- apply(cert_standardize, 1, function(x) tail(na.omit(x), 1))
#last_frame_val <- as.numeric(last_frame_val)

#create column names
names(cert_standardize) <- as.character(1:ncol(cert_standardize))

#create participant column
cert_standardize <- mutate(cert_standardize, id = seq_along(cert_standardize$`1`))
cert_standardize$id

#gather data into long format, order by id instead of frame, get rid of rows with na values for intensity
cert_standardize <- gather(cert_standardize, key = "frame", value = "intensity", -id) %>%
  arrange(id) %>%
  filter(!is.na(intensity))

#make frame numeric
cert_standardize$frame <- as.numeric(cert_standardize$frame)

#added thing for later (can definitely take out if not needed)
cert_standardize_tf2 <- cert_standardize

#create scaled columns and standardized frame numbers
target_frame <- 159

cert_standardize <- cert_standardize %>%
  group_by(id) %>%
  mutate(num_frames = max(frame)) %>%
  mutate(scale_factor = target_frame/num_frames) %>%
  mutate(scaled_frame = frame*scale_factor)

#change structure of intensity from integer (discrete) to numeric (continuous)
cert_standardize$intensity <- as.numeric(cert_standardize$intensity)

#Create data frame with necessary columns
cert_output <- cert_standardize %>%
  select(id, scaled_frame, intensity)

#Export CSV
write.csv(cert_output, file = paste(filename, "_standardized.csv", sep=""))


#Plot
au_tf1 <- ggplot(cert_standardize, aes(x=scaled_frame, y = intensity, group=factor(id))) 
au_tf1 <- au_tf1 + geom_line(aes(color=factor(id))) 
#au_tf1 <- au_tf1 + ylim(-4,4) #change numbers here to set y min and max for your y axis
au_tf1 <- au_tf1 + ggtitle(filename)
au_tf1


#So one more thing! Katina and I discovered a nice thing for you to show. 
#You have enough data that the shape of the graph doesn't much based on the number
#you standardize it with. I'll put some graphs below to show you.

#Changing the target frame number

#we made a copy of the tidied but not standardized data above called cert_standardize_tf2
#create scaled columns and standardized frame numbers
target_frame_2 <- 300

cert_standardize_tf2 <- cert_standardize_tf2 %>%
  group_by(id) %>%
  mutate(num_frames = max(frame)) %>%
  mutate(scale_factor = target_frame_2/num_frames) %>%
  mutate(scaled_frame = frame*scale_factor)

#change structure of intensity from integer (discrete) to numeric (continuous)
cert_standardize_tf2$intensity <- as.numeric(cert_standardize_tf2$intensity)

#Plot
au_tf2 <- ggplot(cert_standardize_tf2, aes(x=scaled_frame, y = intensity, group=factor(id))) 
au_tf2 <- au_tf2 + geom_line(aes(color=factor(id))) 
#au_tf2 <- au_tf2 + ylim(-4,4) #change numbers here to set y min and max for your y axis
au_tf2 <- au_tf2 + ggtitle(filename)
au_tf2

#Save plots as pdfs
#Target frame 1
ggsave(au_tf1, file = paste("/Figures/", filename, "_standardized_", target_frame, ".pdf", sep= ""), height=9, width=12)

#Target frame 2
ggsave(au_tf2, file = paste("/Figures/", filename, "_standardized_", target_frame_2, ".pdf", sep= ""), height=9, width=12)
