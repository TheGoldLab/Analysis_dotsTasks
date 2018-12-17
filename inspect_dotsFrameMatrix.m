function squareMatrix=inspect_dotsFrameMatrix(frameInfoStruct, frameNumber, numPixelLength)
% display a frame of dots
% inspired from this post
% https://www.mathworks.com/matlabcentral/answers/298669-how-to-bin-2d-data#answer_230992
xy = frameInfoStruct{frameNumber}.dotsFrameMatrix';
squareMatrix = hist3(xy, [numPixelLength, numPixelLength]);
imshow(squareMatrix, []); % Show as image
%colormap(hot(256));
%colorbar;
axis on;