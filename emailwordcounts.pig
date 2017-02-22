A = LOAD '../../Downloads/maildir/*' Using PigStorage('\n') as (line:chararray);
B = FILTER A BY (NOT(STARTSWITH(line,'Message-ID:') OR STARTSWITH(line,'From:') OR STARTSWITH(line,'To:') OR STARTSWITH(line, 'Mime-Version:') OR STARTSWITH(line, 'Subject:') OR STARTSWITH(line, 'Content-Type') OR STARTSWITH(line, 'Content-Transfer-Encoding:') OR STARTSWITH(line, 'X-') OR STARTSWITH(line, 'Date:')));
CLEAN_B = FOREACH B GENERATE REPLACE(line, '[^\\w]+', ' ') as delimited_line;
C = FOREACH CLEAN_B generate FLATTEN(TOKENIZE(LOWER(delimited_line),' ')) as word;
D = GROUP C BY word;
E = FOREACH D generate FLATTEN(group) as word, COUNT($1) as wordCount;
sorted_E = order E by wordCount desc;
filtered_sorted_E = filter sorted_E by wordCount>=10l;
STORE filtered_sorted_E INTO '../../pig/output' Using PigStorage(',');
