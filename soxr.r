library(seewave)
library(tidyverse)
library(lubridate)
library(tuneR)
library(parallel)
library(pbapply)

# load parameters ----
source("parameters.r")
source("stopandcontinue_sox.r")
# folder where the data will be saved
deployment_folder <- file.path(out_dir_path,paste(project_id,deployment_id,"FLAC",sep = "_"))

# import files ----
soundfiles_data_biggerfiles <- read_csv(paste0("data/soundfiles_data_biggerfiles_", deployment_id ,".csv"))

############################ create folder tree ----

# Deployment folder first
dir.create(deployment_folder)

# On it, create folders per site and recorder ----
for(i in 1:nrow(metadata)){
  dir_path <- file.path(deployment_folder,paste(project_id, 
                                                deployment_id, 
                                                metadata$site_id[i],
                                                metadata$recorder_id[i],
                                                sep="_"))
  dir.create(dir_path)
}

# On them, create folders per date-----
siterecorderdate_groups <- soundfiles_data_biggerfiles %>%
  group_by(recorder_id,site_id,in_date) %>%
  slice(1) %>%
  select(site_id,recorder_id,in_date)

siterecorderdate_groups

for(i in 1:nrow(siterecorderdate_groups)){
  dir_path <- file.path(
    # per site and recorder folders
    deployment_folder, paste(project_id, 
                             deployment_id, 
                             siterecorderdate_groups$site_id[i],
                             siterecorderdate_groups$recorder_id[i],
                             sep="_"),
    paste(paste0(project_id,deployment_id),
          siterecorderdate_groups$site_id[i],
          siterecorderdate_groups$recorder_id[i],
          siterecorderdate_groups$in_date[i],
          sep="_"))
  dir.create(dir_path)
}

############################ Run sox ----
# find how many already converted files and files still to convert ----
soundfiles_data_biggerfiles <- soundfiles_data_biggerfiles %>%
  mutate(out_file_exists = file.exists(soundfiles_out_path))

soundfiles_data_biggerfiles_juststilltobeconverted <- soundfiles_data_biggerfiles %>%
  filter(out_file_exists==F)

print(paste("N Converted files:",sum(soundfiles_data_biggerfiles$out_file_exists)))
print(paste("Still to convert:",sum(!soundfiles_data_biggerfiles$out_file_exists)))
print(paste0("Percentage converted: ",round(100*sum(soundfiles_data_biggerfiles$out_file_exists)/length(soundfiles_data_biggerfiles$out_file_exists),2),"%"))

# run sox ----
n_files_to_run <-nrow(soundfiles_data_biggerfiles)-length(list.files(deployment_folder,pattern = format_out,recursive = T))
print("N Files to process:")
print(n_files_to_run)

run_sox <- function(x){
  if(!file.exists(stop_file)){
    if(!file.exists(soundfiles_data_biggerfiles_juststilltobeconverted$soundfiles_out_path[x])){
      system(paste0(
        "sox ",
        soundfiles_data_biggerfiles_juststilltobeconverted$soundfiles_in_path[x],
        " -C",compression_factor," ",
        soundfiles_data_biggerfiles_juststilltobeconverted$soundfiles_out_path[x]))}
    else{
      print(paste("Skipping file to not overwrite:",soundfiles_data_biggerfiles_juststilltobeconverted$soundfiles_out_path[x]))
    }
  } else {
    print("STOPPING FILE FOUND, STOPPING SOXR NOW")
    print("TO CONTINUE, RUN continue_sox FIRST")
    break()
  }
}

# continue_sox()
pblapply(1:n_files_to_run,function(x){run_sox(x)},cl = cores_to_use)

# Check names ----
soundfiles_data_biggerfiles %>%
  filter(file_exists)
############# notes of the behavior of the system ----
# UTC conversion and folder structure----
# If there is a file that will be fixed to a latter date because of UTC time correction
# it will still be stored in the date of the original date of the site
# Example:  a file recorded in Costa Rica, before the UTC conversion is named 
# T2250NespCR01_000H_NP01_NP01_20190903_180001.flac
# it will be stored as 
# T2250NespCR01_000H_NP01_NP01_20190904_000001Z.flac
# it the folder
# T2250NespCR01_NP01_NP01_20190903
# with the other files that were recorded that same date,
# eventhough its filename says 20190904
# this will enable an accurate utc conversion, while making it not too
# complicated, since it is good to have all the audios of each day
# in the same folder
# and anyways, the data analysis will use the filenames, 
# not the directory names

# samplingrate ----
# The samplingrate is entered by the user as a nunmber of kHz, Ex:
# 48

# ----