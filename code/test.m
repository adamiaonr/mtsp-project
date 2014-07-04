addpath('~/Workbench/mtsp-project/code/utils/')

% sandbox script to test the whole thing...

%% pre-round (clients, server, routers, topology, etc.)

% 1) overall simulation parameters

% 1.1) different number of content objects
content_n = 100;

% 1.2) CS size (i.e. number of slots)
cs_size = 25;

% 1.3) number of simulation rounds (i.e. 'generate signals' -> 'fetch
% inputs' -> process inputs -> set outputs cycles)
round_n = 1000;

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
epsilon = 0.250;
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
content_requests_time = zeros(content_n, round_n);

for r = 1:round_n
    
%     fprintf('********** ROUND %i: FIGHT **********\n', r)
    
    i = 1;
    
    % 1) client(s) generates Interests, and leave it available on the
    % output ports of their interfaces
    for i = i:clnt_n
        
        % 1.1) after round (round_n - 20), no more Interests
        if (r < (round_n - 5))
            requests = nodes(i).requestContent;
        end
        
        % 1.1.1) Content requests (total) over time
        if (r > 2)
            content_requests_time(:, r) = content_requests_time(:, r - 1) + requests(1:content_n, :);
        else
            content_requests_time(:, r) = requests(1:content_n, :);
        end
        
        % 1.1) display outputs
%         fprintf('client[%i] outputs', i)
%         nodes(i).getOutPorts

        % 1.2) find the connected nodes
        cnnctd_nodes = find(T(i,:));
        
        % 1.2) cycle through connected nodes and load the contents at their
        % output ports, always checking the T matrix for the correct
        % interfacesach
        for j = 1:numel(cnnctd_nodes)

            % 1.2.1) Determine the 'near' and 'far' endpoints of the link
            % between the nodes, from the perspective of the current node
            near = T(i, cnnctd_nodes(j));
            far = T(cnnctd_nodes(j), i);
            
%             fprintf('router[%i] fetching', i)
%             nodes(cnnctd_nodes(j)).getOutPort(far)

            % 1.2.2) The actual load operation...
            nodes(i).putInPort(nodes(cnnctd_nodes(j)).getOutPort(far), near);

        end
        
        % 1.3) display inputs
%         fprintf('router[%i] inputs', i)
%         nodes(i).getInPorts
            
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
            
%             fprintf('router[%i] fetching', i)
%             nodes(cnnctd_nodes(j)).getOutPort(far)

            % 2.2.2) The actual load operation...
            nodes(i).putInPort(nodes(cnnctd_nodes(j)).getOutPort(far), near);

        end
        
        % 2.3) display inputs
%         fprintf('router[%i] inputs', i)
%         nodes(i).getInPorts
        
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
        
        % 3.3) display inputs
%         fprintf('server[%i] inputs', i)
%         nodes(i).getInPorts
    
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
        
%         % 4.2.3) display outputs, PIT and CS
%         fprintf('router[%i] outputs', i)
%         nodes(i).getOutPorts
%         
%         fprintf('router[%i] PIT', i)
%         nodes(i).PIT.PIT
%         
%         fprintf('router[%i] CS', i)
%         nodes(i).CS.CACHE
        
        % 4.2.4) clear inputs
        nodes(i).ifaces.clearInPorts;
        
    end
    
    % 4.3) finally, the servers
    i = i + 1;
    
    for i = i:(clnt_n + rtr_n + srvr_n)

        % 4.3.1) we can clear the output ports btw
        nodes(i).ifaces.clearOutPorts;

        % 4.3.2) a server answers
        nodes(i).answer;
        
%         % 4.3.3) display outputs
%         fprintf('server[%i] outputs', i)
%         nodes(i).getOutPorts
        
        % 4.3.4) clear inputs
        nodes(i).ifaces.clearInPorts;
    
    end
    
    % 5) done, ready for another round...
    
end

% 6) Plottin' time...
colors = ['b', 'r', 'g', 'm', 'y', 'k'];

% % 6.0) requests over time
% figure();
% 
% grid on;
% hold on;
% 
% xlabel('Round #');
% ylabel('# of Requests (Cumulative)');
% 
% for c = (content_n - content_n + 1):(content_n)
% 
%     plot (1:1:round_n, content_requests_time(c, :), sprintf('-%s', colors(rem(c, 6) + 1)), 'LineWidth', 1);
%     
% end
% 
% title(sprintf('Requests over Time'));
% 
% hold off;

% 6.1) total number of Interests/Data sent/received, for each network 
% node

isent = zeros(1, clnt_n + rtr_n + srvr_n);
ircvd = zeros(1, clnt_n + rtr_n + srvr_n);
dsent = zeros(1, clnt_n + rtr_n + srvr_n);
drcvd = zeros(1, clnt_n + rtr_n + srvr_n);

for i = 1:(clnt_n + rtr_n + srvr_n)

    isent(i) = sum(sum(nodes(i).ifaces.stats_interests_sent, 2));
    ircvd(i) = sum(sum(nodes(i).ifaces.stats_interests_rcvd, 2));
    dsent(i) = sum(sum(nodes(i).ifaces.stats_data_sent, 2));
    drcvd(i) = sum(sum(nodes(i).ifaces.stats_data_rcvd, 2));
    
end

figure();

subplot(1, 2, 1);

grid on;
hold on;

xlabel('Node index');
ylabel('# of Interests');

