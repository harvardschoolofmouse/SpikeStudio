% 1. Load data. This struct 
load('\\research.files.med.harvard.edu\neurobio\NEUROBIOLOGY SHARED\Assad Lab\Lingfeng\For Allison\TetrodeRecording\PETH_Press.mat')

% 2. SLOW STEP
% Select some good session to load single trial data. e.g. sessions 183 and 7 feature a activated cell and a shutoff cell
% This uses a gaussian kernel for convolution.
eu = EphysUnit(PETH([183, 7]), 'gaussian', 'sigma', 0.1, 'kernelWindow', 1, 'trialWindow', [-4, 0], 'resolution', 0.001);
% (NOT RECOMMENDED) Alternatively, use a 'exponential' kernel () for convolution. This however will introduce a delay in the convolved signal since its asymetrical.
% eu = EphysUnit(PETH([183, 7]), 'exponential', 'lambda1', 5, 'lambda2', 10, 'trialWindow', [-4, 0], 'resolution', 0.001);

% 3. Plot single trial spike rates for this unit
% stagger (percentage, between [0, 1]) controls height offsets when plotting single trials
eu.plot('stagger', 0.4, 'maxShownResults', 200);

% 4. Examine the kernel used for the convolution step
eu.plotKernel()

% 5. Adjust and redo the convolution step. This time we use a narrower gaussian kernel N(0, 0.05), and extend the convolution window to 6 seconds before movement. 
eu.spikeConv('gaussian', 'sigma', 0.05, 'trialWindow', [-6,0])

% 6. Show new results
eu.plot('stagger', 0.4, 'maxShownResults', 200);