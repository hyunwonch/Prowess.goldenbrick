clc;
clear all

%% Detectors
Nant = 8;
Nsamp = 100;
nchan = 64;
Ndelay = 16;
Ops = [Nant; 2*Nant; 2; 2*Nant; Nant^2; Nant^3; 2*Nant; Nant*log(nchan); Nant*Ndelay; Nant^2];
Coeff = [4; 4; 16; 10; 16; 16; 8; 8; 16; 10];
for i = 1:length(Coeff)
    DetCostMain(i) = Ops(i)*Coeff(i);
end
NumDet = length(DetCostMain);
Total_Ops_Available = sum(DetCostMain);
Det_SampMain = [20; 50; 50; 200; 200; 200; 200; 100; 200; 100]; % number of samples per processing frame
MxDetSamp = max(Det_SampMain);
% Sig_TreeMain = [1; 1; 1; 1; 0; 0; 0; 0; 0; 0];
% Sig_Tree = [1; 1; 1; 1; 0; 0; 0; 0; 0; 0];
Sig_Tree{1}  = [1; 1; 0; 0; 1; 1; 0; 0; 0; 0];
Sig_Tree{2}  = [1; 1; 0; 0; 1; 0; 1; 0; 0; 0];
Sig_Tree{3}  = [1; 1; 0; 0; 0; 1; 0; 0; 0; 0];
Sig_Tree{4}  = [1; 0; 1; 0; 0; 0; 0; 1; 0; 0];
Sig_Tree{5}  = [1; 0; 0; 1; 1; 0; 0; 0; 0; 0];
Sig_Tree{6}  = [0; 1; 0; 0; 1; 1; 0; 0; 0; 0];
Sig_Tree{7}  = [0; 1; 0; 0; 1; 0; 1; 0; 0; 0];
Sig_Tree{8}  = [1; 1; 0; 0; 0; 0; 0; 0; 1; 0];
Sig_Tree{9}  = [1; 0; 0; 0; 1; 0; 0; 0; 0; 1];
Sig_Tree{10} = [1; 1; 0; 0; 1; 0; 1; 0; 0; 0];


%% Scenario

Total_time = 1300*10^-6; % total time in spectral scenario
SigDetMinSamp = [1000; 200; 600; 1000; 500; 200; 1000; 400; 200; 1000]; % samples required to detect signal
Signal_start = [20; 40; 220; 350; 460; 500; 600; 780; 920; 1200]*10^-6; % signal start time
Signal_end = [120; 140; 300; 400; 550; 600; 700; 850; 1100; 1300]*10^-6; % signal finish time
BW = [10; 5; 2; 10; 8; 4; 5; 2; 2; 1]*10^6; % signal bandwidth
fs = 2*BW;
NumSig = length(SigDetMinSamp);
SigType = zeros(NumSig,1);
SigN_samples = zeros(NumSig,1);
SigN_dur = zeros(NumSig,1);
% delta = (0:5:30) * 10^-6;
delta = 0;

for tt = 10
    DetCost = DetCostMain(1:tt);
    Det_Samp = Det_SampMain(1:tt);
    Total_Ops_Available = sum(DetCost);
    % Sig_Tree = Sig_TreeMain(1:tt);
    NumDet = length(DetCost);


    for dd = 1:length(delta)
        SigN_dur = zeros(NumSig,1);
        Ts = []; SigType = zeros(NumSig,1);
        for nn = 1:NumSig %Sweep Duty Cycle
            SigType(nn) = 1;
            for  i =1:length(SigType)
                if SigType(i)>0
                    Ts(i) = 1/fs(i);
                    SigN_dur(i) = (Signal_end(i) - Signal_start(i));
                    SigN_dur(i) = SigN_dur(i) + delta(dd);
                    % SigN_samples(i) =  (Signal_end(i) - Signal_start(i))/Ts(i);
                end
            end
            % Total_samp = Total_time / max(Ts);
            Duty_cyc(tt,nn) = sum(SigN_dur)/Total_time;

            %% Detector Tree
            % if yes for 1 --> 1-2-5-6 ------ 1-2-5-7 ------ 1-2-6 ------ 1-3-8 ------ 1-4-5 ------
            % if no for 1 --> change tree to 2-5-6 ------ 2-5-7

            Utilize_ratio = zeros(NumDet,1);
            Cost_sample = zeros(NumDet,1);
            for i=1:NumSig
                if SigType(i)>0
                    SigTree = Sig_Tree{i};
                    for j = 1:NumDet
                        if SigTree(j)==1
                            Sampcost = max([SigDetMinSamp(i) Det_Samp(j)]);
                            Utilize_ratio(j) = Utilize_ratio(j) + Sampcost*Ts(i)/Total_time;
                        end
                        Cost_sample(j) = Utilize_ratio(j)* DetCost(j);
                    end
                end
            end

            TotalCost = sum(Cost_sample);
            Th_Gain(tt,nn) = Total_Ops_Available/ TotalCost;

        end


        figure(1);
        plotParams2
        plot(Duty_cyc(tt,:),Th_Gain(tt,:)); hold on;
        xlabel('duty cycle')
        ylabel('throughput gain')
        [MaxSig_Dur ind]= max(SigN_dur);

    end
end







