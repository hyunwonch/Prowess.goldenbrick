%% Add Kernel Libraries to Path
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------

clear; clc; close all;
local_dir = pwd;
working_dir = fileparts(local_dir);
addpath(genpath(fullfile(working_dir,'libs')));
env_cfg_path = 'env-cfg-files';

plot_title = ['Energy Detector ROC'];

%signal_types('bpsk', 'mPSK', 'ofdm') % types of signals to draw frm
nThrow = 20; % Number of throws in the Monte Carlo sim
nThresh = 200; % number of discrete threshold levels for ROC curve

save_plots=true;

%% Specify some parameters of interest -- USER INPUT
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
SNR = [-25:5:0]; % Target SNR in dBs. This can be a scalar or a vector.
Approach.type = 'energy'; % energy detector unit test
winSize = 200; % Detector window size in samples

%% Specify RF Environment -- USER INPUT
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
simSysEnvFile = '';
loadSimSysEnvFile = false;
saveSimSysEnvFile = false;

% ---------------------
%load envParams from library
%NOTE: This is what determines the signal parameters
rfcfg.envUnitTestEnergyDetect();

if loadSimSysEnvFile
    %load env file if present
    load(fullfile(working_dir,env_cfg_path,simSysEnvFile))
else
    disp('Generating RF environment ... ')
    
    % ---------------------
    % construct a new "sim" struct to capture all simulation control params
    sim.nThrow          = nThrow; % one waveform per run
    sim.oversamp        = 1; % rx oversampling factor
    sim.maxStartDelay   = 5*10^5; % delay when waveform appears in env, max
    sim.arrayModel      = "ranPhase"; % options "gaussian" or "ranPhase"
    sim.addNoise        = true; % true or false

    % ---------------------
    % construct a new "sys" struct to capture all environmental params
    sys.nAnt          = 1; % number of antennas in rx array, NOTE: only 1
    sys.bandwidthBins = 10^3 * sim.oversamp; % unitless frequency bins

    % ---------------------
    % build environment
    PBS = rfenv.envSetup(sim,sys,env);
    dt    = datetime('now');
    dtStr = datestr(dt,'yyyy-mm-dd--HH-MM');
    fName = fullfile('env-cfg-files',strcat('simSysEnv-',dtStr));

    % ---------------------
    % save the newly created rf env as a .mat, if desired
    if (~loadSimSysEnvFile) && saveSimSysEnvFile
        if ~exist('./env-cfg-files', 'dir')
            mkdir('./env-cfg-files')
        end
        save(fName, 'sim', 'sys', 'env', 'PBS');
    end
end

%% Start construction
% -----------------------------------------------------------------------
% find longest duration waveform contribution
disp('Constructing test vectors ... ')

mxLen = 0;
for throwIn = 1:sim.nThrow
    % grab a waveform
    thisPbs = PBS{throwIn} ;

    % calculate its max length for later
    mxLen = max(mxLen, ...
        length(thisPbs.sig)+ thisPbs.timeOffBin) ;
end

%TODO: Preallocate this
sigTotal = [];

for throwIn = 1:sim.nThrow
    % grab a waveform
    thisPbs = PBS{throwIn} ;

    % preallocate a vector for each waveform
    throw = zeros(sys.nAnt, mxLen);

    % construct noiseless waveforms
    throw(1:sys.nAnt,(1:length(thisPbs.sig)) + thisPbs.timeOffBin) ...
        =  throw(1:sys.nAnt, ...
        (1:length(thisPbs.sig)) + thisPbs.timeOffBin) ...
        + thisPbs.sig;

    % take each nThrow waveforms and make one big vector, for compute simplicity
    sigTotal = [sigTotal, throw];
end

%% Loop over each window for each detection threshold
%-----------------------------------------------------
% Do this for each nThrow signals for each SNR

% lets pre-allocate these fellas
Pd = zeros(length(SNR),nThresh);
Pfa = zeros(length(SNR), nThresh);

% preallocate some cells for pd, pfa vals
pd = cell(1,length(SNR));
pfa = cell(1, length(SNR));

