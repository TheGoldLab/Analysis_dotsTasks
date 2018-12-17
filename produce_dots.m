%% AIM: write a script that displays the dots stimulus from a specific trial

clear all

%% set up a dotsDrawable object

% get specific parameters to draw the dots:
%    TODO: deal with
% endDirection
% presenceCP
% timeCP
% randSeedBase
% coherenceSTD
% dotsOff-dotsOn

dotsParams.stencilNumber = 1;
dotsParams.pixelSize = 2;
dotsParams.diameter = 10;
dotsParams.speed = 1;
dotsParams.yCenter = 0;
dotsParams.xCenter = 0;
dotsParams.density = 60;
dotsParams.direction = 180;
dotsParams.coherence = 0;
dotsParams.dotsDuration = 2;
dotsParams.randSeedBase = 1;

displayIndex = 1;

%% Draw the dots
info_frames=draw_dots(dotsParams, displayIndex);

%% Construct stimulus matrix to feed the ME calculator
% count number of frames actually drawn
numFrames=1;
while ~isempty(info_frames{numFrames})
    numFrames = numFrames+1;
end
numFrames = numFrames - 1; % correct for last increment of while loop

% boolean needed because of the structure of the ME calculation
if ~mod(numFrames,2) % true if numFrames is even
    addTrivialFrame=true;
    length_t = numFrames+1;
else
    addTrivialFrame=false;
    length_t = numFrames;
end

% loop over frames and construct a t-x matrix
length_x=1001; % size of x dimension (MUST BE ODD)
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