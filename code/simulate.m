function [] = simulate(content_n, content_popularity, cs_size, cs_type, round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% pre-round phase (setup clients, server, routers, topology, etc.)

% 1) generate the topology elements

% 1.1) index for the topology elements, i.e. for the network nodes
i = 1;

% 1.2) generate clients, save them on the 'nodes' array

for i = i:clnt_n

    nodes(i) = client(i, content_n, 1, content_popularity');
    
end

% 1.3) generate NDN routers

i = i + 1;

for i = i:(clnt_n + rtr_n)

    nodes(i) = router(i, content_n, 2, cs_size, cs_type);
    
end

% 1.4) generate server(s)

i = i + 1;

for i = i:(clnt_n + rtr_n + srvr_n)

    nodes(i) = server(i, content_n, 1);
    
end

%% simulation rounds
%content_requests_time = zeros(content_n, round_n);

for r = 1:round_n
    
%     fprintf('********** ROUND %i: FIGHT **********\n', r)
    
    i = 1;
    
    % 1) client(s) generates Interests, and leave it available on the
    % output ports of their interfaces
    for i = i:clnt_n
        
        % 1.1) after round (round_n - 20), no more Interests
        % TODO: this is non-standard, erratic behaviour (e.g. why 20 ?) so
        % use this carefully...
        if (r < (round_n - 20))
            %requests = nodes(i).requestContent;
            nodes(i).requestContent;
        end
        
%         % 1.1.1) Content requests (total) over time
%         if (r > 2)
%             content_requests_time(:, r) = content_requests_time(:, r - 1) + requests(1:content_n, :);
%         else
%             content_requests_time(:, r) = requests(1:content_n, :);
%         end
        
        % 1.1) display outputs
%         fprintf('client[%i] outputs', i)
%         nodes(i).getOutPorts

        % 1.2) find the connected nodes, i.e. those positions in the
        % topology matrix whose values are > 0
        cnnctd_nodes = find(topology(i,:));
        
        % 1.3) cycle through connected nodes and load the values on their
        % output ports to the input ports of node(i), always checking the 
        % topology matrix for the correct interfaces
        for j = 1:numel(cnnctd_nodes)

            % 1.3.1) Determine the 'near' and 'far' endpoints of the link
            % between the nodes, from the perspective of the current node,
            % i.e. node(i)
            near = topology(i, cnnctd_nodes(j));
            far = topology(cnnctd_nodes(j), i);
            
%             fprintf('router[%i] fetching', i)
%             nodes(cnnctd_nodes(j)).getOutPort(far)

            % 1.3.2) The actual load operation...
            nodes(i).putInPort(nodes(cnnctd_nodes(j)).getOutPort(far), near);

        end
        
        % 1.4) display inputs
%         fprintf('router[%i] inputs', i)
%         nodes(i).getInPorts
            
    end

    % 2) routers fill input ports of all their interfaces
    i = i + 1;
    
    for i = i:(clnt_n + rtr_n)
        
        % 2.1) find the connected nodes
        cnnctd_nodes = find(topology(i,:));
        
        % 2.2) cycle through connected nodes and load the contents exposed 
        % by their
        % output ports, always checking the topology matrix for the correct
        % interfaces
        for j = 1:numel(cnnctd_nodes)

            % 2.2.1) Determine the 'near' and 'far' endpoints of the link
            % between the nodes, from the perspective of the current node,
            % node(i)
            near = topology(i, cnnctd_nodes(j));
            far = topology(cnnctd_nodes(j), i);
            
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
        cnnctd_nodes = find(topology(i,:));
        
        % 3.2) cycle through connected nodes and load the contents at their
        % output ports, always checking the topology matrix for the correct
        % interfaces
        for j = 1:numel(cnnctd_nodes)

            % 3.2.1) Determine the 'near' and 'far' endpoints of the link
            % between the nodes, from the perspective of the current node,
            % node(i)
            near = topology(i, cnnctd_nodes(j));
            far = topology(cnnctd_nodes(j), i);

            % 3.2.2) The actual load operation...
            nodes(i).putInPort(nodes(cnnctd_nodes(j)).getOutPort(far), near);

        end
        
        % 3.3) display inputs
%         fprintf('server[%i] inputs', i)
%         nodes(i).getInPorts
    
    end
    
    % 4) it's processing time!!!
    
    i = 1; 

    % 4.1) handle the clients, basically clear both input and output ports
    for i = i:clnt_n
        
        % 4.1.1) we can clear the output ports btw
        nodes(i).ifaces.clearOutPorts;
        
        % 4.1.2) clear inputs
        nodes(i).ifaces.clearInPorts;
        
    end    
    
    % 4.2) then the routers, which basically consists in forwarding
    % Interests and Data packets
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

        % 4.3.2) a server 'answers', i.e. simply 'mirrors' all the 
        % Interests in its input ports with appropriate Data packets,
        % according to its own Content Store (CS)
        nodes(i).answer;
        
