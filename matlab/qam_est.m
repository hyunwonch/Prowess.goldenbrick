classdef qamParams_est < baseProcessors.baseTrigger

    %% PROPERTIES
    % need changes here
    properties
        default_parameters = struct("window_size", 256, "buf_size", 2^10)
        default_decision = "toggle"
    end

    %% METHODS
    methods

        %% SIGNAL PROCESSING METHOD - redefine in inheritor
        function out = process(self)

            % Initialize this on first call after reset
            if isempty(self.state)
                self.state.val_buf = [];
            end

            % Check how many samples are in the buffer
            available_samples = self.buf.ptr_delta;
            nIter = floor(available_samples/self.config.window_size);

            if nIter > 0
                % process all samples that fit within the window.
                % if enough samples, grab them
                signal = self.buf.get(self.config.window_size);

                % do processing
                %need to add here
            else
                % not enough samples to process, return NaN (?) and do not
                % update the pointer location
                self.update_state_vector(NaN);
            end

            % return most recent calculated value
            out.val = self.state.val_buf(end);
        end

        % Append value to vector
        function self = update_state_vector(self, val)
            self.state.val_buf(end+1) = val;
        end
    end
end

