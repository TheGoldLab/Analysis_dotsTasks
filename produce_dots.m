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
dotsParams.speed = 2;
dotsParams.yCenter = 0;
dotsParams.xCenter = 0;
dotsParams.density = 50;
dotsParams.direction = 180;
dotsParams.coherence = 100;
dotsParams.dotsDuration = 2;
dotsParams.randSeedBase = 1;

%% Draw the dots
info_frames=draw_dots(dotsParams);

%% Construct stimulus matrix to feed the ME calculator