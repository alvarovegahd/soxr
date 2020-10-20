library(tidyverse)
continue_sox <- function(){
  source("parameters.r")
  file.remove(stop_file)
}

stop_sox <- function(){
  source("parameters.r")
  write_csv(data.frame("exit"),stop_file)
}
