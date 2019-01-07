%% Experiment with George Mather's approach
% as described here: http://www.georgemather.com/Model.html
clear
data_folder = '/Users/adrian/Documents/MATLAB/projects/dotsStimExperiments/data/';
filename = 'detail_13';
% load data outputted by produce_dots.m
load([data_folder,filename,'.mat'])


% count number of frames actually drawn
numFrames=count_frames(info_frames);

% boolean needed because of the structure of the ME calculation
if ~mod(numFrames,2) % true if numFrames is even
    addTrivialFrame=true;
    length_t = numFrames+1;
else
    addTrivialFrame=false;
    length_t = numFrames;
end

% loop over frames and construct both a t-x and a xyt matrix
length_x=101; % size of x dimension (MUST BE ODD)
txMatrix=zeros(length_t,length_x);
xytMatrix = zeros(length_x,length_x, length_t); % x-y-t
for ii=1:numFrames
    dotsMatrix = inspect_dotsFrameMatrix(info_frames, ii, length_x, false);
    xytMatrix(:,:,ii) = dotsMatrix>0;
    txMatrix(ii,:) = (sum(dotsMatrix,2)>0)'; % project all dots onto x-axis
end

if addTrivialFrame
    txMatrix=[txMatrix; zeros(1,length_x)];
end

MotionEnergy_1(txMatrix, (length_x-1)/2, (length_t-1)/2);