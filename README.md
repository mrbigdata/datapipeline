# datapipeline
processing Enron Email dataset

Problem definition: 
The goal is to produce a list of word counts for words that appear in the bodies of the Enron emails (ignoring the headers.) Only words that appear 10 or more times will be included. The list must be sorted in order of count descending.

Assumptions:
No realtime input data stream support requirement
Lines with headers start with Message-ID:,From:,To:,Mime-Version:,Subject:,Content-Type,Content-Transfer-Encoding:,X-,Date:.
If email is a reply or forward, and the original email is included, the original email's headers are also going to be omitted.

Solution:
Implemented mapreduce (pigscript) job to filter and reduce email input data.

Input: path to root directory
Output: list of word counts stored in CSV file.

Tests run:
1. input : empty directory
   ouput: empty file

2. input : single file with one word
   output: given word cunted once

3. input : email file including email headers
   output: word counts, headers not included

4. input : 2 different subdirectories with 1 email file in each subdirectory, 5 appearances of the same word in one file, 5 appearances of the same word in the other file.
   output: the word count is included in the result and equals 10.

5. test words with less than 10 appearances are not included in output.

6. test word counts in the result are in descending order.

7. test with entire Enron dataset, verify job finishes successfully and produces non empty sorted word count result.

8. TODO : test scheduling and incremental word count update scenario. Currently pig script runs on the entire dataset to generate result, but it could be more efficient to only process new source data assuming the input dataset is ever refreshed with new data ( on hourly/daily? basis).

Deployment/Execution instructions:
Currently only local PigServer running mode supported.
To run locally:
install Apache Pig
./$PIG_HOME/bin/pig -x local $SCRIPT_HOME/emailwordcounts.pig 

EMR deployment:
Upload input data to S3 data bucket
Upload pig script to operations s3 bucket
schedule pig script to run via Amazon/EMR SDK. (At this point also support incremental word count refresh by merging new data in. (For this we'll need to also keep intermediate output data with all word counts including the ones lower than 10.)) 
  
TODO:
Modify pig script to make input and output paths configurable, currently hardcoded.
Improve input data cleansing/validation.
Automate scheduling/deployment.It is very useful if input data is stored on s3 in date relative path, e.g. yyyy/mm/dd/HH/...
Make sure there is QA environment to verify end to end automation. The best way to ensure data reliability is to have large controlled data sets used by automated regression/QA environment.
Add alerts/healthchecks. Production alerts make sure intermediate data aggregation steps are correct, for example it makes sense to compare file sizes, non empty intermediate steps etc.
