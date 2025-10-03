classdef energy_det < baseProcessors.baseTrigger
    % energy_det   Magnitude squared energy detector with exponential
    % smoothing
    % This class inherits the WISCASim baseProcessor parent class and
    % implements a magnitude-squared energy detector with a parameterizable 
    % exponential smoother at the output
    %
    % myClass Properties:
    %    val_log - Standard value log property used to capture information
    %    of interest for debug and analysis.
    %    exp_avg - exponential smoothing object used to filter the output
    %
    % myClass Methods:
    %    methods - Standard WISCASim kernel methods: init, process, reset,
    %    update_log, dump_data


    %% PROPERTIES
    properties
        val_log = []
    end

    properties (Access = private)
        exp_avg avg.exp_avg
        initialized = false
    end

    %% METHODS
    methods
        function self = reset(self)
            % The base class calls reset when the node is instantiated, so
            % this can also be used to call init functions
            self.buf.reset();
            self.init()
        end

        %% SIGNAL PROCESSING METHOD
        function out = process(self)

            % Check how many new samples we got on this call
            available_samples = self.buf.ptr_delta;
            val = NaN;

            % Iterate over each available sample, start outputting real values
            % once we have enough samples to fill a processing window.
            % Until then, output NaNs for timekeeping.
            if available_samples >= self.config.window_size
                signal = self.buf.get(self.config.window_size);

                % combine squared magnitudes across antennas
                tmp_val = sum(abs(signal).^2, 2); % this should be a vector

                % perform averaging
                val = self.exp_avg.work(tmp_val);
            end

            out.val = val;
            self.update_log(val);
        end

        function init(self)
            % instantiate a exponential smoothing object
            self.exp_avg = avg.exp_avg(self.config.lambda, self.config.output_mode);
        end

        % log values for posterity
        function self = update_log(self, val)
            self.val_log(end+1:end+size(val,1), :) = val;
        end

        % dump the log
        function data = dump_data(self)
            data.val = self.val_log;
        end
    end
end

