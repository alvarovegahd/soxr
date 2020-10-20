# parameters ----
library(parallel)

# metadata: A metadata file with columns in_dir_path,	site_id and	recorder_id.
## in_dir_path column: is the path where the data pulled from a recorder's SD card is for that specific folder
## site_id and recorder_id columns: ids that correspond to the data contained in the folder specified by in_dir_path
metadata <- read_csv(file = "data/NespCO02_metadata.csv")

# input format
format_in = ".wav"

# output format
format_out = ".flac"

# NespCLO: CO: T2250, CR: T2260
project_id = "T2250"

# ID of deployment
deployment_id = "NespCO02"


# compression factor to use in sox
compression_factor = 2

# number of cpus to use
cores_to_use = detectCores()-1

# ignore files that have less than this file size
ignore_if_less_than_MB <- 5

# expected size - 1MB
reporting_MB_thershold <- 345

# samplingrate of the sound files
samplingrate_kHz <- 48

# timezone of the dataset
# in_timezone="America/Costa_Rica"
in_timezone="America/Bogota"

# path where the compressed data will be saved
# this path should exist already; it should be created by the user outside of soxr
out_dir_path = "/media/alvaro/HDOCOB05/"

# file that if exists, the run will be securely stopped 
stop_file = "/home/alvaro/stopsox.txt"