classdef mpskParams_est < baseProcessors.baseTrigger
    %% PROPERTIES
    % need changes here
    properties
        default_parameters = struct("window_size", 256, "buf_size", 2^10)
        val_log = []
    end
    %% METHODS
    methods
        %% SIGNAL PROCESSING METHOD - redefine in inheritor
        function out = process(self)
            % Check how many samples are in the buffer
            available_samples = self.buf.ptr_delta;
            % Setup output in the case that we dont have enough samples to
            % execute
            out.val = NaN;
            if available_samples >= self.config.window_size
                % do the processing
                % process all samples that fit within the window.
                % if enough samples, grab them
                signal = self.buf.get(self.config.window_size);
                val = max(max(signal.*signal'));
                % do processing
                %need to add here
                out.val = val;
            end
            % return most recent calculated value
            self.update_log(out.val);
        end
        % Append value to vector
        function self = update_log(self, val)
            self.val_log(end+1) = val;
        end
         function data = dump_data(self)
            data.val = self.val_log;
        end
    end
end