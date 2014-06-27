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
        function obj = interface(n_contents, ifaces_n)
            
            if (nargin == 2)
            
                % initialize interface's buffer to zeros. note that the
                % row size must be set to 2 x C, due to both Interest and
                % Data signals, which can both be present in output and
                % input ports.
                obj.inport = zeros(2 * n_contents, ifaces_n);
                obj.outport = zeros(2 * n_contents, ifaces_n);

            end
        end
                
        % add the contents in 'input' to the input port of the interface
        function obj = putInPorts(obj, inputs)
        
            obj.inport = put(obj.inport, inputs);
            
        end
        
        % add the contents in 'output' to the output port of the interface
        function obj = putInPort(obj, input, iface)
        
            obj.inport(:, iface) = put(obj.inport(:, iface), input);
            
        end
        
        % simply return the contents of the interface's input port
        function contents = getInPorts(obj)
        
            contents = obj.inport;
            
        end
        
        % simply return the contents of the interface's input port
        function contents = getInPort(obj, iface)
        
            contents = obj.inport(:, iface);
            
        end
        
        % add the contents in 'output' to the output port of the interface
        function obj = putOutPorts(obj, outputs)
        
            obj.outport = put(obj.outport, outputs);
            
        end

        % add the contents in 'output' to the output port of the interface
        function obj = putOutPort(obj, output, iface)
        
            obj.outport(:, iface) = put(obj.outport(:, iface), output);
            
        end

        % simply return the contents of the interface's output port
        function contents = getOutPorts(obj)
        
            contents = obj.outport;
            
        end
        
        % simply return the contents of the interface's output port
        function contents = getOutPort(obj, iface)
        
            contents = obj.outport(:, iface);
            
        end
        
        % clear the interface's input port
        function obj = clearInPorts(obj)
           
            % as simple as making it all 0
            obj.inport = obj.inport & 0;
            
        end
        
        % clear the interface's input port
        function obj = clearInPort(obj, iface)
           
            % as simple as making it all 0
            obj.inport(:, iface) = obj.inport(:, iface) & 0;
            
        end
        
        % clear the interface's buffer contents
        function obj = clearOutPorts(obj)
           
            % as simple as making it all 0
            obj.outport = obj.outport & 0;
            
        end
        
        % clear the interface's buffer contents
        function obj = clearOutPort(obj, iface)
           
            % as simple as making it all 0
            obj.outport(:, iface) = obj.outport(:, iface) & 0;
            
        end
        
    end
    
end

% just some utility function (in the fashion presented in 
% http://www.mathworks.com/help/matlab/matlab_oop/specifying-methods-and-functions.html

% add the contents in 'input' to some interface's port
function port = put(port, input)

    % ALWAYS check if dimensions of input and buffer match
    try
        % instead of completely altering the contents of the
        % interface's buffer, OR the contents of 'input' to it
        port = port | input;

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
end
    