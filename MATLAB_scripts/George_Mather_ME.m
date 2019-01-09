%% Experiment with George Mather's approach
% as described here: http://www.georgemather.com/Model.html
clear

% load data outputted by produce_dots.m
data_folder = '/Users/adrian/Documents/MATLAB/projects/dotsStimExperiments/data/';
filename = 'detail_19';
load([data_folder,filename,'.mat'])

% count number of frames actually drawn
numFrames=count_frames(info_frames);

% boolean addTrivialFrame needed because of the structure of the ME calculation
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

nx=(length_x-1)/2;
nt=(length_t-1)/2;
max_x = 5; % radius of apperture in deg
max_t = .5/10; % Duration of impulse response of temporal filter (sec) 


me=MotionEnergy_1(txMatrix, nx, nt, max_x, max_t, true);
fprintf('\n\nprojection onto x dimension: %g\n\n',me);
% average 1-D ME across rows of stimulus
running_avg = 0;
numerator = length_x;
for rr = 1: length_x
    txMatrix=squeeze(xytMatrix(:,rr,:))';
    if addTrivialFrame
        txMatrix=[txMatrix; zeros(1,length_x)];
    end
    me=MotionEnergy_1(txMatrix,nx,nt,max_x,max_t, false);
    running_avg = running_avg + me;
    if me == 0
        numerator = numerator - 1;
    end
end
running_avg=running_avg / numerator;
fprintf('\n\nRow-avge net motion energy = %g\n\n',running_avg);