% This function takes a directory, hashes it, and saves the hashes as
% 'HashTable.mat' in the directory.
%
% Code modified from Dan Ellis' 'demo_fingerprint.m'

function make_hashes(dirname)

global HashTable HashTableCounts
% Get the list of reference tracks to add (URLs in this case, but
% filenames work too)
% directory containing the mp3 files
%dirname = 'data';
% find all the MP3 files
dlist = dir(fullfile(dirname, '*.mp3'));
% put their full paths into a cell array
tks = []; 
for i = 1:length(dlist); ...
tks{i} = fullfile(dirname, dlist(i).name); ...
end
% Initialize the hash table database array 
clear_hashtable
% Calculate the landmark hashes for each reference track and store
% it in the array (takes a few seconds per track).
add_tracks(tks);

save([dirname '/HashTable.mat'],'HashTable')
save([dirname '/HastTableCounts.mat'],'HashTableCounts')

%% Implementation notes
%
% The main work in finding the landmarks is done by 
% <find_landmarks.m find_landmarks>.  This contains a number of
% parameters which can be tuned to control the density of
% landmarks.  In general, denser landmarks result in more robust
% matching (since there are more opportunities to match), but
% greater load on the database. 
%
% The scheme relies on just a few landmarks being common to both
% query and reference items.  The greater the density of landmarks,
% the more like this is to occur (meaning that shorter and noisier
% queries can be tolerated), but the greater the load on the
% database holding the hashes.
%
% The factors influencing the number of landmarks returned are:
%
% 1. The number of local maxima found, which in turn depends on the
% spreading width applied to the masking skirt from each found
% peak, the decay rate of the masking skirt behind each peak, and
% the high-pass filter applied to the log-magnitude envelope.
%
% 2. The number of landmark pairs made with each peak.  All maxes within 
% a "target region" following the seed max are made into pairs,
% so the larger this region is (in time and frequency), the
% more maxes there will be.  The target region is defined by a
% freqency half-width, and a time duration.
%
% Landmarks, which are 4-tuples of start time, start frequency, end
% frequency, and time difference, are converted into hashes with a
% start time and a 20 bit value describing the two frequencies and
% time difference, by <landmark2hash.m landmark2hash>.
% <hash2landmark.m hash2landmark> undoes this quantization.
%
% The matching relies on the "inverted index" hash table, 
% implemented by <clear_hashtable.m clear_hashtable>,
% <record_hashes.m record_hashes>, and <get_hash_hits.m get_hash_hits>.
% Currently, it's implemented as a single Matlab array, HashTable, 
% stored in a global of 20 x 10^20 uint32s (about 80MB of core).
% This can record just 20 occurrences of each landmark hash, but as 
% the reference database grows, this may fill up.  You can change 
% the size it is initialized to in clear_hashtable.m, but really
% it should be replaced with a real key/value database system.
%
% Because the track IDs are stored in just 18 bits of the uint32, 
% we can only handle 256k unique tracks in this implementation.
% Actually, I've only tried it with up to a few thousand.
%
% Other functions included are <add_tracks.m add_tracks>, which
% simply ties together find_landmarks, landmarks2hash, and
% save_hashes to enter a new reference track into the database, 
% <match_query.m match_query>, which extracts landmarks from a
% query audio and matches them against the reference database to
% returned ranked matches, <show_landmarks.m show_landmarks>, a
% utility to plot the actual landmarks on top of the spectrogram of
% a sound, and <illustrate_match.m illustrate_match>, which uses
% match_query and show_landmarks to show exactly which landmarks
% matched for a particular query's top match.  Utility function 
% <myls.m myls> is used by this demo script, 
% <demo_fingerprint.m demo_fingerprint> to build a list of files,
% including possibly over http.
% 
% Also included are <gen_random_queries.m gen_random_queries> to 
% generate random queries of a certain length from a list of tracks
% (possibly adding noise), <eval_fprint.m eval_fprint> to query the 
% fingerprinter with a cell array of query waveforms such as 
% gen_random_queries produces, and <addprefixsuffix.m
% addprefixsuffix> which is used to construct a cell array list of 
% full file names from a cell array of unique ID strings.

%% For Windows Users
%
% Robert Macrae of C4DM Queen Mary Univ. London sent me some 
% notes on <windows-notes.txt running this code under Windows>.

%% For Octave Users
%
% Joren Six has a nice page on 
% <http://tarsos.0110.be/artikels/lees/Dan_Ellis%2527_Robust_Landmark-Based_Audio_Fingerprinting_-_With_Octave Porting this code to Octave>.

%% See also AUDFPRINT Compiled Binary
%
% To make it easier to use in some large-scale experiments, I
% rewrote this code to function as a compiled Matlab stand-alone
% executable.  See the 
% <http://labrosa.ee.columbia.edu/matlab/audfprint/ AUDFPRINT>
% page for more details.

%% Download
%
% You can download all the code and data for these examples here:
% <fingerprint.tgz fingerprint.tgz>.
% For the demo code above, you will also need
% <http://www.ee.columbia.edu/~dpwe/resources/matlab/mp3read.html mp3 read/write>.

%% Referencing
%
% If you use this code in your research and you want to make a
% reference to where you got it, you can use the following
% citation:
%
% D. Ellis (2009), "Robust Landmark-Based Audio Fingerprinting", web resource, available: http://labrosa.ee.columbia.edu/matlab/fingerprint/ .

%% Acknowledgment
%
% This material is based in part upon work supported by the
% National Science Foundation under Grant No. IIS-0713334. Any
% opinions, findings and conclusions or recomendations expressed in
% this material are those of the author(s) and do not necessarily
% reflect the views of the National Science Foundation (NSF).  
%
% Last updated: $Date: 2012/05/14 19:45:56 $
% Dan Ellis <dpwe@ee.columbia.edu>