%         % 4.3.3) display outputs
%         fprintf('server[%i] outputs', i)
%         nodes(i).getOutPorts
        
        % 4.3.4) clear inputs
        nodes(i).ifaces.clearInPorts;
    
    end
    
    % 5) done, ready for another round...
    
end

% 6) it's plottin' time...
colors = ['m', 'b', 'r', 'g', 'y', 'k'];

% % 6.0) plot the (cumulative) # of requests over time
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

axis([1 (clnt_n + rtr_n + srvr_n) 0 (1.05 * max([max(isent) max(ircvd)]))]);

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

axis([1 (clnt_n + rtr_n + srvr_n) 0 (1.05 * max([max(dsent) max(drcvd)]))]);

xlabel('Node index');
ylabel('# of Data packets');

dsent_ = plot (1:1:(clnt_n + rtr_n + srvr_n), dsent,  '-ob', 'LineWidth', 1);
drcvd_ = plot (1:1:(clnt_n + rtr_n + srvr_n), drcvd,  '-or', 'LineWidth', 1);

legend([dsent_ drcvd_], 'sent', 'received');

title(sprintf('Data packets'));

hold off;

% 6.2) same thing as 6.1, but applied to topology levels (not individual
% clients, routers or servers)
rtr_level_n = size(rtr_level, 2);

isent = zeros(1, rtr_level_n);
ircvd = zeros(1, rtr_level_n);
dsent = zeros(1, rtr_level_n);
drcvd = zeros(1, rtr_level_n);

for i = 1:rtr_level_n

    level_rtrs = find(rtr_level(:,i));

    for j = 1:numel(level_rtrs)

        isent(i) = isent(i) + sum(sum(nodes(level_rtrs(j)).ifaces.stats_interests_sent, 2));
        ircvd(i) = ircvd(i) + sum(sum(nodes(level_rtrs(j)).ifaces.stats_interests_rcvd, 2));
        dsent(i) = dsent(i) + sum(sum(nodes(level_rtrs(j)).ifaces.stats_data_sent, 2));
        drcvd(i) = drcvd(i) + sum(sum(nodes(level_rtrs(j)).ifaces.stats_data_rcvd, 2));
        
    end
    
end

figure();

subplot(1, 2, 1);

grid on;
hold on;

axis([1 (rtr_level_n) 0 (1.05 * max([max(isent) max(ircvd) max(dsent) max(drcvd)]))]);

xlabel('Topology level');
ylabel('# of Interests');

isent_ = plot (1:1:rtr_level_n, isent,  '-ob', 'LineWidth', 1);
ircvd_ = plot (1:1:rtr_level_n, ircvd,  '-or', 'LineWidth', 1);

legend([isent_ ircvd_], 'sent', 'received');

title(sprintf('Interests per level'));

hold off;

subplot(1, 2, 2);

grid on;
hold on;

xlabel('Topology level');
ylabel('# of Data packets');

dsent_ = plot (1:1:rtr_level_n, dsent,  '-ob', 'LineWidth', 1);
drcvd_ = plot (1:1:rtr_level_n, drcvd,  '-or', 'LineWidth', 1);

legend([dsent_ drcvd_], 'sent', 'received');

title(sprintf('Data packets per level'));

hold off;

% 6.3) Cache hit and miss rate per content object, at different NDN router
% levels (this implies the definition of level, encoded in the rtr_level 
% matrix)
hit_level = zeros(content_n, rtr_level_n);
hit_level_reg = zeros(content_n, rtr_level_n);
miss_level = zeros(content_n, rtr_level_n);
miss_level_reg = zeros(content_n, rtr_level_n);

% 6.3.1) for each router level, gather statistics and pre-process some
% values

for i = 2:(rtr_level_n - 1)
    
    icumul = zeros(content_n, 1);

    % 6.3.1.1) find out which routers belong to level i
    level_rtrs = find(rtr_level(:,i));

    % 6.3.1.2) simply gather the statistics for level i
    for j = 1:numel(level_rtrs)

        hit_level(:,i) = hit_level(:,i) + (nodes(level_rtrs(j)).CS.stats_hits);    
        miss_level(:,i) = miss_level(:,i) + (nodes(level_rtrs(j)).CS.stats_miss);
        icumul = icumul + nodes(level_rtrs(j)).ifaces.stats_interests_rcvd(:, 1) + 1;

    end
        
    % 6.3.1.3) in order to get a well defined line and not simply a bunch of
    % points scattered all over the place, apply linear regression to find
    % it
    hit_level(:,i) = hit_level(:,i) ./ icumul;
    miss_level(:,i) = miss_level(:,i) ./ icumul;
    
    hit_level_reg(:,i) = poly_regression((1:1:content_n)', hit_level(:,i), (1:1:content_n)', 3);
    miss_level_reg(:,i) = poly_regression((1:1:content_n)', miss_level(:,i), (1:1:content_n)', 3);
