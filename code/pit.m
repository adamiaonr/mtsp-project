classdef pit < handle
    %PIT Abstraction for an NDN Pending Interest Table (PIT)
    %   Detailed explanation goes here
    
    properties
        
        % the PIT is simply a C x I matrix which relates some content
        % entry c (in this case represented by the row, numbered from 1 to 
        % C) with a set of outgoint interfaces for Interest packets (i.e. 
        % the columns 1 to I, where I is equal to the number of interfaces
        % of the NDN router)
        PIT = []
        
    end
    
    methods
        
        % class constructor
        function obj = pit(content_n,iface_n)
            
            if (nargin == 2)
            
                % initialize interface's buffer to zeros
                obj.PIT = zeros(content_n,iface_n);
            end
        end
        
        % add an entry to the PIT
        function obj = add2PIT(obj,entry,iface)
            
            % this pair of operations may not be entirely correct, so
            % discard it for now and stick to a basic PIT operation
            %i = (obj.PIT(:,iface) < 0);
            %obj.PIT(i,iface) = obj.PIT(i,iface) + entry(i);
        
            % check which values from entry correspond to Interest packets
            % (encoded as '-1')
            i = (entry < 0);
            
            % simply add the entry Interest values to the corresponding
            % column on the PIT
            obj.PIT(i,iface) = obj.PIT(i,iface) + entry(i);
            
            % make sure it is encoded as -1 and 0
            i = (obj.PIT(:,iface) ~= 0);
            obj.PIT(i,iface) = obj.PIT(i,iface) .* (1 ./ abs(obj.PIT(i,iface)));
            
        end
        
        % clear PIT contents by interface
        function [] = clearPITiface(obj,iface)
        
            obj.PIT(:,iface) = obj.PIT(:,iface) .* 0;
            
        end
        
        % clear PIT contents by content
        function [] = clearPITcontent(obj,content)
        
            obj.PIT(content,:) = obj.PIT(content,:) .* 0;
            
        end
        
        % clear all PIT contents
        function [] = clearPIT(obj)
        
            obj.PIT = obj.PIT .* 0;
            
        end
        
        % simply show the PIT contents
        function [] = showPIT(obj)
        
            obj.PIT
            
        end

    end
    
end

