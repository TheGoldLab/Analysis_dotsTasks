function squareMatrix=inspect_dotsFrameMatrix(frameInfoStruct, frameNumber, numPixelLength, displayMatrix)
% display a frame of dots
% ARGS:
% RETURN: an x-by-y matrix, where going down the rows increases x and going
% from left to right increases y. Matrix entries count number of dots that
% fell in the corresponding bin.
% inspired from this post
% https://www.mathworks.com/matlabcentral/answers/298669-how-to-bin-2d-data#answer_230992
xy = frameInfoStruct{frameNumber}.dotsFrameMatrix';
EDGES = linspace(0,1,numPixelLength);
squareMatrix = hist3(xy, 'Edges', {EDGES,EDGES});
if displayMatrix
    imshow(squareMatrix, []); % Show as image
    %colormap(hot(256));
    %colorbar;
    axis on;
end
