# soxr

A toolbox to compress WAV files to FLAC using the standardized Cornell's Center for Conservation Bioacoustics' naming format. The code runs in parallel.

*Tested on Ubuntu 16 and 18; should work on macOS*

## Requirements: 

- Sox should be already installed in your PATH, so R can call it. You can confirm this by opening a terminal and running `sox --version`. If you get sox's version then it is in your PATH variable. The easiest way of making sure that it is on your PATH variable is by installing it doing `sudo apt install sox` on Ubuntu or `brew install sox` on macOS and then confirming by running `sox --version`.
- A metadata file with the columns: `in_dir_path`,	`site_id` and	`recorder_id`.
  + `in_dir_path` column: is the path where the data pulled from a recorder's SD card is for that specific folder
  + `site_id` and `recorder_id` columns: ids that correspond to thecan be run  data contained in the folder specified by in_dir_path
- Other parameters in the `parameters.r` file: metadata, format_in, format_out, project_id, deployment_id, compression_factor, cores_to_use, ignore_if_less_than_MB, reporting_MB_thershold, samplingrate_kHz, in_timezone, out_dir_path, stop_file


## Usage

1. Change `parameters.r` to match your case. **IMPORTANT:** This version won't accept spaces in the directories names.

2. Run the script `create_data_structure.r` and pay attention to the validation steps to make sure that it will work as expected.

3. Run `soxr.r`. It will create the directories and then will start running the compression. You can stop it securely at any point by creating a file in the path specified by the `stop_file` variable defined in `parameters.r`.

## Bug reports

If you have troubles using this, don't hesitate to reach out: ajv95 [at] cornell [dot] edu
