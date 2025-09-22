classdef chirp_det < baseProcessors.baseEstimator
    % CHIRP_DET   Detect a linear chirp signal.
    % Detect a linear chirp signal by computing the second derivative of
    % the phase of the input signal. If this value is a constant, then it
    % can be inferred that this signal is a linear frequency modulated
    % chirp. Estimated parameters
    %
    % inputs:
    %    samples - time-domain stream placed in buffer by this kernels
    %    nodeHandle wrapper
    %
    % outputs:
    %    interrupt-
    %
    % myClass Properties:
    %    val_log - Values logged internally for posterity and analysis
    %    est_var -
    %    est_val -
    %    previous_samples - Samples kept from the previous call, where the
    %    number of samples is equal to nlags
    %    exp_avg - An exponential smoother / averaging object
    %
    % myClass Methods:
    %    methods - Standard WISCASim kernel methods: init, process, reset,
    %    update_log, dump_data


    %% PROPERTIES
    properties
        val_log = []
        est_vals = []
        previous_samples = []
        fc_est = []
        cr_est = []
        exp_avg_diff1 avg.exp_avg
        exp_avg_diff2 avg.exp_avg
        exp_avg_monitor avg.exp_avg
        interrupt_type = "detection" % overriding the default "estimator" interrupt type
    end


    %% METHODS
    methods

        function self = reset(self)
            self.buf.reset();
            self.init();
            self.previous_samples = [];
            self.init();
            self.previous_samples = [];
        end



        %% SIGNAL PROCESSING METHOD
        function out = process(self)

            % Check how many new samples we got on this call
            available_samples = self.buf.new_samps;
            val = NaN;
            fc_est = NaN;
            cr_est = NaN;


            % If enough samples, execute the kernel
            if available_samples >= self.config.window_size

                z = self.buf.get(self.config.window_size);
                z = [self.previous_samples; z];

                % Size(z) changes between first call and subsequent calls,
                % so get size on every call
                [nSamp, nChan] = size(z) ;
                lag = self.config.lag;
                nlag = self.config.lag;


                %% Do Chirp Analysis:
                % Chirp rate estimation
                % Multiply the signal with a lagged version of itself to
                % take the first derivative of the phase
                diff1_product = z(1+lag:end,:).*conj(z(1:end-lag,:));

                % Do the same process again to take the second derivative
                % of the phase
                diff2_product = diff1_product(1+nlag:end,:).*conj(diff1_product(1:end-nlag,:));

                % Take an average of the second derivative phasor
                avg_productdiff2 = self.exp_avg_diff2.work(sum(diff2_product,2)); % sum across channels, then smoothed average

                % Find the average angle associated with this phasor
                ang_diff2 = (angle(avg_productdiff2));

                % That angle is our estimated chirp rate
                chirp_rate = ang_diff2/(2*pi);

                % Center frequency estimation - generate a test phasor
                % using our estimated chirp rate
                tRange = ((1:(nSamp-lag))-nSamp/2);
                phasor = exp(-1i*2*pi*lag*chirp_rate*tRange);
                phasor = (ones(nChan,1)*phasor).';

                %  Hit our estimated waveform with the actual to back out
                %  the center beat frequency
                diff1_phasor = diff1_product.*phasor;
                avg_diff1_phasor = self.exp_avg_diff1.work(sum(diff1_phasor,2)); % sum across channels, smoothed average
                ang_diff1_phasor = angle(avg_diff1_phasor);

                % estimate the center frequency using the above (this
                % assumes baseband)
                center_freq = (ang_diff1_phasor+(chirp_rate*lag^2)/2)/(2*pi*lag);
                center_freq = center_freq + self.stream_params.fc;

                %% Chirp Detect/Monitoring
                tRange_mon = ((1:(nSamp))-nSamp/2);
                est_chirp = exp(-1i*2*pi*(chirp_rate*tRange_mon.^2 + center_freq*tRange_mon));
                est_chirp = ones(nChan,1)*est_chirp; est_chirp = est_chirp.';
                chirp_detection_metric = z.*(est_chirp);
                chirp_detection_metric = (sum(abs(chirp_detection_metric),2));
                chirp_detection_metric = self.exp_avg_monitor.work(chirp_detection_metric);

                % Update data products vectors
                self.previous_samples = z(end-lag+1:end,:);
                val = chirp_detection_metric;
            end

            % Only update estimates if we triggered a detection
            if chirp_detection_metric > self.config.decision_threshold
                out.est.fc = center_freq;
                out.est.chirp_rate = chirp_rate;

                % out.est_params goes to downstream nodes (only on detection)
                out.output_params.fc_est = center_freq; 
                out.output_params.chirp_rate_est = chirp_rate; 
            end
            % out.val goes to the decision logic function
            out.val = val;

            % update log file
            self.update_log(val, center_freq, chirp_rate);
        end

        function init(self)
            % instantiate a moving averager for each average we need to
            % maintain
            self.exp_avg_diff1 = avg.exp_avg(self.config.lambda, self.config.output_mode);
            self.exp_avg_diff2 = avg.exp_avg(self.config.lambda, self.config.output_mode);
            self.exp_avg_monitor = avg.exp_avg(self.config.lambda, self.config.output_mode);
        end

        % log values for posterity
        function self = update_log(self, val, fc_est, cr_est)
            self.val_log(end+1:end+size(val,1), :) = val;
            self.fc_est(end+1:end+size(val,1), :) = fc_est;
            self.cr_est(end+1:end+size(val,1), :) = cr_est;
        end

        % dump the log
        function data = dump_data(self)
            data.val = self.val_log;
            % more logs
        end
    end
end