disp(['Generating ROC curves for SNRs: ', num2str(SNR), ' ...'])
for thisSNR = 1:length(SNR)
    tic
    disp(['Calculating PFA/PD for SNR=',num2str(SNR(thisSNR)), 'dB using ', num2str(nThrow), ' signal throws...'])        % create some indexing variables for convenience

    % ---------------------
    % our final output signal is y. Recall for later that sigTotal is the signal
    % minus any noise, we use the to construct our detections/false detections
    % we construct y for this loop with a certain SNR and waveform

    % add noise to sigTotal to create y, our noisy signal
    y = awgn(sigTotal,SNR(thisSNR));

    % Detector decision vectors
    [nAnt,subSamps] = size(y);
    nWin = floor(subSamps/winSize);

    DetTruth = zeros(1,nWin);
    detDecision   = zeros(1,nWin);

    energy = zeros(1,nWin);

    for winIn = 1:nWin
        % grab winSize worth of samples from y
        z = y(:,((1:winSize)+(winIn-1)*winSize));

        % Magnitude squared energy detector per window (scaled over winSize)
        % This is done to determine our threshold levels
        energy(winIn) = sum(sum(z .* conj(z))) / nAnt / winSize;
    end

    % generate an a priori threshold based on the actual energy levels in the
    % signal
    thLow = min(energy); thHigh = max(energy);
    thRange = linspace(thLow, thHigh, nThresh);


    % loop over each of the various detection thresholds
    for thisThresh = 1:nThresh

        % set threshold based on these levels
        Approach.detail.thresh = thRange(thisThresh);

        % for each detection window
        for winIn = 1:nWin
            % Grab our window of signal that we are passing to the energy
            % detector
            z = y(:,((1:winSize)+(winIn-1)*winSize));

            % Run that window of data through our detector
            detOut = detector.detSig(z, Approach);

            % Collect the results of the binary detector
            detDecision(winIn) = detOut.decision;

            % z1 is the signal minus any added noies. If the value is
            % non-zero, then a signal exists there.
            z1 = sigTotal(1:nAnt,((1:winSize)+(winIn-1)*winSize));

            % if there exists anything in z1, then we say the detection for
            % this window is true
            if sum(abs(z1)) > 0
                % generate our truth vector for this loop
                DetTruth(winIn) = 1;
            end
        end

        % find the indices where the signal is/is not present in truth
        det_idx = find(DetTruth==1);
        nodet_idx = find(DetTruth==0);

        % % create some indexing variables for convenience
        j=1; % j will eventually = the number of samples with signal present
        k=1; % k will eventually = the number of samples without signal present

        % Loop over golden detection vector, DetTruth. It has the same number
        % of entries as nWin ... Compare to our calculated detections
        % this can almost certainly be vectorized
        for thisWin=1:nWin
            if DetTruth(thisWin)==1
                if detDecision(thisWin)==1
                    % good detection
                    pd{thisSNR}(j) = 1;
                elseif detDecision(thisWin)==0
                    % missed detection
                    pd{thisSNR}(j) = 0;
                end
                j = j+1;
            elseif DetTruth(thisWin)==0
                % being verbose here for clarity
                if detDecision(thisWin)==1
                    % false alarm occurred
                    pfa{thisSNR}(k) = 1;
                elseif detDecision(thisWin)==0
                    % correct decision
                    pfa{thisSNR}(k) = 0;
                end
                k = k+1;
            end
        end
        % do probability of detection calculation for this SNR/thresh pair
        Pd(thisSNR, thisThresh) = sum(pd{thisSNR}==1)/length(pd{thisSNR});

        % do probablity of false alarm calculation for this SNR/thresh pair
        Pfa(thisSNR, thisThresh) = sum(pfa{thisSNR}==1)/length(pfa{thisSNR});
    end
    toc
end

% create our figure of merit
labels = cell(1,length(SNR));
for n = 1:length(SNR)
    % trace labels (backwards)
    labels{length(SNR)-n+1} = strcat("SNR=",num2str(SNR(n)),'dB');
end

figure(3);
plot(flipud(Pfa).',flipud (Pd).');
xlabel('Probability of False Alarm')
ylabel('Probability of Detection')
title(plot_title)
legend(labels, 'Location','southeast')
tools.boldify()
grid on

if save_plots
    if ~exist('./plots', 'dir')
        mkdir('./plots')
    end
    fh = gca;
    saveas(fh,['./plots/',plot_title, ' ', strrep(datestr(datetime),':','-'),'.png'])
end
