classdef server < handle
    %SERVER Source of content items
    
    properties
    
        % a client has a single interface
        iface@interface;
        
        % number of contents considered in the experiment
        content_n;
        
    end
    
    methods
        
        %class constructor
        function obj = server(content_n)
          
            if (nargin == 1)
           
                % initialize the client's single interface
                obj.iface = interface(content_n, 1);
                
                obj.content_n = content_n;
                               
            end
            
        end
        
        % default answer of the server, simply takes what it gets as
        % Interest signals on its interface's input ports, and mirrors it
        % to the output ports as Data signals.
        function data_outputs = answer(obj)

            data_outputs = obj.iface.getInPorts;
            obj.iface.putOutPorts([zeros(obj.content_n, 1); data_outputs((1:obj.content_n),:)]);
            
        end
        
    end
    
end

