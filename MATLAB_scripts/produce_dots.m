%% AIM: write a script that displays the dots stimulus and saves useful info about the stimulus

clear all


data_folder = '/Users/adrian/Documents/MATLAB/projects/dotsStimExperiments/data/';
fileName = 'detail_18';
fffs = {'tomerge_1','tomerge_2'};

%fileToLoad = [fileName,'.mat'];

% column names in final csv file
colNames={...
    'stencilNumber', ...
    'pixelSize', ...
    'diameter', ...
    'speed', ...
    'yCenter', ...
    'xCenter', ...
    'density', ...
    'direction', ...
    'coherence', ...
    'dotsDuration', ...
    'randSeedBase', ...
    'coherenceSTD', ...
    'frameIdx', ...
    'onsetTime', ...
    'onsetFrame', ...
    'swapTime', ...
    'isTight', ...
    'iter', ...
    'dotIdx', ...
    'xpos', ...
    'ypos', ...
    'isCoherent'};

numCols=length(colNames);
numIter = 1;


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
dotsParams.speed = 2;
dotsParams.yCenter = 0;
dotsParams.xCenter = 0;
dotsParams.density = 80;
dotsParams.direction = 0;
dotsParams.coherence = 50;
dotsParams.dotsDuration = .5; % in sec
dotsParams.randSeedBase = 1;
dotsParams.coherenceSTD = 0; % I don't know what that is

% vector to write to csv files
paramVec = [...
    dotsParams.stencilNumber, ...
    dotsParams.pixelSize, ...
    dotsParams.diameter, ...
    dotsParams.speed, ...
    dotsParams.yCenter, ...
    dotsParams.xCenter, ...
    dotsParams.density, ...
    dotsParams.direction, ...
    dotsParams.coherence, ...
    dotsParams.dotsDuration * 1000, ... % in msec
    dotsParams.randSeedBase, ...
    dotsParams.coherenceSTD];

displayIndex = 1;


%% Draw the dots
for jjj = 1:numIter
    info_frames=draw_dots(dotsParams, displayIndex);
        
%% Dump all stimulus data that will be used by our data analysis in R
   
    %load(fileToLoad)
    
    % count number of frames actually drawn
    numFrames=count_frames(info_frames);
    
    % build matrix that will be dumped as a csv file
    
    bigNumber = 10000 * numFrames; % overestimate of the number of dots
    dataMatrix = zeros(bigNumber,numCols);
       
    matrixRow = 1;
    
    for frameIdx = 1:numFrames
        currFrame = info_frames{frameIdx};
        
        % 2-by-numDots matrix for current frame
        dotsMatrix = currFrame.dotsFrameMatrix;
        
        % number of rows to dump into csv file for this frame
        numRowsForThisFrame = size(dotsMatrix,2);
        
        % 1-by-numDots boolean vector containing a 1 if dot is coherent on
        % this frame
        cohDots = currFrame.cohDotsBool;
        
        % prepare all but last 3 cols of the 'standard row' to fill
        standardRow = [paramVec, frameIdx, currFrame.onsetTime, currFrame.onsetFrame,...
            currFrame.swapTime, currFrame.isTight, jjj];
        
        for dotIdx = 1:numRowsForThisFrame
            varyingRow = [dotIdx, dotsMatrix(:,dotIdx)', cohDots(dotIdx)];
            dataMatrix(matrixRow,:) = [standardRow, varyingRow];
            matrixRow = matrixRow + 1;
        end
    end
    
    dataMatrix = dataMatrix(1:matrixRow-1, :);
    
    T=array2table(dataMatrix, 'VariableNames', colNames);
    save([data_folder,fileName,'.mat']) % to save workspace
    fileToWrite = [data_folder, fileName, fffs{jjj}, '.csv'];
    writetable(T,fileToWrite,'WriteRowNames',true)  % files will need to be merged later
end




%% Redraw the dots, out of the 3D matrix gathered by snow-dots
% inspired from this post
% https://www.mathworks.com/matlabcentral/answers/326813-3d-matrix-to-video#answer_256221
% NOTE: this module will create/write the file v below
% figure();
% v = VideoWriter('dots_reconstructed_5.avi');
% open(v);
% imagesc(xytMatrix(:,:,1))
% axis tight manual 
% set(gca,'nextplot','replacechildren');
% for k = 2:numFrames 
%    imagesc(xytMatrix(:,:,k))
%    frame = getframe;
%    writeVideo(v,frame);
% end
% close(v);