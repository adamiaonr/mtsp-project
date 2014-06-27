classdef (Abstract) node < handle & matlab.mixin.Heterogeneous
    %NODE General abstraction of an NDN network node.
    %   Detailed explanation goes here
    
    properties
        
        % an NDN node has a set of iface_n network interfaces
        ifaces@interface;
        ifaces_n = 0;

        % simulation parameters
        
        % number of contents considered for the simulation
        content_n = 0;
        
        % node ID
        id;
        
    end
    
    methods
        
        function [] = putOutPorts(obj, outputs)
        
            obj.ifaces.putOutPorts(outputs);
            
        end
        
        function [] = putOutPort(obj, outputs, iface)
        
            obj.ifaces.putOutPort(outputs, iface);
            
        end

        function contents = getOutPorts(obj)
        
            contents = obj.ifaces.getOutPorts;
            
        end
        
        function contents = getOutPort(obj, iface)
        
            contents = obj.ifaces.getOutPort(iface);
            
        end

        function [] = putInPorts(obj, inputs)
        
            obj.ifaces.putInPorts(inputs);
            
        end
        
        function [] = putInPort(obj, inputs, iface)
        
            obj.ifaces.putInPort(inputs, iface);
            
        end
        
        function contents = getInPorts(obj)
        
            contents = obj.ifaces.getInPorts;
            
        end
        
        function contents = getInPort(obj, iface)
        
            contents = obj.ifaces.getInPort(iface);
            
        end

    end
    
end

