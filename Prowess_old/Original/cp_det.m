classdef cp_det < baseProcessors.baseTrigger
    % Cyclic Prefix Detector

    %% PROPERTIES
    properties
        val_log = []
        exp_avg avg.exp_avg
    end

    %% METHODS
    methods

        function self = reset(self)
            self.buf.reset();
            self.init();
        end

        function out = process(self)

            % Check how many new samples we got on this call
            available_samples = self.buf.ptr_delta;
            val = NaN;

            if available_samples >= self.config.window_size
               
                signal = self.buf.get(self.config.window_size);
                [nn, nSamp] = size(signal) ;
                cyc = [16 32 64 128];
                lag = 16;

                z = sum(signal,2);

                for i=1:length(cyc)

                    zlag = [zeros(cyc(i),1); z];
                    CAF = fftshift(ifft(fft(z,256).*conj(fft(zlag,256))));
                    CAFMain(i,:) = abs(CAF)/(nn*nSamp);
                end
                CAFMain = sum(CAFMain,1);
                [pk, ind] = max(CAFMain);
                [p, ~] = findpeaks(CAFMain(ind-15:ind+15)); % THIS NEEDS TO BE MADE MORE ROBUST
                p = sort(p,'descend');
                if isempty(p)
                    pref_pk = 0;
                else
                    pref_pk = (pk - p(1))/pk;
                end

                [corr_max, ind] = max(max_corr);
                prefix_len_approx = prefix_sizes(ind);

                % output values
                % log the output value
                out.val = val1;

                self.update_log(val1);
            end
        end

       function init(self)
            % instantiate a moving averager
            self.exp_avg = avg.exp_avg(self.config.lambda, self.config.output_mode);
        end

        % log values for posterity
        function self = update_log(self, val)
            % self.val_log(end+1:end+size(val,1), :) = val; % for vector output
            self.val_log(:, end+1) = val; % for scalar output
        end

        % dump the log
        function data = dump_data(self)
            data.val = self.val_log;
        end
    end
end

