library(seewave)
library(tidyverse)
library(lubridate)
library(tuneR)

# load parameters ----
source("parameters.r")
# folder where the data will be saved
deployment_folder <- file.path(out_dir_path,paste(project_id,deployment_id,"FLAC",sep = "_"))

# get soundfiles path----
soundfiles_data <- NULL
for(i in 1:nrow(metadata)){
  #debug
  # i=1
  print(i)
  # list files with right extension in the input folder
  soundfiles_in_path <- unlist(
    list.files(metadata$in_dir_path[i],
               pattern = format_in,
               full.names = T,
               recursive = T))
  # slice metadata to match extension of the wav files length
  tmp_soundfiles_data <- slice(metadata,rep(i,length(soundfiles_in_path)))
  
  tmp_soundfiles_data$soundfiles_in_path <- soundfiles_in_path
  
  # append to tibble
  if(i==1){
    soundfiles_data <- tmp_soundfiles_data
  }else{
    soundfiles_data <- full_join(tmp_soundfiles_data, soundfiles_data,by=c("in_dir_path", "site_id", "recorder_id", "soundfiles_in_path"))
  }
}
# to avoid variable reuse
rm(soundfiles_in_path)
# right dimensions

dim(soundfiles_data)
#no NAs
sum(is.na(soundfiles_data))

# Add filesize ----

soundfiles_data <- soundfiles_data %>%
  mutate(filesize_MB = round(file.size(soundfiles_in_path)*0.000001,1))

# Add datetime----
soundfiles_data <- soundfiles_data %>%
  mutate(in_date_time = str_extract(basename(soundfiles_in_path),pattern = "[0-9]{8}_[0-9]{6}"))

# Add datetime UTC ----
to_UTC <- function(datetime_str){
  str_time_intimezone<-ymd_hms(datetime_str,tz = in_timezone)
  utc_time <- with_tz(str_time_intimezone,tzone="UTC")
  utc_time_str <- str_replace_all(as.character(utc_time),"-","")
  utc_time_str <- str_replace_all(as.character(utc_time_str)," ","_")
  utc_time_str <- str_replace_all(as.character(utc_time_str),":","")
  return(paste0(utc_time_str,"Z"))
}

soundfiles_data <- soundfiles_data %>%
  mutate(utc_date_time_str = to_UTC(in_date_time))
# check right utc conversion
k<-sample(1:nrow(soundfiles_data),1)
paste(soundfiles_data$in_date_time[k],soundfiles_data$utc_date_time_str[k])
# set sampling rate ----
soundfiles_data <- soundfiles_data %>%
  mutate(samplingrate = paste0(str_pad(samplingrate_kHz,
                                       3,side = "left",pad = 0),"K"))
soundfiles_data

# Data validation: check unique files----
df_tmp <- soundfiles_data %>%
  group_by(site_id,recorder_id,in_date_time,basename(soundfiles_in_path)) %>%
  summarise(n=n())
unique(df_tmp$n)
# Data validation: site id ----
length(unique(soundfiles_data$site_id))
length(unique(soundfiles_data$recorder_id))
length(unique(soundfiles_data$in_dir_path))

# Create columns of date and hour ----
soundfiles_data <- soundfiles_data %>%
  mutate(in_date = str_sub(in_date_time,1,8)) %>%
  mutate(in_time = str_sub(in_date_time,10,16))
soundfiles_data$in_date
soundfiles_data$in_time

# create new basenames ----
soundfiles_data <- soundfiles_data %>%
  mutate(new_basename = paste(paste0(project_id,deployment_id),samplingrate,site_id,recorder_id,paste0(utc_date_time_str,format_out),sep="_"))
soundfiles_data$new_basename
unique(soundfiles_data$new_basename)

# filter out small error files----
soundfiles_data_biggerfiles <- soundfiles_data %>%
  filter(filesize_MB > ignore_if_less_than_MB)
soundfiles_data_biggerfiles
# how many were small
nrow(soundfiles_data)-nrow(soundfiles_data_biggerfiles)

# Create soundfiles_out_path  ----
soundfiles_data_biggerfiles <- soundfiles_data_biggerfiles %>%
  mutate(soundfiles_out_path=file.path(
    deployment_folder,
    #per site and recorder folder
    paste(project_id, 
          deployment_id, 
          site_id,
          recorder_id,
          sep="_"),
    #per site, recorder and date folder
    paste(paste0(project_id,deployment_id),
          site_id,
          recorder_id,
          in_date,
          sep="_"),
    new_basename))
soundfiles_data_biggerfiles$soundfiles_out_path[1]

# export data ----
write_csv(soundfiles_data, paste0("data/soundfiles_data_", deployment_id ,".csv"))
write_csv(soundfiles_data_biggerfiles,paste0("data/soundfiles_data_biggerfiles_", deployment_id ,".csv"))