end

% for i = (clnt_n + 1):(clnt_n + rtr_n)
%     
%     hit_level(:,i) = nodes(i).CS.stats_hits ./ (nodes(i).ifaces.stats_interests_rcvd(:, 1) + 1);
%     hit_level_reg(:,i) = poly_regression((1:1:content_n)', hit_level(:,i), (1:1:content_n)', 3);
%     
%     miss_level(:,i) = nodes(i).CS.stats_miss ./ (nodes(i).ifaces.stats_interests_rcvd(:, 1) + 1);
%     miss_level_reg(:,i) = poly_regression((1:1:content_n)', miss_level(:,i), (1:1:content_n)', 3);
%     
% end

% 6.3.2) after the statistics gathering and pre-processing, the actual
% plots, one subplot for the cache hits, another for cache misses

figure();

subplot(1, 2, 1);

grid on;
hold on;

% 6.3.2.1) apparently, this is important
axis([0 content_n 0 1]);

xlabel('Content index');
ylabel('Hit rate');

% 6.3.2.2) some references for the dynamic plot list (both for the plot
% objects and the legend strings)
plot_obj = zeros(1, rtr_level_n);
plot_str = cell(1, rtr_level_n);

for i = 2:(rtr_level_n - 1)
    
    plot (1:1:content_n, hit_level(:,i)',  sprintf('o%s', colors(i)), 'LineWidth', 1);
    plot_obj(i) = plot(1:1:content_n, hit_level_reg(:,i)', sprintf('-%s', colors(i)), 'LineWidth', 1);
    plot_str{i} = sprintf('Level %d', i);
    
end

% for i = (clnt_n + 1):(clnt_n + rtr_n)
%     
%     plot (1:1:content_n, hit_level(:,i)',  sprintf('o%s', colors(i - (clnt_n + 1) + 1)), 'LineWidth', 1);
%     plot_obj(i - clnt_n) = plot(1:1:content_n, hit_level_reg(:,i)',  sprintf('-%s', colors(i - (clnt_n + 1) + 1)), 'LineWidth', 1);
%     plot_str{i- clnt_n} = sprintf('Level %d', i - clnt_n);
%     
% end

% 6.3.2.3) and this is how you build up a dynamic legend...
legend(plot_obj(2:(rtr_level_n - 1)), plot_str{2:(rtr_level_n - 1)});

title(sprintf('Cache hit rate'));

hold off;

% 6.3.2.4) do the sames as above, now for cache misses
subplot(1, 2, 2);

grid on;
hold on;

axis([0 content_n 0 1]);

xlabel('Content index');
ylabel('Miss rate');

%plot_obj = zeros(1, rtr_level_n);

for i = 2:(rtr_level_n - 1)
    
    plot (1:1:content_n, miss_level(:,i)',  sprintf('o%s', colors(i)), 'LineWidth', 1);
    plot_obj(i) = plot(1:1:content_n, miss_level_reg(:,i)',  sprintf('-%s', colors(i)), 'LineWidth', 1);
    
end

% for i = (clnt_n + 1):(clnt_n + rtr_n)
%     
%     plot (1:1:content_n, miss_level(:,i)',  sprintf('o%s', colors(i - (clnt_n + 1) + 1)), 'LineWidth', 1);
%     plot_obj(i - clnt_n) = plot (1:1:content_n, miss_level_reg(:,i)',  sprintf('-%s', colors(i - (clnt_n + 1) + 1)), 'LineWidth', 1);
%     plot_str{i- clnt_n} = sprintf('Level %d', i - clnt_n);
%     
% end

legend(plot_obj(2:(rtr_level_n - 1)), plot_str{2:(rtr_level_n - 1)});

title(sprintf('Cache miss rate'));

hold off;

% 6.4) Caching time per content object, at different NDN router
% levels (basically, the same procedures as those applied in 6.3 are used
% here)
time_rtr_level = zeros(content_n, rtr_level_n);

for i = 2:(rtr_level_n - 1)

    level_rtrs = find(rtr_level(:,i));

    for j = 1:numel(level_rtrs)

        time_rtr_level(:,i) = time_rtr_level(:,i) + nodes(level_rtrs(j)).CS.stats_time;    
        
    end
    
    time_rtr_level(:,i) = time_rtr_level(:,i) ./ (round_n * numel(level_rtrs));
    
end

figure();

grid on;
hold on;

xlabel('Content index');
ylabel('Relative time');

%plot_obj = zeros(1, rtr_level_n);

for i = 2:(rtr_level_n - 1)
        
    plot_obj(i) = plot(1:1:content_n, time_rtr_level(:,i)', sprintf('-%s', colors(i)), 'LineWidth', 1);
    plot_str{i} = sprintf('Level %d', i);
    
end

legend(plot_obj(2:(rtr_level_n - 1)), plot_str{2:(rtr_level_n - 1)});

title(sprintf('Relative time in CS'));

hold off;

end