classdef client < node
    %CLIENT Generates content requests (i.e. Interest signals) 
    %   Generates content requests, i.e. Interest signals, according to a
    %   Poisson process, with rate value lambda, set for each content type. 
    %   As our simulations follow 
    %   a step-by-step (discrete) model, the value of lambda represents 
    %   the number of 
    
    properties
                
        % lambda (i.e. rate) values for each content item
        lambda = [];
        
        % some data structures for data gathering
        stats_requests = [];
        
    end
    
    methods
        
        %class constructor
        function obj = client(id, content_n, ifaces_n, lambda)
            
            % set the element id
            obj.id = id;

            % number of content objects for the simulation
            obj.content_n = content_n;
            
            % initialize the client's single interface
            obj.ifaces = interface(content_n, ifaces_n);
            obj.ifaces_n = ifaces_n;
            
            % set the Poisson distribution rates, must be a C x 1 array
            % of doubles
            obj.lambda = lambda;
            
            % statistics
            obj.stats_requests = zeros(content_n, 1);
            
        end
        
        % returns a C x 1 array with the Interest signals for each content 
        % item, generated according to a Poisson distribution 
        function interests = requestContent(obj)
        
            % generate Interest signals, for now will generate multiple
            % signals per step (this might need to be revised in the
            % future)
            interests = [((obj.lambda - rand(obj.content_n, obj.ifaces_n)) > 0); zeros(obj.content_n, obj.ifaces_n)];
            
            % activate the output Interest signals
            obj.ifaces.putOutPorts(interests);
            
            % statistics
            obj.stats_requests = obj.stats_requests + sum(interests(1:obj.content_n, :), 2);
            
        end
        
    end
    
end

