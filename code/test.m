% sandbox script to test the whole thing...

%% pre-round (clients, server, routers, topology, etc.)

% 1) overall simulation parameters

% 1.1) different number of content objects
content_n = 30;

% 1.2) CS size (i.e. number of slots)
cs_size = 10;

% 1.3) number of simulation rounds (i.e. 'generate signals' -> 'fetch
% inputs' -> process inputs -> set outputs cycles)
round_n = 100;

% 2) topology

% 2.1) specify the topology matrix T (commented case is a cascade 
% topology, 1 client, 3 levels - i.e. NDN routers - and 1 server).
clnt_n = 1;
rtr_n = 3;
srvr_n = 1;

T = [0 1 0 0 0; 1 0 2 0 0; 0 1 0 2 0; 0 0 1 0 2; 0 0 0 1 0];

% 2.2) generate the topology elements

% 2.2.1) index for the elements
i = 1;

% 2.2.2) generate clients

% 2.2.2.1) content generation probabilities
denominators = 1:1:content_n;
epsilon = 0.25;
lambda = 1 ./ (denominators + epsilon);

% 2.2.2.2) create client(s)

for i = i:clnt_n

    nodes(i) = client(i, content_n, 1, lambda');
    
end

% 2.2.3) generate NDN routers

i = i + 1;

for i = i:(clnt_n + rtr_n)

    nodes(i) = router(i, content_n, 2, cs_size, 'LRU');
    
end

% 2.2.4) generate server(s)

i = i + 1;

for i = i:(clnt_n + rtr_n + srvr_n)

    nodes(i) = server(i, content_n, 1);
    
end

%% simulation rounds

for r = 1:round_n
    
    i = 1;
    
    % 1) client(s) generates Interests, and leave it available on the
    % output ports of their interfaces
    for i = i:clnt_n
        
        nodes(i).requestContent;
            
    end

    % 2) routers fill input ports of all their interfaces
    i = i + 1;
    
    for i = i:(clnt_n + rtr_n)
        
        % 2.1) find the connected nodes
        cnnctd_nodes = find(T(i,:));
        
        % 2.2) cycle through connected nodes and load the contents at their
        % output ports, always checking the T matrix for the correct
        % interfacesach
        for j = 1:numel(cnnctd_nodes)

            % 2.2.1) Determine the 'near' and 'far' endpoints of the link
            % between the nodes, from the perspective of the current node
            near = T(i, cnnctd_nodes(j));
            far = T(cnnctd_nodes(j), i);

            % 2.2.2) The actual load operation...
            nodes(i).putInPort(nodes(cnnctd_nodes(j)).getOutPort(far), near);

        end
        
    end
    
    % 3) servers fill input ports of all their interfaces
    i = i + 1;
    
    for i = i:(clnt_n + rtr_n + srvr_n)

        % 3.1) find the connected nodes
        cnnctd_nodes = find(T(i,:));
        
        % 3.2) cycle through connected nodes and load the contents at their
        % output ports, always checking the T matrix for the correct
        % interfacesach
        for j = 1:numel(cnnctd_nodes)

            % 3.2.1) Determine the 'near' and 'far' endpoints of the link
            % between the nodes, from the perspective of the current node
            near = T(i, cnnctd_nodes(j));
            far = T(cnnctd_nodes(j), i);

            % 3.2.2) The actual load operation...
            nodes(i).putInPort(nodes(cnnctd_nodes(j)).getOutPort(far), near);

        end
    
    end
    
    % 4) it's processing time...
    
    i = 1; 

    % 4.1) handle the clients...
    for i = i:clnt_n
        
        % 4.1.1) we can clear the output ports btw
        nodes(i).ifaces.clearOutPorts;
        
        % 4.1.2) clear inputs
        nodes(i).ifaces.clearInPorts;
        
    end    
    
    % 4.2) then the routers
    i = i + 1;
    
    for i = i:(clnt_n + rtr_n)
        
        % 4.2.1) we can clear the output ports btw
        nodes(i).ifaces.clearOutPorts;

        % 4.2.2) forward Interests, then Data
        nodes(i).forwardInterests;
        nodes(i).forwardData;
        
        % 4.2.3) clear inputs
        nodes(i).ifaces.clearInPorts;
        
    end
    
    % 4.3) finally, the servers
    i = i + 1;
    
    for i = i:(clnt_n + rtr_n + srvr_n)

        % 4.3.1) we can clear the output ports btw
        nodes(i).ifaces.clearOutPorts;

        % 4.3.2) a server answers
        nodes(i).answer;
        
        % 4.3.3) clear inputs
        nodes(i).ifaces.clearInPorts;
    
    end
    
    % 5) done, ready for another round...
    
end
