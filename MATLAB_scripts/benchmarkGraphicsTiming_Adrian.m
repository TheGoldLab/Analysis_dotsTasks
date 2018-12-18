% script initially copied (and modified) from 
% https://github.com/TheGoldLab/Lab-Matlab-Control/blob/b099d3cfd7c5ad424fba9a1738113f2fd3121cc1/snow-dots/utilities/benchmarking/benchmarkGraphicsTiming.m
%
% Shows a bunch of RDK of increasing complexity & tests for skipped frames

SCREEN_INDEX = 0;  % 0=small rectangle on main screen; 1=main screen; 2=secondary

try
    % open the screen
    dotsTheScreen.reset('displayIndex', SCREEN_INDEX);
    dotsTheScreen.openWindow();
    
    theScreen = dotsTheScreen.theObject();
    frameInt = 1./theScreen.windowFrameRate.*1000; % in ms

    
    %% RDK
    %
    % make dots & store timing data
    DDS        = 1000:2000:20000;
    numDDs     = length(DDS);
    NUM_FRAMES = 50;
    timeData  = nans(NUM_FRAMES, numDDs);
    dots       = dotsDrawableDotKinetogram();
    dots.diameter  = 15;
    dots.pixelSize = 3;
    for nn = 1:numDDs
        % draw 'em
        dots.density   = DDS(nn);
        dots.isVisible = true;
        startTime = mglGetSecs();
        dots.prepareToDrawInWindow();  % this is an empty function
        for ii = 1:NUM_FRAMES
            dotsDrawable.drawFrame({dots}, true);
            timeData(ii,nn) = (mglGetSecs - startTime).*1000;
        end
        theScreen.blank();
    end
    
    % close the drawing window
    dotsTheScreen.closeWindow();
    
catch
    % close the drawing window
    dotsTheScreen.closeWindow();
end

% plot some stats
figure

cla reset; hold on;
plot(DDS([1 end]), [0 0], 'k:');
plot(DDS, sum(diff(timeData)>frameInt+2), 'ko', 'MarkerSize', 8)
axis([DDS(1) DDS(end) -1 NUM_FRAMES+1])
xlabel('Number of dots')
ylabel('Number of skipped frames');


