classdef client < handle
    %CLIENT Generates content requests (i.e. Interest signals) 
    %   Generates content requests, i.e. Interest signals, according to a
    %   Poisson process, with rate value lambda, set for each content type. 
    %   As our simulations follow 
    %   a step-by-step (discrete) model, the value of lambda represents 
    %   the number of 
    
    properties
        
        % a client has a single interface
        iface@interface;
        
        % number of contents considered in the experiment
        content_n;
        
        % lambda (i.e. rate) values for each content item
        lambda = [];
        
    end
    
    methods
        
        %class constructor
        function obj = client(content_n, lambda)
           
            % initialize the client's single interface
            obj.iface = interface(content_n, 1);

            obj.content_n = content_n;

            % set the Poisson distribution rates, must be a C x 1 array
            % of doubles
            obj.lambda = lambda;
            
        end
        
        % returns a C x 1 array with the Interest signals for each content 
        % item, generated according to a Poisson distribution 
        function interests = requestContent(obj)
        
            % generate Interest signals, for now will generate multiple
            % signals per step (this might need to be revised in the
            % future)
            interests = [((obj.lambda - rand(obj.content_n, 1)) > 0); zeros(obj.content_n,1)];
            
            % activate the output Interest signals
            obj.iface.putOutPorts(interests);
            
        end
        
    end
    
end

