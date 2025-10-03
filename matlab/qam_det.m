classdef qam_det < baseProcessors.baseTrigger

    %% PROPERTIES
    properties
        default_parameters = struct("window_size", 256, "buf_size", 2^12)
        default_decision = "binary_switch"
        window = []
        val_log = []
    end

    %% METHODS
    methods

        function self = reset(self)
            self.buf.reset();
        end

        %% SIGNAL PROCESSING METHOD
        function out = process(self)

            % if there aren't enough samples to process, output NaN
            val = NaN;

            % Check how many new samples we got on this call
            samples_required = self.config.window_size;
            available_samples = self.buf.new_samps;

            if available_samples >= samples_required
               signal = self.buf.get(samples_required);
               val = max(fft(signal(:)).*conj(fft(signal(:))));
            end

            % output values
            out.val = val;
            self.update_log(val);
        end

        % log values for posterity
        function self = update_log(self, val)
            self.val_log(:, end+1) = val;
        end

        % dump the log
        function data = dump_data(self)
            data = self.val_log;
        end
    end
end




