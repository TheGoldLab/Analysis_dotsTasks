% Implementation of the Adelson & Bergen (1985) motion energy model.
% Example Matlab code by George Mather, University of Sussex, UK, 2010.
% 
% An expanded version of the code is used by George Mather and Kirsten 
% Challinor as part of a Wellcome Trust funded research project. Initial
% code was partially based on a tutorial forming part of a short course at
% Cold Spring Harbor Laboratories, USA.
% 
% This script is part of an online guide to implementing the Adelson-Bergen
% motion energy model:
%
% http://www.lifesci.sussex.ac.uk/home/George_Mather/EnergyModel.htm
%
% It is free for non-commercial educational use, with appropriate 
% acknowledgement.
%
% The script requires a variable called 'stim' to be loaded in 
% Step 3b. You can use 'AB15.mat' & 'AB16.mat' or input your own stimulus.
%
%--------------------------------------------------------------------------
%           STEP 1: Create component spatiotemporal filters 
%--------------------------------------------------------------------------
function motion_energy=MotionEnergy_1(stim, nx, nt, max_x, max_t, plotOutput)
% ARGS:
%   stim           t-by-x matrix, with 2*nt+1 rows and 2*nx+1 columns
%   nx             Number of spatial samples in the filter 
%   nt             Number of temporal samples in the filter
%   max_x          Half-width of spatial filter (deg)
%   max_t          Duration of impulse response (sec)
%   plotOutput     if true, plots will be plotted
% NOTE: post describing this script is here:
% http://www.georgemather.com/Model.html

% Step 1a: Define the space axis of the filters

         
dx = (max_x*2)/nx;  %Spatial sampling interval of filter (deg)

% A row vector holding spatial sampling intervals
x_filt=linspace(-max_x,max_x,nx);

%%%%% SPATIAL FILTER PARAMETERS %%%%%%%%%
% Spatial filter parameters
sx=0.1;   %standard deviation of Gaussian, in deg.
sf=10;  %spatial frequency of carrier, in cpd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Spatial filter response
gauss=exp(-x_filt.^2/sx.^2);          %Gaussian envelope
even_x=cos(2*pi*sf*x_filt).*gauss;   %Even Gabor
odd_x=sin(2*pi*sf*x_filt).*gauss;    %Odd Gabor

% Step 1b: Define the time axis of the filters

dt = max_t/nt;  % Temporal sampling interval (sec)

% A column vector holding temporal sampling intervals
t_filt=linspace(0,max_t,nt)';

%%%%% SPATIAL FILTER PARAMETERS %%%%%%%%%
% Temporal filter parameters
k = 100;    % Scales the response into time units
slow_n = 4; % Width of the slow temporal filter
fast_n = 3; % Width of the fast temporal filter
beta =0.5;  % Beta. Represents the weighting of the negative
            % phase of the temporal relative to the positive 
            % phase.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Temporal filter response (formula as in Adelson & Bergen, 1985, Eq. 1)
slow_t=(k*t_filt).^slow_n .* exp(-k*t_filt).*(1/factorial(slow_n)-beta.*((k*t_filt).^2)/factorial(slow_n+2));
fast_t=(k*t_filt).^fast_n .* exp(-k*t_filt).*(1/factorial(fast_n)-beta.*((k*t_filt).^2)/factorial(fast_n+2));

% Step 1c: combine space and time to create spatiotemporal filters
e_slow= slow_t * even_x;    %SE/TS
e_fast= fast_t * even_x ;   %SE/TF
o_slow = slow_t * odd_x ;   %SO/TS
o_fast = fast_t * odd_x ;   % SO/TF

%--------------------------------------------------------------------------
%         STEP 2: Create spatiotemporally oriented filters
%--------------------------------------------------------------------------
left_1=o_fast+e_slow;      % L1
left_2=-o_slow+e_fast;     % L2
right_1=-o_fast+e_slow;    % R1
right_2=o_slow+e_fast;     % R2
%--------------------------------------------------------------------------
%         STEP 3: Convolve the filters with a stimulus
%--------------------------------------------------------------------------

% Step 3a: Define the space and time dimensions of the stimulus

% SPACE: x_stim is a row vector to hold sampled x-positions of the space.
stim_width=4;  %half width in degrees, gives 8 degrees total
x_stim=-stim_width:dx:round(stim_width-dx);

% TIME: t_stim is a col vector to hold sampled time intervals of the space
stim_dur=1.5;    %total duration of the stimulus in seconds
t_stim=(0:dt:round(stim_dur-dt))';

% Step 3b Load a stimulus
%load 'AB15.mat';% Oscillating edge stimulus. Loaded as variable ‘stim’
    % OR 
%load 'AB16.mat';% RDK stimulus. Loaded as variable ‘stim’

% Step 3c: convolve

% Rightward responses
resp_right_1=conv2(stim,right_1,'valid');
resp_right_2=conv2(stim,right_2,'valid');

% Leftward responses
resp_left_1=conv2(stim,left_1,'valid');
resp_left_2=conv2(stim,left_2,'valid');
%--------------------------------------------------------------------------
%         STEP 4: Square the filter output
%--------------------------------------------------------------------------
resp_left_1 = resp_left_1.^2;
resp_left_2 = resp_left_2.^2;
resp_right_1 = resp_right_1.^2;
resp_right_2 = resp_right_2.^2;
%--------------------------------------------------------------------------
%         STEP 5: Normalise the filter output
%--------------------------------------------------------------------------
% Calc left and right energy
energy_right= resp_right_1 + resp_right_2;
energy_left= resp_left_1 + resp_left_2;

% Calc total energy
total_energy = sum(sum(energy_right))+sum(sum(energy_left));

% Normalise each directional o/p by total output
RR1 = sum(sum(resp_right_1))/total_energy;
RR2 = sum(sum(resp_right_2))/total_energy;
LR1 = sum(sum(resp_left_1))/total_energy;
LR2 = sum(sum(resp_left_2))/total_energy;
%--------------------------------------------------------------------------
%         STEP 6: Sum the paired filters in each direction
%--------------------------------------------------------------------------
right_Total = RR1+RR2;
left_Total = LR1+LR2;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%         STEP 7: Calculate net energy as the R-L difference
%--------------------------------------------------------------------------
motion_energy = right_Total - left_Total;
if isnan(motion_energy)
    motion_energy = 0;
end

%--------------------------------------------------------------------------
%         SUPPLEMENTARY CODE: Display summary output and graphics
%--------------------------------------------------------------------------
% Display motion energy statistic
%fprintf('\n\nNet motion energy = %g\n\n',motion_energy);

if plotOutput
    % Plot the stimulus
    figure (1)
    imagesc(stim); 
    colormap(gray);
    axis off
    caxis([0 1.0]);
    axis equal
    title('Stimulus');
end

% Plot the output:
%   Generate motion contrast matrix
energy_opponent = energy_right - energy_left; % L-R difference matrix
[xv yv] = size(energy_left); % Get the size of the response matrix
energy_flicker = total_energy/(xv * yv); % A value for average total energy

% Re-scale (normalize) each pixel in the L-R matrix using average energy.
motion_contrast = energy_opponent/energy_flicker;

% Plot, scaling by max L or R value
mc_max = max(max(motion_contrast));
mc_min = min(min(motion_contrast));
if (abs(mc_max) > abs(mc_min))
    peak = abs(mc_max);
else
    peak = abs(mc_min);
end

if plotOutput
    figure (2)
    imagesc(motion_contrast); 
    colormap(gray);
    axis off
    caxis([-peak peak]);
    axis equal
    title('Normalised Motion Energy');
end
end
%--------------------------------------------------------------------------



