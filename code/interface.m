classdef interface < handle
    %INTERFACE Abstraction of an network interface (input or output)
    %   Detailed explanation goes here
    
    properties
        
        % router interfaces have both input and output ports
        % we still don't know to which size shall the buffer be initialized
        inport = []
        outport = []
        
    end
    
    methods
        
        % class constructor
        function obj = interface(size)
            
            if (nargin == 1)
            
                % initialize interface's buffer to zeros
                obj.inport = zeros(1,size);
                obj.outport = zeros(1,size);

            end
        end
                
        % add the contents in 'input' to the input port of the interface
        function obj = putIn(obj,input)
        
            obj.inport = put(obj.inport,input);
            
        end

        % add the contents in 'output' to the output port of the interface
        function obj = putOut(obj,output)
        
            obj.outport = put(obj.outport,output);
            
        end
        
        % simply return the contents of the interface's input port
        function contents = getInport(obj)
        
            contents = obj.inport;
            
        end

        % simply return the contents of the interface's output port
        function contents = getOutport(obj)
        
            contents = obj.outport;
            
        end

        
        % clear the interface's input port
        function obj = clearInport(obj)
           
            % as simple as making it all 0
            obj.inport = obj.inport .* 0;
            
        end
        
        % clear the interface's buffer contents
        function obj = clearOutport(obj)
           
            % as simple as making it all 0
            obj.outport = obj.outport .* 0;
            
        end
        
    end
    
end

% just some utility function (in the fashion presented in 
% http://www.mathworks.com/help/matlab/matlab_oop/specifying-methods-and-functions.html

% add the contents in 'input' to some interface's port
function port = put(port,input)

    % ALWAYS check if dimensions of input and buffer match
    try
        % instead of completely altering the contents of the
        % interface's buffer, add the contents of 'input' to it
        port = port + input;

    catch err

        % give more information for mismatch
        if (strcmp(err.identifier,'MATLAB:catenate:dimensionMismatch'))

            msg = ['Dimension mismatch occurred: First argument has ', ...
            num2str(size(A,2)), ' columns while second has ', ...
            num2str(size(B,2)), ' columns.'];
            error('MATLAB:myCode:dimensions', msg);

        % display any other errors as usual
        else
          rethrow(err);
        end

    end  % end try/catch

    % normalize the buffer (-1 0 1 encoding is used)
    %port = (port ~= 0);
    i = (port ~= 0);
    port(i) = port(i) .* (1 ./ abs(port(i)));

end
    