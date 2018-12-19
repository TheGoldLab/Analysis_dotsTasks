%% AIM: write a script that displays the dots stimulus and saves useful info about the stimulus

clear all

%% set up a dotsDrawable object

% get specific parameters to draw the dots:
%    TODO: deal with
% endDirection
% presenceCP
% timeCP
% dotsOff-dotsOn

dotsParams.stencilNumber = 1;
dotsParams.pixelSize = 5;
dotsParams.diameter = 10;
dotsParams.speed = 3;
dotsParams.yCenter = 0;
dotsParams.xCenter = 0;
dotsParams.density = 70;
dotsParams.direction = 0;
dotsParams.coherence = 50;
dotsParams.dotsDuration = .1; % in sec
dotsParams.randSeedBase = 1;
dotsParams.coherenceSTD = 0; % I don't know what that is

displayIndex = 1;

%% Draw the dots
info_frames=draw_dots(dotsParams, displayIndex);


%% Dump all stimulus data that will be used by our data analysis in R

%clear all
fileName = 'detail_4';
%fileToLoad = [fileName,'.mat'];
fileToWrite = [fileName,'.csv'];

%load(fileToLoad)

% count number of frames actually drawn
numFrames=count_frames(info_frames);

% column names in final csv file
colNames={'frameIdx', ...
          'onsetTime', ...
          'onsetFrame', ...
          'swapTime', ...
          'isTight', ...
          'dotIdx', ...
          'xpos', ...
          'ypos'};

numCols=length(colNames);

% build matrix that will be dumped as a csv file

bigNumber = 10000 * numFrames; % overestimate of the number of dots
dataMatrix = zeros(bigNumber,numCols);

matrixRow = 1;

for frameIdx = 1:numFrames
    currFrame = info_frames{frameIdx};
    
    % 2-by-numDots matrix for current frame
    dotsMatrix = currFrame.dotsFrameMatrix;
    
    numRowsForThisFrame = size(dotsMatrix,2);
    
    % prepare all but last 3 cols of the 'standard row' to fill
    standardRow = [frameIdx, currFrame.onsetTime, currFrame.onsetFrame,...
        currFrame.swapTime, currFrame.isTight];
    
    for dotIdx = 1:numRowsForThisFrame
        varyingRow = [dotIdx, dotsMatrix(:,dotIdx)'];
        dataMatrix(matrixRow,:) = [standardRow, varyingRow];
        matrixRow = matrixRow + 1;
    end
end

dataMatrix = dataMatrix(1:matrixRow-1, :);

T=array2table(dataMatrix, 'VariableNames', colNames);
writetable(T,fileToWrite,'WriteRowNames',true) 



%% Construct stimulus matrix to feed the ME calculator from George Mather
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
length_x=501; % size of x dimension (MUST BE ODD)
txMatrix=zeros(length_t,length_x);
xytMatrix = zeros(length_x,length_x, length_t); % x-y-t
for ii=1:numFrames
    dotsMatrix = inspect_dotsFrameMatrix(info_frames, ii, length_x, false);
    xytMatrix(:,:,ii) = dotsMatrix>0;
    txMatrix(ii,:) = sum(dotsMatrix,1)>0; % project all dots onto x-axis
end

if addTrivialFrame
    txMatrix=[txMatrix; zeros(1,length_x)];
end

MotionEnergy_1(txMatrix, (length_x-1)/2, (length_t-1)/2);

%% Redraw the dots, out of the 3D matrix gathered by snow-dots
% inspired from this post
% https://www.mathworks.com/matlabcentral/answers/326813-3d-matrix-to-video#answer_256221
% NOTE: this module will create/write the file v below
figure();
v = VideoWriter('dots_reconstructed_5.avi');
open(v);
imagesc(xytMatrix(:,:,1))
axis tight manual 
set(gca,'nextplot','replacechildren');
for k = 2:numFrames 
   imagesc(xytMatrix(:,:,k))
   frame = getframe;
   writeVideo(v,frame);
end
close(v);