function numFrames=count_frames(cellOfFrameInfo)
% count number of frames actually drawn
numFrames=1;
while ~isempty(cellOfFrameInfo{numFrames})
    numFrames = numFrames+1;
end
numFrames = numFrames - 1; % correct for last increment of while loop
end