isent_ = plot (1:1:(clnt_n + rtr_n + srvr_n), isent,  '-ob', 'LineWidth', 1);
ircvd_ = plot (1:1:(clnt_n + rtr_n + srvr_n), ircvd,  '-or', 'LineWidth', 1);

legend([isent_ ircvd_], 'sent', 'received');

title(sprintf('Interests'));

hold off;

subplot(1, 2, 2);

grid on;
hold on;

xlabel('Node index');
ylabel('# of Data packets');

dsent_ = plot (1:1:(clnt_n + rtr_n + srvr_n), dsent,  '-ob', 'LineWidth', 1);
drcvd_ = plot (1:1:(clnt_n + rtr_n + srvr_n), drcvd,  '-or', 'LineWidth', 1);

legend([dsent_ drcvd_], 'sent', 'received');

title(sprintf('Data packets'));

hold off;

% 6.2) Cache hit and miss rate per content object, at different NDN router
% levels (this implies the definition of level)
level_n = 3;

hit_level = zeros(content_n, level_n);
hit_level_reg = zeros(content_n, level_n);
miss_level = zeros(content_n, level_n);
miss_level_reg = zeros(content_n, level_n);

for i = (clnt_n + 1):(clnt_n + rtr_n)
    
    hit_level(:,i) = nodes(i).CS.stats_hits ./ (nodes(i).ifaces.stats_interests_rcvd(:, 1) + 1);
    hit_level_reg(:,i) = poly_regression((1:1:content_n)', hit_level(:,i), (1:1:content_n)', 3);
    
    miss_level(:,i) = nodes(i).CS.stats_miss ./ (nodes(i).ifaces.stats_interests_rcvd(:, 1) + 1);
    miss_level_reg(:,i) = poly_regression((1:1:content_n)', miss_level(:,i), (1:1:content_n)', 3);
    
end

figure();

subplot(1, 2, 1);

grid on;
hold on;

% 6.2.1) apparently, this is important
axis([0 content_n 0 1]);

xlabel('Content index');
ylabel('Hit rate');

% 6.2.1) some references for the dynamic plot list (both for the plot
% objects and the legend strings)
plot_obj = zeros(1, rtr_n);
plot_str = cell(1, rtr_n);

for i = (clnt_n + 1):(clnt_n + rtr_n)
    
    plot (1:1:content_n, hit_level(:,i)',  sprintf('o%s', colors(i - (clnt_n + 1) + 1)), 'LineWidth', 1);
    plot_obj(i - clnt_n) = plot(1:1:content_n, hit_level_reg(:,i)',  sprintf('-%s', colors(i - (clnt_n + 1) + 1)), 'LineWidth', 1);
    plot_str{i- clnt_n} = sprintf('Level %d', i - clnt_n);
    
end

% 6.2.2) and this is how you build up a dynamic legend...
legend(plot_obj(1:rtr_n), plot_str{1:rtr_n});

title(sprintf('Cache hit rate'));

hold off;

subplot(1, 2, 2);

grid on;
hold on;

axis([0 content_n 0 1]);

xlabel('Content index');
ylabel('Miss rate');

plot_obj = zeros(1, rtr_n);
plot_str = cell(1, rtr_n);

for i = (clnt_n + 1):(clnt_n + rtr_n)
    
    plot (1:1:content_n, miss_level(:,i)',  sprintf('o%s', colors(i - (clnt_n + 1) + 1)), 'LineWidth', 1);
    plot_obj(i - clnt_n) = plot (1:1:content_n, miss_level_reg(:,i)',  sprintf('-%s', colors(i - (clnt_n + 1) + 1)), 'LineWidth', 1);
    plot_str{i- clnt_n} = sprintf('Level %d', i - clnt_n);
    
end

legend(plot_obj(1:rtr_n), plot_str{1:rtr_n});

title(sprintf('Cache miss rate'));

hold off;

% 6.3) Caching time per content object, at different NDN router
% levels (this implies the definition of level)
time_level = zeros(content_n, level_n);

for i = (clnt_n + 1):(clnt_n + rtr_n)
    
    hit_level(:,i) = nodes(i).CS.stats_hits ./ (nodes(i).ifaces.stats_interests_rcvd(:, 1) + 1);
    hit_level_reg(:,i) = poly_regression((1:1:content_n)', hit_level(:,i), (1:1:content_n)', 3);
    
    miss_level(:,i) = nodes(i).CS.stats_miss ./ (nodes(i).ifaces.stats_interests_rcvd(:, 1) + 1);
    miss_level_reg(:,i) = poly_regression((1:1:content_n)', miss_level(:,i), (1:1:content_n)', 3);
    
end

figure();

grid on;
hold on;

xlabel('Content index');
ylabel('Relative time (to # of rounds)');

% 6.2.1) some references for the dynamic plot list (both for the plot
% objects and the legend strings)
plot_obj = zeros(1, rtr_n);
plot_str = cell(1, rtr_n);

for i = (clnt_n + 1):(clnt_n + rtr_n)
        
    plot_obj(i - clnt_n) = plot(1:1:content_n, (nodes(i).CS.stats_time ./ round_n)', sprintf('-%s', colors(i - (clnt_n + 1) + 1)), 'LineWidth', 1);
    plot_str{i - clnt_n} = sprintf('Level %d', i - clnt_n);
    
end

% 6.2.2) and this is how you build up a dynamic legend...
legend(plot_obj(1:rtr_n), plot_str{1:rtr_n});

title(sprintf('Relative time in CS'));

hold off;
