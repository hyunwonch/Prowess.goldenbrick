classdef aep < baseProcessors.baseTrigger
    % AEP   Adaptive Event Processing
    % Description of the algorithm
    %
    % myClass Properties:
    %    props - Inherited from the baseTrigger parent class
    %
    % myClass Methods:
    %    process - call the computational kernel processing method
    %    update_log - stores computed values in a vector property for later
    %    analysis
    %    dump_data - pass out data/logs of interest to user

    % NOTES:
    % 1. We need to document our algorithms better. Please document the
    % code inline so there is context for what is supposed to happening.
    % Also, add references (papers, texts, websites) in the description of
    % the class.
    % 2. The loggers need to be re-written for every kernel. Please log
    % whatever data is important for the specific kernel. Copy/pasting what
    % I wrote previously is not sufficient.
    % 3. We need to think about how to add statefullness to the processors.
    % It could simply be adding a moving averager to everything, but it
    % might differ per processor. Keep this in mind - ONE SIZE DOES NOT FIT
    % ALL.

    %% PROPERTIES
    properties
        default_parameters = struct("window_size", 256, 'nCovSamp', 64, "buf_size", 2^12, "n_avg", 1)
        eigval_log = []
        ma % moving averager object
        oldCov % store the last sample covariance matrix computation between calls
        reset_flag = false % was this kernel just reset?
        %eigvec_log = []
    end

    %% METHODS
    methods

        %% SIGNAL PROCESSING METHOD - redefine in inheritor
        function out = process(self)

            % if a processor does not have enough samples to execute,
            % output a NaN. This informs the nodeHandle of what
            % happened, and it does bookkeeping accordingly.

            nCovS = self.config.nCovSamp; % number of samples to gen covariance matrix
            nCov = floor(self.config.window_size/nCovS); % number of cov matrices we will compute
            out.val = NaN(nCov-1, 1); % number of output eigenvalues we will make

            % Check how many samples are in the buffer
            available_samples = self.buf.new_samps;

            % If there are enough samples, process them
            if available_samples >= self.config.window_size
                signal = self.buf.get(self.config.window_size);

                % Signals are column vectors, but this processor wants them
                % as rows, so transpose.
                signal = signal.';

                % do processing
                z = signal(:,1:nCovS);

                % if this kernel was just reset, recompute this value,
                % otherwise, continue to use it for the duration of this
                % activation epoch

                % Question: when else do we want to update this cov matrix?
                % We need to do some sort of update rate or something
                if self.reset_flag
                    self.oldCov = z * z';
                    self.reset_flag = false;
                end

                % allocate some vectors
                thisEigVec = zeros(self.stream_params.nAnt,1);
                eigVals = zeros(nCov-1, 1);

                % do eigenvalue analysis of sample covariance matrix
                for covIn = 1:(nCov-1)
                    z = signal(:,((1:nCovS)+covIn*nCovS));
                    cov = z*z';
                    [eVec, eVal, ~] = eigs(inv(self.oldCov)*cov,1); % The ~ here suppresses warnings of nonconvergence (well, it was supposed to)
                    maxEig = real(eVal);

                    eigVals(covIn) = maxEig;
                    thisEigVec(:,covIn) = eVec;
                end

                % Apply a moving average filter - unclear if this is the
                % right thing to do
                avgdEigVals = self.ma.call(eigVals.').';

                % Assign the desired output to our out.val output interface
                % struct
                out.val = avgdEigVals;
            end

            % log our output values for posterity
            self.update_log(out.val);
        end

        function self = reset(self)
            % The base class calls reset when the node is instantiated, so
            % this can also be used to call init functions
            self.buf.reset(); % the base class contains this method, but it only contains this line. Create a reset method here if more functionality is needed.
            self.init()
            self.reset_flag = true;
        end

        function init(self)
            % instantiate a moving averager
            if ~isfield(self.config, "n_avg")
                self.config.n_avg = self.default_parameters.n_avg;
            end

            if ~isfield(self.config, "window_size")
                self.config.window_size = self.default_parameters.window_size;
            end

            if ~isfield(self.config, "nCovSamp")
                self.config.nCovSamp = self.default_parameters.nCovSamp;
            end

            % Note this is specific for what we are trying to do for AEP
            n_channel = floor(self.config.window_size/self.config.nCovSamp) - 1;
            self.ma = avg.running_average(self.config.n_avg, n_channel);
        end

        % log values for posterity
        function self = update_log(self, eigval)
            self.eigval_log(end+1, :) = eigval;
            % potentially log eigenvectors here as well, but probably not
            % needed
        end

        % dump the log data
        function data = dump_data(self)
            data.val = self.eigval_log; % this is the primary value, easy to plot with plot_node function (in development)
            %data.eig_vecs = self.eigvec_log; % this is secondary stuff that you will have to access manually or write new tools to access
        end

    end
end

